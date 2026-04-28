import mlx.core as mx
from transformers import AutoTokenizer, AutoModelForCausalLM
from pathlib import Path
import json
from typing import Dict, Optional
from configs.training_config import TrainingConfig

class BloomInference:
    def __init__(self, model_path: str, config: Optional[TrainingConfig] = None):
        self.model_path = Path(model_path)
        self.config = config or self.load_config()
        self.setup_model()
        
    def load_config(self) -> TrainingConfig:
        """Load configuration from saved model."""
        with open(self.model_path / "config.json", "r") as f:
            config_dict = json.load(f)
        return TrainingConfig(**config_dict)
        
    def setup_model(self):
        """Initialize the model and tokenizer."""
        self.tokenizer = AutoTokenizer.from_pretrained(self.model_path)
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_path,
            torch_dtype="float16" if self.config.mixed_precision else "float32"
        )
        self.model.eval()
        
    def generate_question(
        self,
        bloom_level: str,
        topic: str,
        max_length: int = 100,
        temperature: float = 0.7,
        top_p: float = 0.9
    ) -> str:
        """Generate a question for the given Bloom's level and topic."""
        # Format prompt
        prompt = self.config.prompt_template.format(
            bloom_level=bloom_level,
            topic=topic
        )
        
        # Tokenize
        inputs = self.tokenizer(
            prompt,
            return_tensors="pt",
            padding=True,
            truncation=True,
            max_length=self.config.max_length
        )
        
        # Generate
        with mx.stop_gradient():
            outputs = self.model.generate(
                input_ids=mx.array(inputs["input_ids"]),
                attention_mask=mx.array(inputs["attention_mask"]),
                max_length=max_length,
                temperature=temperature,
                top_p=top_p,
                do_sample=True,
                pad_token_id=self.tokenizer.pad_token_id
            )
            
        # Decode and clean up
        generated_text = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        question = generated_text.split("Question:")[-1].strip()
        
        return question

def main():
    # Example usage
    model_path = "outputs/best_model"
    inference = BloomInference(model_path)
    
    # Test cases
    test_cases = [
        ("Remember", "Photosynthesis"),
        ("Understand", "Quantum Mechanics"),
        ("Apply", "Python Programming"),
        ("Analyze", "World War II"),
        ("Evaluate", "Climate Change"),
        ("Create", "Machine Learning")
    ]
    
    print("Testing question generation:")
    print("-" * 50)
    
    for bloom_level, topic in test_cases:
        question = inference.generate_question(bloom_level, topic)
        print(f"\nBloom's Level: {bloom_level}")
        print(f"Topic: {topic}")
        print(f"Generated Question: {question}")
        print("-" * 50)

if __name__ == "__main__":
    main() 