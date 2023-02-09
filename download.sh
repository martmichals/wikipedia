# Bash coloring macros
RED='\033[0;31m'
RESET='\033[0m'

# Exit on any error
set -e

# Data directory
DATA_DIR=./data

# Magnet link for wikipedia data dump
TORRENT_INDEX="https://www.litika.com/torrents/enwiki-20211020-pages-articles-multistream-index.txt.bz2.torrent"
TORRENT_ARTICLES="https://www.litika.com/torrents/enwiki-20211020-pages-articles-multistream.xml.bz2.torrent"

# Check for existence of data directory
if [ ! -d $DATA_DIR ]; then
    echo "Data directory $DATA_DIR not found. Creating."
    mkdir $DATA_DIR
fi

# Download the files, seed for 30 minutes each
# Best practice: --seed_ratio 1.0, but this results in indefinite runtime
aria2c -d ./data -V --seed-time=30 $TORRENT_INDEX
aria2c -d ./data -V --seed-time=30 $TORRENT_ARTICLES

# Delete all downloaded torrent files
rm $DATA_DIR/*.torrent

# Organize files into dated directories
# Note: filename validation is not extremely rigorous
for filepath in $DATA_DIR/*.bz2; do
    # Split on '-'
    IFS='-' read -r -a array <<< $filepath

    # Validate filename format
    if [ ! "${#array[@]}" -gt 2 ]; then
        echo -e $RED Invalid filename encountered: $RESET $filepath
        exit 1
    fi

    # Validate date field is numerical
    if [[ ! "${array[1]}" =~ ^[0-9]+$ ]]; then
        echo -e $RED Filename has non-numerical date: $RESET $filepath
        exit 1 
    fi

    # Validate date field in of the correct length
    if [ ! "${#array[1]}" -eq 8 ]; then
        echo -e $RED Filename has ill-formatted date: $RESET $filepath
        exit 1 
    fi

    # Format date
    date="$(echo "${array[1]}" | cut -c1-4)"
    date="$date-$(echo "${array[1]}" | cut -c5-6)"
    date="$date-$(echo "${array[1]}" | cut -c7-8)"

    # Create directory if it does not exist
    file_dir=$DATA_DIR/$date
    if [ ! -d $file_dir ]; then
        mkdir $file_dir
    fi

    # Move file to directory
    mv $filepath $file_dir
done

# TODO: Give exe permissions to scripts in the scripts folder
# TODO: Change directory structure of 2021-10-20 to include zipped directory
# TODO: Move this to the scripts directory
