from langchain.text_splitter import RecursiveCharacterTextSplitter

# Function to chunk an article
def chunk_text(article, tokenizer):
    splitter = RecursiveCharacterTextSplitter(
        chunk_size = 256,
        chunk_overlap = 20,
        length_function = lambda str: len(tokenizer.encode(str))
    )

    return (
        [doc.page_content for doc in splitter.create_documents([article['text']])], 
        article['id']
    )