# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_admin import firestore, initialize_app
import google.cloud.firestore
import typesense

from firebase_functions.firestore_fn import (
  on_document_created,
  on_document_deleted,
  on_document_updated,
  on_document_written,
  Event,
  Change,
  DocumentSnapshot,
)

initialize_app()
client = typesense.Client({
  'nodes': [{
    'host': 'hawk-perfect-frog.ngrok-free.app',
    'port': '80',
    'protocol': 'http'
  }],
  'api_key': 'eSMjP8YVxHdMKoT164TTKLMkXRS47FdDnPENNAA2Ob8RfEfr',
  'connection_timeout_seconds': 2,
  'connection_retries': 3
  })

@on_document_created(document="items/{itemId}")
def index_in_typesense(event: Event[DocumentSnapshot]) -> None:
  item = event.data.to_dict()
  
  client.collections['items'].documents.create({
    'id': event.params['itemId'],
    'buyerId': item['buyerId'],
    'condition': item['condition'],
    'deletedAt': item['deletedAt'],
    'createdAt': item['createdAt'],
    'dateUpdated': item['dateUpdated'],
    'description': item['description'],
    'images': item['images'],
    'marketplaceId': item['marketplaceId'],
    'name': item['name'],
    'price': item['price'],
    'schoolId': item['schoolId'],
    'sellerId': item['sellerId'],
    'tags': item['tags'],
    'isFlagged': item['isFlagged']
    })

@on_document_created(document="typesense_sync/{backfillId}")
def backfill_in_typesense(event: Event[DocumentSnapshot]) -> None:
  backfill_dict = event.data.to_dict()
  if event.params['backfillId'] == 'backfill' and backfill_dict['trigger'] == True:
    firestore_client: google.cloud.firestore.Client = firestore.client()
    docs = firestore_client.collection('items').stream()

    for doc in docs:
      item = doc.to_dict()
      try:
        # if doc exists
        client.collections['items'].documents[str(doc.id)].retrieve()
        break
      except:
        # if doc doesnt exist, add it
        client.collections['items'].documents.create({
        'id':doc.id,
        'buyerId': item['buyerId'],
        'condition': item['condition'],
        'deletedAt': item['deletedAt'],
        'createdAt': item['createdAt'],
        'dateUpdated': item['dateUpdated'],
        'description': item['description'],
        'images': item['images'],
        'marketplaceId': item['marketplaceId'],
        'name': item['name'],
        'price': item['price'],
        'schoolId': item['schoolId'],
        'sellerId': item['sellerId'],
        'tags': item['tags'],
        'isFlagged': item['isFlagged']
        })