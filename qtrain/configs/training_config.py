from pydantic import BaseModel
from typing import Literal, Optional

class TrainingConfig(BaseModel):
    # Model configuration
    model_name: str = "meta-llama/Llama-2-7b-hf"
    max_length: int = 512
    batch_size: int = 4
    gradient_accumulation_steps: int = 4
    
    # Training configuration
    learning_rate: float = 2e-5
    num_epochs: int = 3
    warmup_steps: int = 100
    weight_decay: float = 0.01
    
    # LoRA configuration
    use_lora: bool = True
    lora_rank: int = 8
    lora_alpha: int = 16
    lora_dropout: float = 0.05
    
    # Dataset configuration
    train_split: float = 0.8
    val_split: float = 0.1
    test_split: float = 0.1
    
    # Output configuration
    output_dir: str = "outputs"
    save_steps: int = 500
    eval_steps: int = 100
    logging_steps: int = 10
    
    # Hardware configuration
    mixed_precision: bool = True
    gradient_checkpointing: bool = True
    
    # Prompt template
    prompt_template: str = """Generate a {bloom_level} question about {topic}.
Question:"""
    
    # Bloom's taxonomy levels
    bloom_levels: list[str] = [
        "Remember",
        "Understand",
        "Apply",
        "Analyze",
        "Evaluate",
        "Create"
    ] 