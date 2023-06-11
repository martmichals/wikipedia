# Bash coloring macros
RED='\033[0;31m'
RESET='\033[0m'

# Exit on any error
set -e

# Process command line arguments
while test $# != 0
do
    case "$1" in
    -k) KEEP_ZIP=1 ;;
    -d) DATA_DIR="$2"; shift;;
    esac
    shift
done

# Check required arguments
DATA_DIR="${DATA_DIR:-../data}"
KEEP_ZIP="${KEEP_ZIP:-0}"

# Magnet link for wikipedia data dump
TORRENT_ARTICLES="https://www.litika.com/torrents/enwiki-20211020-pages-articles-multistream.xml.bz2.torrent"
TORRENT_INDEX="https://www.litika.com/torrents/enwiki-20211020-pages-articles-multistream-index.txt.bz2.torrent"

# Check for existence of data directory
if [ ! -d $DATA_DIR ]; then
    echo "Data directory $DATA_DIR not found. Creating."
    mkdir -p $DATA_DIR
fi

# Download the files, seed for 30 minutes each
# Best practice: --seed_ratio 1.0, but this results in indefinite runtime
aria2c -d $DATA_DIR -V --seed-time=30 $TORRENT_INDEX
aria2c -d $DATA_DIR -V --seed-time=30 $TORRENT_ARTICLES

# Delete all downloaded torrent files
rm $DATA_DIR/*.torrent

# Organize files into dated directories
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

    # Create a directory for unzipped files if it does not exist
    unzip_dir=$DATA_DIR/$date/unzipped
    if [ ! -d $unzip_dir ]; then
        mkdir -p $unzip_dir
    fi
    
    # Unzip
    if [ $KEEP_ZIP -eq 1 ]; then
        zip_dir=$DATA_DIR/$date/zipped
        if [ ! -d $zip_dir ]; then
            mkdir -p $zip_dir
        fi
        bzip2 -dk $filepath
        mv $filepath $zip_dir
    else
        bzip2 -d $filepath
    fi
    mv "${filepath::-4}" $unzip_dir
done

