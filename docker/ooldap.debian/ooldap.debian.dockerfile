FROM osixia/openldap:1.5.0

LABEL maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

ENV LDAP_ORGANISATION="Acme Org" \
    LDAP_DOMAIN="acme.org" \
    LDAP_ADMIN_PASSWORD="admin" \
    LDAP_BASE_DN="dc=acme,dc=org" \
    DATA_VERSION="v3" \
    IMAGE_ROOT_PATH=docker/ooldap.debian

COPY ${IMAGE_ROOT_PATH}/data.${DATA_VERSION}.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif