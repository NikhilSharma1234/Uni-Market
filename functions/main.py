from firebase_admin import firestore, initialize_app
from firebase_functions import https_fn
import google.cloud.firestore
import requests
import datetime

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

headers = {
  "Content-Type": "application/json",
  "x-typesense-api-key": API_KEY
}

def compile_data(id, item):
  return {
    'id': str(id),
    'buyerId': str(item['buyerId']),
    'condition': item['condition'],
    'deletedAt': item['deletedAt'].timestamp() if item['deletedAt'] != None else 0.0,
    'createdAt': item['createdAt'].timestamp() if item['createdAt'] != None else 0.0,
    'dateUpdated': item['dateUpdated'].timestamp() if item['dateUpdated'] != None else 0.0,
    'description': item['description'],
    'images': item['images'],
    'marketplaceId': item['marketplaceId'],
    'name': item['name'],
    'price': item['price'],
    'schoolId': item['schoolId'],
    'sellerId': item['sellerId'],
    'tags': item['tags'],
    'isFlagged': item['isFlagged'],
    'lastReviewedBy': str(item['lastReviewedBy'])
  }

@functions_framework.http
def make_request(request):
  requests.post(request[0], headers=request[1], json=request[2]).raise_for_status()

@on_document_updated(document="items/{itemId}")
def update_in_typesense(event: Event[Change[DocumentSnapshot]]) -> None:
  item = event.data.after.to_dict()

  url = f"{base_url}/collections/items/documents?action=upsert"

  data = compile_data(event.params['itemId'], item)
  
  make_request([url, headers, data])

@on_document_created(document="items/{itemId}")
def index_in_typesense(event: Event[DocumentSnapshot]) -> None:
  item = event.data.to_dict()

  url = f"{base_url}/collections/items/documents"

  data = compile_data(event.params['itemId'], item)

  make_request([url, headers, data])

@on_document_created(document="typesense_sync/{backfillId}")
def backfill_in_typesense(event: Event[DocumentSnapshot]) -> None:
  backfill_dict = event.data.to_dict()
  if event.params['backfillId'] == 'backfill' and backfill_dict['trigger'] == True:
    firestore_client: google.cloud.firestore.Client = firestore.client()
    docs = firestore_client.collection('items').stream()

    for doc in docs:
      item = doc.to_dict()
      url = f"{base_url}/collections/items/documents/{str(doc.id)}"

      req = requests.get(url, headers={"X-TYPESENSE-API-KEY": API_KEY})
      if req.status_code != 200:
        url = f"{base_url}/collections/items/documents"

        # if doc doesnt exist, add it
        data = compile_data(doc.id, item)

        make_request([url, headers, data])

@https_fn.on_call()
def search_typesense(req: https_fn.CallableRequest) -> any:
  headersSearch = {
    "Access-Control-Allow-Origin": "*",
    'Access-Control-Allow-Methods': 'true',
    "X-TYPESENSE-API-KEY": API_KEY,
  }
  response = requests.get('https://hawk-perfect-frog.ngrok-free.app/collections/items/documents/search{fullQuery}'.format(fullQuery=req.data['fullQuery']), headers=headersSearch)
  return response.text

@https_fn.on_call()
def search_tags_typesense(req: https_fn.CallableRequest) -> any:
  headersSearch = {
    "Access-Control-Allow-Origin": "*",
    'Access-Control-Allow-Methods': 'true',
    "X-TYPESENSE-API-KEY": API_KEY,
  }
  response = requests.get('https://hawk-perfect-frog.ngrok-free.app/collections/tags/documents/search{fullQuery}'.format(fullQuery=req.data['fullQuery']), headers=headersSearch)
  return response.text

@https_fn.on_call()
def search_suggestions_typesense(req: https_fn.CallableRequest) -> any:
  headersSearch = {
    "Access-Control-Allow-Origin": "*",
    'Access-Control-Allow-Methods': 'true',
    "X-TYPESENSE-API-KEY": API_KEY,
  }
  response = requests.get('https://hawk-perfect-frog.ngrok-free.app/collections/suggestions/documents/search{fullQuery}'.format(fullQuery=req.data['fullQuery']), headers=headersSearch)
  return response.text
