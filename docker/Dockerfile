FROM quay.io/ecosystem-appeng/keycloak-source:latest as keycloak

FROM registry.access.redhat.com/ubi9/openjdk-11-runtime
WORKDIR /opt/keycloak/bin
ARG KEYCLOAK_VERSION=21.1.1

USER root
RUN microdnf install -y jq
RUN mkdir -p /opt/keycloak/bin/client/lib/

COPY --from=keycloak /opt/keycloak/bin/client/keycloak-admin-cli-${KEYCLOAK_VERSION}.jar client
COPY --from=keycloak /opt/keycloak/bin/client/lib/ client/lib/
COPY --from=keycloak /opt/keycloak/bin/kcadm.sh .

RUN chmod +x /opt/keycloak/bin/kcadm.sh

USER 185
CMD ["bash"]

