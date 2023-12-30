from pathlib import Path

# Directories
EFS_DIR = Path("/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/extraction/simple")
DOCS_DIR = Path("/Users/htr365/Documents/Side_Projects/09_founding_lab/semester_project/meta-studies/extraction/simple/papers/original_studies")
ROOT_DIR = Path(__file__).parent.parent.absolute()

# Mappings
EMBEDDING_DIMENSIONS = {
    "thenlper/gte-base": 768,
    "thenlper/gte-large": 1024,
    "BAAI/bge-large-en": 1024,
    "text-embedding-ada-002": 1536,
    "gte-large-fine-tuned": 1024,
}
MAX_CONTEXT_LENGTHS = {
    "gpt-4": 8192,
    "gpt-3.5-turbo": 4096,
    "gpt-3.5-turbo-16k": 16384,
    "meta-llama/Llama-2-7b-chat-hf": 4096,
    "meta-llama/Llama-2-13b-chat-hf": 4096,
    "meta-llama/Llama-2-70b-chat-hf": 4096,
    "codellama/CodeLlama-34b-Instruct-hf": 16384,
    "mistralai/Mistral-7B-Instruct-v0.1": 65536,
}