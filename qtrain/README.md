# Bloom's Taxonomy Question Generator

A fine-tuned Llama 3.1 8B model for generating educational questions at specific Bloom's taxonomy levels, optimized for M1 Pro MacBooks using the MLX framework.

## Features

- Fine-tuned Llama 3.1 8B model for educational question generation
- Supports all 6 Bloom's taxonomy levels
- Optimized for M1 Pro MacBooks using MLX
- Both LoRA and full fine-tuning options
- Concise, parser-friendly outputs
- Comprehensive evaluation framework

## Project Structure

```
.
├── configs/
│   └── training_config.py    # Training configuration
├── data/                     # Processed datasets
├── notebooks/
│   └── evaluation.ipynb      # Model evaluation notebook
├── outputs/                  # Saved models and results
├── src/
│   ├── data_processor.py     # Data preprocessing
│   ├── train.py             # Training script
│   └── inference.py         # Inference script
└── requirements.txt          # Project dependencies
```

## Setup

1. Create a virtual environment:
```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Download the dataset:
```bash
python src/data_processor.py
```

## Training

To train the model with LoRA (default):
```bash
python src/train.py
```

The training script will:
- Process and split the dataset
- Fine-tune the model using MLX
- Save checkpoints and the best model
- Log metrics to Weights & Biases

## Inference

To generate questions:
```bash
python src/inference.py
```

Example usage in Python:
```python
from src.inference import BloomInference

inference = BloomInference("outputs/best_model")
question = inference.generate_question(
    bloom_level="Analyze",
    topic="World War II"
)
print(question)
```

## Evaluation

Run the evaluation notebook:
```bash
jupyter notebook notebooks/evaluation.ipynb
```

The notebook provides:
- Question quality analysis
- Length distribution analysis
- Example questions for each Bloom's level
- Performance metrics

## Model Output Format

The model generates concise questions in response to prompts like:
```
Generate a [BLOOM_LEVEL] question about [TOPIC]
```

Example outputs:
- "What are the key components of photosynthesis?"
- "How would you apply the principles of quantum mechanics to explain electron behavior?"
- "Compare and contrast the causes of World War I and World War II."

## Hardware Requirements

- MacBook with M1 Pro chip
- 32GB RAM recommended
- Sufficient storage for model weights and datasets

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Dataset: [Bloom's Taxonomy Dataset](https://www.kaggle.com/datasets/vijaydevane/blooms-taxonomy-dataset)
- Base model: [Llama 3.1 8B](https://huggingface.co/meta-llama/Llama-2-7b-hf)
- Framework: [MLX](https://github.com/ml-explore/mlx) 