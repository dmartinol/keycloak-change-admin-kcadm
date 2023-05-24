#!/bin/bash

# TODO: Check/handle connection/credentials to Keycloak.
# TODO: Test with HTTPS.
# TODO: Parse realm name from JSON file content or from JSON filename.
# TODO: Refactor kcadm.sh commands to variables.
# TODO: Refactor script to use env vars for keycloack server and credentials.
# TODO: Add error handling for the execution of the command

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="${SCRIPT_DIR}/demo"

KEYCLOAK_BIN="/opt/keycloak/bin/kcadm.sh"
REALM_NAME="heroes"
REALM_JSON_FILE="${DEMO_DIR}/realm.json"

info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
}

error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

set_keycloak_credentials() {
  $KEYCLOAK_BIN config credentials --server https://test-keycloak.apps.ocp-dev01.lab.eng.tlv2.redhat.com --realm master --user admin --password aa1d2c4704494ecdb5451fd660c9f218
  local exit_code=$?
  if (( $exit_code != 0 )); then
    exit 1
  fi
}

create_realm () {
  info "Realm '$REALM_NAME' does not exist. Creating realm..."
  "$KEYCLOAK_BIN" create realms -f "$REALM_JSON_FILE"
}

update_realm() {
  info "Realm '$REALM_NAME' already exists. Updating realm..."
  "$KEYCLOAK_BIN" update realms/$REALM_NAME -f "$REALM_JSON_FILE"
}

process_realm() {
  $KEYCLOAK_BIN get realms/$REALM_NAME > /dev/null 2>&1

  if (( $? != 0 )); then
    create_realm
  else
    update_realm
  fi
}

process_clients() {
for file in ${DEMO_DIR}/clients/*.json; do
  local CLIENT_JSON_FILE=$(realpath "$file")
  local clientID=$(jq -r '.clientId' $CLIENT_JSON_FILE)
  info "Processing file $CLIENT_JSON_FILE with ClientID: $clientID"
  id=$($KEYCLOAK_BIN get clients -r $REALM_NAME --fields id,clientId | jq -r --arg clientID $clientID '.[] | select(.clientId == $clientID) | .id')
  if [[ -n "$id" ]]; then
    update_client "$id" "$CLIENT_JSON_FILE"
  else
    create_client "$CLIENT_JSON_FILE"
  fi
done
}

update_client() {
  local clientID="$1"
  local fileName="$2"
  info "Updating client $clientID"
  "$KEYCLOAK_BIN" update clients/$clientID -r $REALM_NAME -f "$fileName"
}

create_client() {
  local fileName="$1"
  info "Creating client $clientID"
  "$KEYCLOAK_BIN" create clients -r $REALM_NAME -f "$fileName"
}

set_keycloak_credentials
process_realm
process_clients
