import mlx.core as mx
import mlx.nn as nn
from mlx.utils import tree_unflatten
import mlx.optimizers as optim
from transformers import AutoTokenizer, AutoModelForCausalLM
from datasets import Dataset
import wandb
from pathlib import Path
import json
from tqdm import tqdm
from typing import Dict, List, Optional
import numpy as np
import logging
import time

from configs.training_config import TrainingConfig
from src.data_processor import DataProcessor

class BloomTrainer:
    def __init__(self, config: TrainingConfig):
        self.config = config
        self.device = mx.default_device()
        self.logger = logging.getLogger(__name__)
        self.setup_model()
        self.setup_optimizer()
        
    def setup_model(self):
        """Initialize the model and tokenizer."""
        self.logger.info("Loading tokenizer...")
        self.tokenizer = AutoTokenizer.from_pretrained(self.config.model_name)
        self.logger.info("Tokenizer loaded successfully")
        
        self.logger.info("Loading model...")
        self.model = AutoModelForCausalLM.from_pretrained(
            self.config.model_name,
            torch_dtype="float16" if self.config.mixed_precision else "float32"
        )
        self.logger.info("Base model loaded successfully")
        
        if self.config.use_lora:
            self.logger.info("Setting up LoRA...")
            self.setup_lora()
            self.logger.info("LoRA configuration completed")
            
    def setup_lora(self):
        """Configure LoRA for efficient fine-tuning."""
        from peft import LoraConfig, get_peft_model
        
        lora_config = LoraConfig(
            r=self.config.lora_rank,
            lora_alpha=self.config.lora_alpha,
            target_modules=["q_proj", "v_proj"],
            lora_dropout=self.config.lora_dropout,
            bias="none",
            task_type="CAUSAL_LM"
        )
        
        self.model = get_peft_model(self.model, lora_config)
        self.logger.info(f"LoRA configured with rank={self.config.lora_rank}, alpha={self.config.lora_alpha}")
        
    def setup_optimizer(self):
        """Initialize the optimizer."""
        self.logger.info("Setting up optimizer...")
        self.optimizer = optim.Adam(
            learning_rate=self.config.learning_rate,
            weight_decay=self.config.weight_decay
        )
        self.logger.info(f"Optimizer initialized with learning rate={self.config.learning_rate}")
        
    def prepare_batch(self, batch: Dict) -> Dict:
        """Prepare a batch of data for training."""
        # Combine instruction and output
        texts = [
            f"{item['instruction']}\n{item['output']}"
            for item in batch
        ]
        
        # Tokenize
        encodings = self.tokenizer(
            texts,
            padding=True,
            truncation=True,
            max_length=self.config.max_length,
            return_tensors="pt"
        )
        
        return {
            "input_ids": mx.array(encodings["input_ids"]),
            "attention_mask": mx.array(encodings["attention_mask"])
        }
        
    def train_epoch(self, train_dataset: Dataset, epoch: int) -> float:
        """Train for one epoch."""
        total_loss = 0
        num_batches = 0
        batch_times = []
        
        self.logger.info(f"Starting epoch {epoch + 1}/{self.config.num_epochs}")
        
        for i in tqdm(range(0, len(train_dataset), self.config.batch_size), desc=f"Epoch {epoch + 1}"):
            batch_start_time = time.time()
            
            batch = train_dataset[i:i + self.config.batch_size]
            prepared_batch = self.prepare_batch(batch)
            
            # Forward pass
            outputs = self.model(**prepared_batch)
            loss = outputs.loss
            
            # Backward pass
            loss.backward()
            
            # Update weights
            if (i + 1) % self.config.gradient_accumulation_steps == 0:
                self.optimizer.step()
                self.optimizer.zero_grad()
                
                # Log batch statistics
                batch_time = time.time() - batch_start_time
                batch_times.append(batch_time)
                avg_batch_time = sum(batch_times[-100:]) / min(len(batch_times), 100)
                
                self.logger.info(
                    f"Batch {i//self.config.batch_size + 1}/"
                    f"{len(train_dataset)//self.config.batch_size + 1} - "
                    f"Loss: {loss.item():.4f} - "
                    f"Avg batch time: {avg_batch_time:.2f}s"
                )
            
            total_loss += loss.item()
            num_batches += 1
            
            # Log progress
            if (i + 1) % self.config.logging_steps == 0:
                wandb.log({
                    "train_loss": loss.item(),
                    "step": i,
                    "epoch": epoch + 1,
                    "learning_rate": self.optimizer.learning_rate
                })
                
        return total_loss / num_batches
    
    def evaluate(self, eval_dataset: Dataset) -> float:
        """Evaluate the model on the validation set."""
        self.logger.info("Starting evaluation...")
        total_loss = 0
        num_batches = 0
        
        self.model.eval()
        with mx.stop_gradient():
            for i in tqdm(range(0, len(eval_dataset), self.config.batch_size), desc="Evaluating"):
                batch = eval_dataset[i:i + self.config.batch_size]
                prepared_batch = self.prepare_batch(batch)
                
                outputs = self.model(**prepared_batch)
                loss = outputs.loss
                
                total_loss += loss.item()
                num_batches += 1
                
        self.model.train()
        avg_loss = total_loss / num_batches
        self.logger.info(f"Evaluation completed. Average loss: {avg_loss:.4f}")
        return avg_loss
    
    def train(self, train_dataset: Dataset, eval_dataset: Dataset):
        """Main training loop."""
        self.logger.info("Starting training process...")
        best_eval_loss = float('inf')
        
        for epoch in range(self.config.num_epochs):
            epoch_start_time = time.time()
            
            # Training
            train_loss = self.train_epoch(train_dataset, epoch)
            self.logger.info(f"Epoch {epoch + 1} training completed. Average loss: {train_loss:.4f}")
            
            # Evaluation
            eval_loss = self.evaluate(eval_dataset)
            self.logger.info(f"Epoch {epoch + 1} evaluation completed. Average loss: {eval_loss:.4f}")
            
            # Log metrics
            wandb.log({
                "epoch": epoch + 1,
                "train_loss": train_loss,
                "eval_loss": eval_loss,
                "epoch_time": time.time() - epoch_start_time
            })
            
            # Save best model
            if eval_loss < best_eval_loss:
                best_eval_loss = eval_loss
                self.logger.info(f"New best model found! Eval loss: {eval_loss:.4f}")
                self.save_model("best_model")
                
            # Save checkpoint
            if (epoch + 1) % self.config.save_steps == 0:
                self.logger.info(f"Saving checkpoint for epoch {epoch + 1}")
                self.save_model(f"checkpoint_epoch_{epoch + 1}")
                
        self.logger.info("Training completed successfully")
        
    def save_model(self, name: str):
        """Save the model and tokenizer."""
        self.logger.info(f"Saving model as {name}...")
        output_dir = Path(self.config.output_dir) / name
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # Save model
        self.model.save_pretrained(output_dir)
        self.logger.info("Model weights saved")
        
        # Save tokenizer
        self.tokenizer.save_pretrained(output_dir)
        self.logger.info("Tokenizer saved")
        
        # Save config
        with open(output_dir / "config.json", "w") as f:
            json.dump(self.config.dict(), f, indent=2)
        self.logger.info("Configuration saved")
        
        self.logger.info(f"Model saved successfully to {output_dir}")

def main():
    # Load configuration
    config = TrainingConfig()
    
    # Process data
    processor = DataProcessor(config)
    datasets = processor.load_datasets()
    
    if not datasets:
        datasets = processor.create_datasets()
        processor.save_datasets(datasets)
    
    # Initialize trainer
    trainer = BloomTrainer(config)
    
    # Train model
    trainer.train(datasets['train'], datasets['validation'])

if __name__ == "__main__":
    main() 