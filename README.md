# Keycloak change management via kcadm.sh

## Сontainer preparation

```shell
docker run --name kcm -d -p 8080:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin quay.io/keycloak/keycloak:21.1.1 start-dev
docker exec -it kcm bash

docker run --rm --volume=${PWD}:/home/default/kcm --network host quay.io/dmartino/kcadm:latest /home/default/kcm/kcm.sh

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

## Bash script for realm management

The source code available in [kcm.sh](./kcm.sh)
