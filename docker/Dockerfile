FROM quay.io/keycloak/keycloak:latest as keycloak

FROM openjdk:11-jre
WORKDIR /opt/keycloak/bin
ARG KEYCLOAK_VERSION=21.1.1

RUN mkdir -p /opt/keycloak/bin/client/lib/

RUN echo ${KEYCLOAK_VERSION}
COPY --from=keycloak /opt/keycloak/bin/client/keycloak-admin-cli-${KEYCLOAK_VERSION}.jar client
COPY --from=keycloak /opt/keycloak/bin/client/lib/ client/lib/
COPY --from=keycloak /opt/keycloak/bin/kcadm.sh .

RUN chmod +x /opt/keycloak/bin/kcadm.sh

CMD ["bash"]

