import kagglehub
import pandas as pd
from datasets import Dataset
from typing import Dict, List
import json
from pathlib import Path
from configs.training_config import TrainingConfig

class DataProcessor:
    def __init__(self, config: TrainingConfig):
        self.config = config
        self.data_dir = Path("data")
        self.data_dir.mkdir(exist_ok=True)
        
    def download_dataset(self) -> pd.DataFrame:
        """Download the Bloom's taxonomy dataset from Kaggle."""
        dataset_path = kagglehub.dataset_download("vijaydevane/blooms-taxonomy-dataset")
        return pd.read_csv(dataset_path)
    
    def preprocess_data(self, df: pd.DataFrame) -> List[Dict]:
        """Convert the dataset into instruction format."""
        processed_data = []
        
        for _, row in df.iterrows():
            # Create instruction format
            instruction = self.config.prompt_template.format(
                bloom_level=row['bloom_level'],
                topic=row['topic']
            )
            
            processed_data.append({
                "instruction": instruction,
                "input": "",
                "output": row['question'],
                "bloom_level": row['bloom_level'],
                "topic": row['topic']
            })
        
        return processed_data
    
    def create_datasets(self) -> Dict[str, Dataset]:
        """Create train, validation, and test datasets."""
        # Download and preprocess data
        raw_data = self.download_dataset()
        processed_data = self.preprocess_data(raw_data)
        
        # Convert to HuggingFace dataset
        dataset = Dataset.from_list(processed_data)
        
        # Split dataset
        splits = dataset.train_test_split(
            test_size=self.config.val_split + self.config.test_split,
            seed=42
        )
        
        val_test = splits['test'].train_test_split(
            test_size=self.config.test_split / (self.config.val_split + self.config.test_split),
            seed=42
        )
        
        return {
            'train': splits['train'],
            'validation': val_test['train'],
            'test': val_test['test']
        }
    
    def save_datasets(self, datasets: Dict[str, Dataset]):
        """Save processed datasets to disk."""
        for split_name, dataset in datasets.items():
            output_path = self.data_dir / f"{split_name}.json"
            dataset.to_json(output_path)
            
    def load_datasets(self) -> Dict[str, Dataset]:
        """Load processed datasets from disk."""
        datasets = {}
        for split_name in ['train', 'validation', 'test']:
            input_path = self.data_dir / f"{split_name}.json"
            if input_path.exists():
                datasets[split_name] = Dataset.from_json(str(input_path))
        return datasets

if __name__ == "__main__":
    config = TrainingConfig()
    processor = DataProcessor(config)
    
    # Process and save datasets
    datasets = processor.create_datasets()
    processor.save_datasets(datasets) 