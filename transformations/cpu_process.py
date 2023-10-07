import os
import json
import argparse
import transformers
from tqdm import tqdm
import multiprocessing
from processing import fxn_map

def main(args):
    # Validate the existence of the input directory
    if not os.path.isdir(args.input):
        raise ValueError(f'{args.input} is not a valid path')
    print(f'Processing {args.input}')

    # Validate the function name argument
    if args.fxn_name not in fxn_map:
        raise ValueError(f'Function name {args.fxn_map} is not valid')
    processing_fxn = fxn_map[args.fxn_name]

    # Check for the existence of a metadata file already
    metadata_filepath = os.path.join(args.input, f'{args.output_basename}.json')
    if os.path.exists(metadata_filepath):
        print('Metadata already extracted for the current directory')
        return
    
    # Parse articles from files
    articles = {}
    for filename in os.listdir(args.input):
        # Skip metadata files
        if 'wiki_' not in filename: continue

        # Process the wiki file
        with open(os.path.join(args.input, filename), 'r') as fin:
            for line in fin:
                if (article := json.loads(line))['text'] != '':
                    if article['id'] not in articles:
                        articles[article['id']] = article
                    else:
                        raise ValueError(f"Not-unique ID {article['id']}")

    # Suppress tokenization length warnings
    transformers.utils.logging.set_verbosity_error()

    # Chunk the articles
    progress_bar = tqdm(total=len(articles))
    with multiprocessing.Pool(processes=32) as pool:
        async_results = [
            pool.apply_async(
                processing_fxn, 
                args=(articles[article_id], ), 
                callback=lambda _: progress_bar.update()
            ) for article_id in articles
        ]

        # Collect async results
        for async_res in async_results:
            output, article_id = async_res.get()
            articles[article_id]['output'] = output

        # Close out worker pool
        pool.close()
        pool.join()
    
    # Close out progress bar
    progress_bar.close()

    # Unsuppress warnings
    transformers.utils.logging.set_verbosity_warning()

    # Write out the article metadata to json file
    metadata = {}
    for article_id in articles:
        metadata[article_id] = articles[article_id]['output']
    with open(metadata_filepath, 'w') as fout:
        json.dump(metadata, fout)

if __name__ == '__main__':
    # Define the argument parser
    parser = argparse.ArgumentParser(
        description = 'Launch one of the CPU-based processing functions against the Wikipedia corpus.'
    )
    parser.add_argument(
        '--input', 
        type = str,
        required = True,
        help = 'Path to directory with article files.'
    )
    parser.add_argument(
        '--output_basename', 
        type = str,
        required = True,
        help = 'Basename for the output files generated by the process.'
    )
    parser.add_argument(
        '--fxn_name', 
        type = str,
        required = True,
        help = 'Which processing function to launch against the articles in the corpus.'
    )

    # Parse arguments
    args = parser.parse_args()

    # Launch script
    main(args)
