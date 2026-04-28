import logging
import sys
from pathlib import Path
import time
from datetime import datetime
import wandb
import mlx.core as mx

from configs.training_config import TrainingConfig
from src.data_processor import DataProcessor
from src.train import BloomTrainer

# Configure logging
def setup_logging():
    # Create logs directory
    log_dir = Path("logs")
    log_dir.mkdir(exist_ok=True)
    
    # Create a timestamp for the log file
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_file = log_dir / f"training_{timestamp}.log"
    
    # Configure logging format
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler(sys.stdout)
        ]
    )
    
    return logging.getLogger(__name__)

def main():
    # Setup logging
    logger = setup_logging()
    logger.info("Starting Bloom's Taxonomy Question Generator training pipeline")
    
    try:
        # Load configuration
        logger.info("Loading training configuration...")
        config = TrainingConfig()
        logger.info(f"Configuration loaded successfully. Using model: {config.model_name}")
        logger.info(f"Training mode: {'LoRA' if config.use_lora else 'Full fine-tuning'}")
        
        # Initialize data processor
        logger.info("Initializing data processor...")
        processor = DataProcessor(config)
        
        # Check for existing processed datasets
        logger.info("Checking for existing processed datasets...")
        datasets = processor.load_datasets()
        
        if not datasets:
            logger.info("No existing datasets found. Processing raw data...")
            logger.info("Downloading dataset from Kaggle...")
            datasets = processor.create_datasets()
            logger.info("Saving processed datasets...")
            processor.save_datasets(datasets)
            logger.info("Dataset processing completed successfully")
        else:
            logger.info("Found existing processed datasets")
        
        # Log dataset statistics
        for split_name, dataset in datasets.items():
            logger.info(f"{split_name.capitalize()} dataset size: {len(dataset)} examples")
        
        # Initialize trainer
        logger.info("Initializing model trainer...")
        trainer = BloomTrainer(config)
        logger.info("Model and optimizer initialized successfully")
        
        # Log hardware information
        logger.info(f"Using device: {mx.default_device()}")
        logger.info(f"Available memory: {mx.metal.get_available_memory() / 1024**3:.2f} GB")
        
        # Initialize wandb
        logger.info("Initializing Weights & Biases...")
        wandb.init(
            project="bloom-question-generator",
            config=config.dict(),
            name=f"training_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        )
        logger.info("Weights & Biases initialized successfully")
        
        # Start training
        logger.info("Starting training process...")
        start_time = time.time()
        
        trainer.train(datasets['train'], datasets['validation'])
        
        # Log training completion
        training_time = time.time() - start_time
        logger.info(f"Training completed successfully in {training_time/3600:.2f} hours")
        
        # Save final model
        logger.info("Saving final model...")
        trainer.save_model("final_model")
        logger.info("Final model saved successfully")
        
        # Cleanup
        wandb.finish()
        logger.info("Training pipeline completed successfully")
        
    except Exception as e:
        logger.error(f"An error occurred during training: {str(e)}", exc_info=True)
        raise

if __name__ == "__main__":
    main() 