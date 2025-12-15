import firebase_admin
from firebase_admin import credentials, firestore
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent
KEY_PATH = BASE_DIR / "serviceAccountKey.json"

try:
    firebase_admin.get_app()
except ValueError:
    cred = credentials.Certificate(str(KEY_PATH))
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("Done")
