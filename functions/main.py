from firebase_admin import firestore, initialize_app
import google.cloud.firestore
import requests

import functions_framework

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

API_KEY = 'eSMjP8YVxHdMKoT164TTKLMkXRS47FdDnPENNAA2Ob8RfEfr'
base_url = "https://hawk-perfect-frog.ngrok-free.app"

@functions_framework.http
def make_request(request):
  requests.post(request[0], headers=request[1], json=request[2]).raise_for_status()


@on_document_created(document="items/{itemId}")
def index_in_typesense(event: Event[DocumentSnapshot]) -> None:
  item = event.data.to_dict()

  url = f"{base_url}/collections/items/documents"

  headers = {
      "Content-Type": "application/json",
      "x-typesense-api-key": API_KEY
  }
  data = {
    'id': str(event.params['itemId']),
    'buyerId': item['buyerId'],
    'condition': item['condition'],
    'deletedAt': str(item['deletedAt']),
    'createdAt': str(item['createdAt']),
    'dateUpdated': str(item['dateUpdated']),
    'description': item['description'],
    'images': item['images'],
    'marketplaceId': item['marketplaceId'],
    'name': item['name'],
    'price': item['price'],
    'schoolId': item['schoolId'],
    'sellerId': item['sellerId'],
    'tags': item['tags'],
    'isFlagged': item['isFlagged'],
    'lastReviewedBy': item['lastReviewedBy']
  }
  
  make_request([url, headers, data])

@on_document_created(document="typesense_sync/{backfillId}")
def backfill_in_typesense(event: Event[DocumentSnapshot], request) -> None:
  backfill_dict = event.data.to_dict()
  if event.params['backfillId'] == 'backfill' and backfill_dict['trigger'] == True:
    firestore_client: google.cloud.firestore.Client = firestore.client()
    docs = firestore_client.collection('items').stream()

    for doc in docs:
      item = doc.to_dict()
      url = f"{base_url}/collections/items/documents/{str(doc.id)}"

      req = requests.get(url, headers={"X-TYPESENSE-API-KEY": API_KEY})
      if req.status_code == 200:
        break
      else:
        url = f"{base_url}/collections/items/documents"

        headers = {
            "Content-Type": "application/json",
            "x-typesense-api-key": API_KEY
        }

        # if doc doesnt exist, add it
        data = {
          'id': str(event.params['itemId']),
          'buyerId': item['buyerId'],
          'condition': item['condition'],
          'deletedAt': str(item['deletedAt']),
          'createdAt': str(item['createdAt']),
          'dateUpdated': str(item['dateUpdated']),
          'description': item['description'],
          'images': item['images'],
          'marketplaceId': item['marketplaceId'],
          'name': item['name'],
          'price': item['price'],
          'schoolId': item['schoolId'],
          'sellerId': item['sellerId'],
          'tags': item['tags'],
          'isFlagged': item['isFlagged'],
          'lastReviewedBy': item['lastReviewedBy']
        }

        make_request([url, headers, data])
