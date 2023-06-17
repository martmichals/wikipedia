DATA_DIR="../data/2021-10-20/json"

cd ../embed
for dir_path in "$DATA_DIR"/*; do
    if [ -d "$dir_path" ]; then
        python cpu_process.py \
            --input "$dir_path" \
            --output_basename nltk_stats \
            --fxn_name get_sentence_token_stats
    fi
done
