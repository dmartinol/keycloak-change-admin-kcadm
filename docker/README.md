# Minimal Docker image with kcadm.sh script

Build and push the image after downloading the cluster certificate from the Keycloak cluster:
```bash
oc get -n openshift-ingress-operator secret router-ca -o jsonpath="{.data.tls\.crt}" | base64 -d > ca-bundle.crt
docker build -t quay.io/dmartino/kcadm:latest .
docker login quay.io
docker push quay.io/dmartino/kcadm:latest
```

Run the container and enter terminal mode:
```bash
docker run --rm -it --network host quay.io/dmartino/kcadm:latest
```

Sample commands to connect to remote Keycloak and get realm `external` from the server at `http://localhost:8280` (see [guide](https://www.keycloak.org/docs/latest/server_admin/#using-the-admin-cli)):
```bash
./kcadm.sh config credentials --server http://host.docker.internal:8280 \
--realm master --user admin --client admin-cli
./kcadm.sh get realms/external
```