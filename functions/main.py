# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`

from firebase_functions import https_fn
from firebase_admin import initialize_app
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

@on_document_created(document="items/{itemId}")
def index_in_typesense(event: Event[DocumentSnapshot]) -> None:
  client = typesense.Client({
  'nodes': [{
    'host': 'hawk-perfect-frog.ngrok-free.app', # For Typesense Cloud use xxx.a1.typesense.net
    'port': '80',      # For Typesense Cloud use 443
    'protocol': 'http'   # For Typesense Cloud use https
  }],
  'api_key': 'eSMjP8YVxHdMKoT164TTKLMkXRS47FdDnPENNAA2Ob8RfEfr',
  'connection_timeout_seconds': 2,
  'connection_retries': 3
  })

  client.collections['items'].documents.create({
    'id': event.data['id'],
    'buyerId': event.data['buyerId'],
    'condition': event.data['condition'],
    # dont think we need deletedAt since itll be gone from typesense anyway
    'createdAt': event.data['createdAt'],
    'dateUpdated': event.data['dateUpdated'],
    'description': event.data['description'],
    'images': event.data['images'],
    'marketplaceId': event.data['marketplaceId'],
    'name': event.data['name'],
    'price': event.data['price'],
    'schoolId': event.data['schoolId'],
    'sellerId': event.data['sellerId'],
    'tags': event.data['tags'],
    'isFlagged': event.data['isFlagged']
    # also dont think we need lastReviewed by
    })
  print(f"Created document: {event.data}")

# initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")