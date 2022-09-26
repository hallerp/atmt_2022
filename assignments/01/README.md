# Assignment 1: Training and Evaluating a Basic NMT System

In this assignment we use sv-en data from the Infopankki
corpus to train our model and then evaluate performance on
both in-domain and out-of-domain data.

All data has been prepared for the experiments so you just
need to train the model and translate the different test
sets.

# Train a model

```
python train.py \
    --data data/en-sv/infopankki/prepared \
    --source-lang sv \
    --target-lang en \
    --save-dir assignments/01/baseline/checkpoints
```

# Run inference

```
python translate.py \
    --data data/en-sv/infopankki/prepared \
    --dicts data/en-sv/infopankki/prepared \
    --checkpoint-path assignments/01/baseline/checkpoints/checkpoint_last.pt \
    --output assignments/01/baseline/infopankki_translations.txt
```
