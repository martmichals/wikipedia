# wikipedia

EDA and pre-processing methods for Wikipedia data dumps.

## Getting Started

Run the data download script. This will take 1hr+ due to seeding for other downloaders.

```bash
    sudo apt update && sudo apt upgrade
    sudo apt install aria2
    bash download.sh
```

## Python Environment

Create environment from the repository's `yml` file:

```bash
conda env create -f wikipedia.yml
```

To save your python environment (and overwrite the current environment file):

```bash
conda env export > wikipedia.yml
```