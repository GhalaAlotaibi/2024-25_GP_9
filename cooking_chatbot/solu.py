# solu.py - Complete Local Version
import os
from langchain_community.document_loaders import PyMuPDFLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from sentence_transformers import SentenceTransformer
from deep_translator import GoogleTranslator
import chromadb
from chromadb.config import Settings
import requests
import json

# ===== Configuration =====
PDF_FOLDER = "cooking_chatbot//cooking_books"  # Place your PDFs here
CHROMA_DB_PATH = "./chroma_db"
QWEN_API_KEY = os.getenv('QWEN_API_KEY') # Replace with your actual key
OPENAI_API_BASE = "https://openrouter.ai/api/v1"

# ===== Initialize Components =====
translator = GoogleTranslator(source='auto', target='en')
translator_ar = GoogleTranslator(source='auto', target='ar')
embedding_model = None

def get_embedding_model():
    global embedding_model
    if embedding_model is None:
        print("🔍 Loading embedding model...")
        embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
    return embedding_model

client = chromadb.PersistentClient(path=CHROMA_DB_PATH)

# ===== Core Functions ===== 
def initialize_database():
    """Load PDFs and create embeddings"""
    collection = client.get_or_create_collection(name="recipes")
    print("📥 Loading PDFs...")
    print("🧠 Creating embeddings...")
    print("✅ Database initialized.")

    # Skip loading if collection already has data
    if len(collection.get()['ids']) > 0:
        return collection
        
    all_pages = []
    pdf_files = [f for f in os.listdir(PDF_FOLDER) if f.endswith(".pdf")]
    
    if not pdf_files:
        print("Warning: No PDF files found in cooking_books directory")
        return collection  # Return empty collection
    
    for pdf_file in pdf_files:
        try:
            loader = PyMuPDFLoader(os.path.join(PDF_FOLDER, pdf_file))
            pages = loader.load_and_split()
            all_pages.extend(pages)
            print(f"Loaded {pdf_file}")
        except Exception as e:
            print(f"Error loading {pdf_file}: {e}")
            continue  # Skip failed files

    if not all_pages:  
        return collection

 
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=512, chunk_overlap=24)
    chunks = text_splitter.split_documents(all_pages)
    texts = [chunk.page_content for chunk in chunks]
    
    if not texts:  # If no texts after splitting
        return collection
        
    embedding_model = get_embedding_model()
    embeddings = embedding_model.encode(texts, batch_size=8, show_progress_bar=True)



    
    collection.add(
        ids=[f"doc_{i}" for i in range(len(texts))],
        documents=texts,
        embeddings=embeddings
    )
    return collection
collection = None

def ensure_collection_initialized():
    global collection
    if collection is None:
        print("⚙️ Initializing collection...")
        collection = initialize_database()


def translate_with_gpt(text: str, target_lang: str = "English") -> str:
    """Advanced translation using GPT"""
    headers = {
        "Authorization": f"Bearer {QWEN_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "gpt-3.5-turbo", 
        "messages": [
            {
                "role": "system",
                    "content": f"""
You are a smart and professional translator. Translate the following text to {target_lang} accurately.
Understand the user's intent, even if the input is casual, misspelled, or slang.
Preserve the meaning and context. Do not explain or comment — return only the translation.
"""
            },
            {
                "role": "user",
                "content": text
            }
        ],
        "temperature": 0.3
    }
    
    try:
        response = requests.post(
            f"{OPENAI_API_BASE}/chat/completions",
            headers=headers,
            json=payload
        )
        return response.json()["choices"][0]["message"]["content"]
    except Exception as e:
        print(f"Translation error: {e}")
        return text

def query_chroma(query: str, top_k: int = 3) -> list:
    """Search the knowledge base"""
    query_embedding = get_embedding_model().encode(query).tolist()
    results = collection.query(
        query_embeddings=[query_embedding],
        n_results=top_k
    )
    return results['documents'][0] if results else []

def generate_response(query: str, context: str) -> str:
    """Generate answer using GPT"""
    headers = {
        "Authorization": f"Bearer {QWEN_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {
                "role": "system",
               "content": """You are a highly knowledgeable cooking assistant. Follow these strict rules:
    **Understand the user's question**
      - First, determine whether the user is asking for a **cooking recipe** or a **general question**.
      - Then, check if the provided context contains information that is directly helpful for answering the user's question.
      - If the context is useful, use it to help form your answer.
      - If the context is not useful or relevant, simply answer the question using your own knowledge.

    **1. Recipe Requests:**
       - ALWAYS provide **complete** recipes with the following sections:
         - **[INGREDIENTS]**: List all ingredients with **exact measurements**.
         - **[METHOD]**: Numbered steps with clear, detailed instructions.
       - **Use context ONLY** if it includes proper ingredient lists and instructions.
       - If context lacks key details, **fill gaps using standard cooking practices**.
       - If no relevant recipe is found, **use your own cooking knowledge to provide a full, accurate recipe**.
       - DO NOT mention where the recipe was retrieved from. Just present it naturally.

    **2. Other Cooking-Related Questions:**
       - Answer **clearly and concisely**.
       - If possible, **suggest a related recipe** that fits the query.

    **3. Restrictions (NEVER do the following):**
       - DO NOT ask follow-up questions.
       - DO NOT provide **incomplete** or **partial** recipes.
       - DO NOT respond with phrases like **"Would you like..."** or **"Do you want more details?"**.
       - DO NOT make up ingredients if unsure—use **best culinary practices** instead.

    Maintain a **professional and structured tone** while being friendly and helpful.
    """
            },
            {
                "role": "user",
                "content": f"Query: {query}\nContext: {context}"
            }
        ],
        "temperature": 0.7
    }
    
    try:
        response = requests.post(
            f"{OPENAI_API_BASE}/chat/completions",
            headers=headers,
            json=payload
        )
        return response.json()["choices"][0]["message"]["content"]
    except Exception as e:
        print(f"GPT error: {e}")
        return "حدث خطأ في المعالجة"

# ===== Main Function =====
def get_answer(query: str) -> str:
    """Full query processing pipeline"""
    try:
        ensure_collection_initialized()  # 👈 initialize on demand
        # Step 1: Translate query to English
        english_query = translate_with_gpt(query, "English")
        
        # Step 2: Search knowledge base
        context_chunks = query_chroma(english_query)
        context = "\n".join(context_chunks) if context_chunks else ""
        
        # Step 3: Generate response
        english_response = generate_response(english_query, context)
        
        # Step 4: Translate back to Arabic
        return translate_with_gpt(english_response, "Arabic")
        
    except Exception as e:
        return f"Error: {str(e)}"

# Test (run only once)
if __name__ == "__main__":
    print("Initializing database...")
    initialize_database()
    test_query = "كيفية عمل البان كيك؟"
    print(f"Test Query: {test_query}")
    print(f"Response: {get_answer(test_query)}")