# https://github.com/rroemhild/docker-test-openldap
# Full tree
ldapsearch -LLL -H ldap://localhost:389 -M -b "dc=planetexpress,dc=com" -D "cn=admin,dc=planetexpress,dc=com" -w "GoodNewsEveryone"
# ou=people
ldapsearch -LLL -H ldap://127.0.0.1:389 -M -b "dc=planetexpress,dc=com" -D "cn=admin,dc=planetexpress,dc=com" -w "GoodNewsEveryone" ou="people"
# professor
ldapsearch -LLL -H ldap://127.0.0.1:389 -M -b "dc=planetexpress,dc=com" -D "cn=admin,dc=planetexpress,dc=com" -w "GoodNewsEveryone" uid="zoidberg"
ldapsearch -LLL -H ldap://127.0.0.1:389 -M -b "dc=planetexpress,dc=com" -D "cn=admin,dc=planetexpress,dc=com" -w "GoodNewsEveryone" cn="admin_staff"
