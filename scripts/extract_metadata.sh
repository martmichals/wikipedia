DATA_DIR="../data/2021-10-20/json"

cd ../embed
for dir_path in "$DATA_DIR"/*; do
    if [ -d "$dir_path" ]; then
        python ./extract_metadata.py --input "$dir_path" --metadata_suffix "langchain"
    fi
done
