#!/bin/bash
HOSTNAME=$(hostname -f)
CA_CERT=${CA_CERT-/certs/ca.pem}
CA_KEY=${CA_KEY-/certs/ca-key.pem}
CERT_PATH=/certs/${HOSTNAME}.pem
KEY_PATH=/certs/${HOSTNAME}.key
ADMIN_CERT=/certs/docker-nifiregistry-admin.pem
ADMIN_KEY=/certs/docker-nifiregistry-admin.key
SRC_MODULE=${SRC_MODULE-/modules}
MODULES_DIR=/etc/puppet/modules
LDAP_SERVER=${LDAP_SERVER-ldap}
LDAP_PORT=${LDAP_PORT-389}
LDAP_BIND_DN=${LDAP_BIND_DN}
LDAP_BIND_PW=${LDAP_BIND_PW}
LDAP_USER_SEARCH_BASE=${LDAP_USER_SEARCH_BASE}
LDAP_USER_OBJECT_CLASS=${LDAP_USER_OBJECT_CLASS}
LDAP_USER_IDENTITY_ATTRIBUTE=${LDAP_USER_IDENTITY_ATTRIBUTE}
LDAP_USER_GROUP_NAME_ATTRIBUTE=${LDAP_USER_GROUP_NAME_ATTRIBUTE}
LDAP_GROUP_SEARCH_BASE=${LDAP_USER_SEARCH_BASE}
LDAP_GROUP_OBJECT_CLASS=${LDAP_GROUP_OBJECT_CLASS}
LDAP_IDENTITY_STRATEGY=${LDAP_IDENTITY_STRATEGY-USE_DN}
LDAP_GROUP_MEMBER_ATTRIBUTE=${LDAP_GROUP_MEMBER_ATTRIBUTE}

# install r10k
gem install r10k

cat << EOF > /root/Puppetfile
mod 'puppetlabs/stdlib', '4.6.0'
mod 'puppetlabs/inifile'
mod 'puppetlabs/concat', '1.2.5'
mod 'puppetlabs/java_ks', '1.4.1'
EOF

cat << EOF > /root/manifest.pp

\$ldap_identity_provider_properties = {
    'authentication_strategy' => 'simple',
    'manager_DN' => '${LDAP_BIND_DN}',
    'manager_password' => '${LDAP_BIND_PW}',
    'referral_strategy' => 'FOLLOW',
    'connect_timeout' => '10 secs',
    'url' => 'ldap://${LDAP_HOST}:${LDAP_PORT}',
    'user_search_base' => '${LDAP_USER_SEARCH_BASE}',
    'user_search_filter' => '',
    'group_search_base' => '${LDAP_GROUP_SEARCH_BASE}',
    'user_group_name_attribute' => '${LDAP_USER_GROUP_NAME_ATTRIBUTE}',
    'identity_strategy' => '${LDAP_IDENTITY_STRATEGY}',

}

\$ldap_user_group_properties = {
    'authentication_strategy' => 'simple',
    'manager_DN' => '${LDAP_BIND_DN}',
    'manager_password' => '${LDAP_BIND_PW}',
    'referral_strategy' => 'FOLLOW',
    'connect_timeout' => '10 secs',
    'url' => 'ldap://${LDAP_HOST}:${LDAP_PORT}',
    'user_search_base' => '${LDAP_USER_SEARCH_BASE}',
    'user_search_filter' => '',
    'group_search_base' => '${LDAP_GROUP_SEARCH_BASE}',
    'user_group_name_attribute' => '${LDAP_USER_GROUP_NAME_ATTRIBUTE}',
    'user_identity_attribute' => '${LDAP_USER_IDENTITY_ATTRIBUTE}',
    'group_search_base' => '${LDAP_GROUP_SEARCH_BASE}',
    'user_object_class' => '${LDAP_USER_OBJECT_CLASS}',
    'group_object_class' => '${LDAP_GROUP_OBJECT_CLASS}',
    'group_search_filter' => '',
    'group_name_attribute' => '${LDAP_GROUP_NAME_ATTRIBUTE}',
    'group_member_attribute' =>'${LDAP_GROUP_MEMBER_ATTRIBUTE}',
}
class {'::nifi_registry':
  config_ssl => true,
  ca_cert_path => '${CA_CERT}',
  server_cert_path => '${CERT_PATH}',
  server_key_path => '${KEY_PATH}',
  initial_admin_identity => 'CN=docker-nifiregistry-admin',
  admin_cert_path => '${ADMIN_CERT}',
  admin_key_path => '${ADMIN_KEY}',
  keystore_pass => 'changeit',
  truststore_pass => 'changeit',
  key_pass => 'changeit',
  min_heap => "512m",
  max_heap => "512m",
  manage_repo => false,
  ldap_identity_provider_properties => \$ldap_identity_provider_properties,
  ldap_user_group_properties => \$ldap_user_group_properties,
  start_service => false,
}
EOF

r10k puppetfile install --puppetfile /root/Puppetfile --moduledir ${MODULES_DIR}
if [ -d ${SRC_MODULE}/nifi_registry ]; then
  cp -r ${SRC_MODULE}/nifi_registry ${MODULES_DIR}/nifi_registry
else
  echo "Cannot find nifi_registry module at ${SRC_MODULE}/nifi_registry"
fi

#lancuh in backgroud, so systemd can run before service start
nohup puppet apply --verbose --parser future --modulepath=${MODULES_DIR} /root/manifest.pp > /dev/null 2>&1 &

exec /usr/sbin/init
