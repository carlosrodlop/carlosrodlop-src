FROM osixia/openldap

LABEL maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

ENV LDAP_ORGANISATION="Acme" \
    LDAP_DOMAIN="shihadeh.intern" \
    DATA_VERSION="v3" \
    IMAGE_ROOT_PATH=docker/ooldap.debian

COPY ${IMAGE_ROOT_PATH}/data.${DATA_VERSION}.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif