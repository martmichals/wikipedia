import nltk

# Function to get token and sentence counts
def get_sentence_token_stats(article):
    return (
        {
            'sentence_count': len(nltk.sent_tokenize(article['text'])),
            'token_count': len(nltk.word_tokenize(article['text']))
        }, 
        article['id']
    )

# Map of fxn names to functions that match cpu_process schema
fxn_map = {
    'get_sentence_token_stats': get_sentence_token_stats
}

