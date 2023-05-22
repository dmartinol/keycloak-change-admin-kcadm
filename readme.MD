# Keycloak change management via kcadm.sh

## Сontainer preparation

```shell
docker run --name kcm -d -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:21.1.1 start-dev
docker exec -it kcm bash
export KEYCLOAK_HOME=/opt/keycloak
export PATH=$PATH:$KEYCLOAK_HOME/bin
kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin --password admin
```

## Scripts for manual testing

### Realm create

```shell
cat <<EOF > realm.json
{
  "realm": "heroes",
  "enabled": true,
  "displayName": "heroes"
}
EOF
```

```shell
kcadm.sh create realms -f realm.json
```

### Realm update

```shell
cat <<EOF > realm.json
{
  "displayName": "heroes updated"
}
EOF
```

We need explicitly pass realm name (investigate)

```shell
kcadm.sh update realms/heroes -f realm.json
```

## Basic script for realm management

The source code available in [kcm.sh](./kcm.sh)

```shell
cat << 'EOF' > /opt/keycloak/bin/kcm.sh
#!/bin/bash

# TODO: Check/handle connection/credentials to Keycloak.
# TODO: Test with HTTPS.
# TODO: Parse realm name from JSON file content or from JSON filename.
# TODO: Refactor kcadm.sh commands to variables.
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
  $KEYCLOAK_BIN config credentials --server http://localhost:8080 --realm master --user admin1 --password admin
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
EOF
```

```shell
chmod +x /opt/keycloak/bin/kcm.sh
./opt/keycloak/bin/kcm.sh
```
