#!/bin/bash

# TODO: Check/handle connection/credentials to Keycloak.
# TODO: Test with HTTPS.
# TODO: Parse realm name from JSON file content or from JSON filename.
# TODO: Refactor kcadm.sh commands to variables.
# TODO: Refactor script to use env vars for keycloack server and credentials.
# TODO: Add error handling for the execution of the command

KEYCLOAK_BIN="/opt/keycloak/bin/kcadm.sh"
REALM_NAME="heroes"
REALM_JSON_FILE="/opt/keycloak/bin/realm.json"

info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&1
}

error() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

set_keycloak_credentials() {
  $KEYCLOAK_BIN config credentials --server http://localhost:8080 --realm master --user admin --password admin
  if (( $? != 0 )); then
    info "Credentials setting error"
    exit 1
  fi
}

set_keycloak_credentials

# Check if realm exists
$KEYCLOAK_BIN get realms/$REALM_NAME > /dev/null 2>&1

if (( $? != 0 )); then
  info "Realm '$REALM_NAME' does not exist. Creating realm..."
  "$KEYCLOAK_BIN" create realms -f "$REALM_JSON_FILE"
else
  info "Realm '$REALM_NAME' already exists. Updating realm..."
  "$KEYCLOAK_BIN" update realms/$REALM_NAME -f "$REALM_JSON_FILE"
fi