FROM osixia/openldap

LABEL maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

ENV LDAP_ORGANISATION="Example Ltd." \
    LDAP_DOMAIN="jenkins.org" \
    DATA_VERSION="v2" \
    IMAGE_ROOT_PATH=docker/ooldap.debian

COPY ${IMAGE_ROOT_PATH}/data.${DATA_VERSION}.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif