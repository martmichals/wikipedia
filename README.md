# wikipedia

Various projects using wikipedia data dumps.

## Getting Started

Run the data setup script. This will take 1hr+ due to seeding for other downloaders. This
script downloads the wikipedia data dump via torrent, and decompresses the data dump.

```bash
    sudo apt update && sudo apt upgrade
    sudo apt install aria2
    cd scripts
    chmod +x ./setup.sh && ./setup.sh
    cd ..
```

Create a conda environment from the `wikipedia.yml`:

```bash
conda env create -f wikipedia.yml
```

If required, run script to [extract plain text](https://github.com/attardi/wikiextractor) from the wikipedia articles. 
Some notebooks use wikipedia in its compressed form, so this may or may not be necessary:

```bash
wikiextractor \
    --processes 96 \
    --json  \
    -o ./data/<dump-date>/json/ \
    ./data/<dump-date>/unzipped/enwiki-<dump-date-compressed>-pages-articles-multistream.xml 
```

## Python Environment

To save your python environment (and overwrite the current environment file):

```bash
conda env export > wikipedia.yml
```

## WIKIR

To download the WIKIR datasets:

```bash
cd data
wget https://www.zenodo.org/record/3707606/files/enwikIR.zip?download=1
wget https://www.zenodo.org/record/3707238/files/enwikIRS.zip?download=1
```

To unzip and organize:

```bash
unzip 'enwikIR.zip?download=1' && unzip 'enwikIRS.zip?download=1'
rm 'enwikIR.zip?download=1' 'enwikIRS.zip?download=1'
mkdir WIKIR
mv enwikIR WIKIR && mv enwikIRS WIKIR
```

## WikiPassageQA

To download the WikiPassageQA dataset:

```bash
cd data
wget https://ciir.cs.umass.edu/downloads/wikipassageqa/WikiPassageQA.zip
```

To unzip and organize:

```bash
unzip WikiPassageQA.zip -d WikiPassageQA && rm WikiPassageQA.zip 
```

## TODO
Integrate in a better way to handle batch processing, using an idempotent data pipeline. Ideally, handles data download, file structure,
organization, database standup, and launches of training/validation/testing jobs.
 - Apache Airflow
 - Spotify Luigi
 
## Airflow Installation

Notes on installing Airflow.


