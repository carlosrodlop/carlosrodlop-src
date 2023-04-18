FROM osixia/openldap

LABEL maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

ENV LDAP_ORGANISATION="Acme Consulting Ltd." \
    LDAP_DOMAIN="acme.org"

COPY bootstrap.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif