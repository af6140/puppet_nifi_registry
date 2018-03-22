# Class: nifi_registry
# ===========================
#
# Full description of class nifi_registry here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class nifi_registry (
  String $package_name = $::nifi_registry::params::package_name,
  String $package_version = $::nifi_registry::params::package_version,
  String $service_name = $::nifi_registry::params::service_name,
  String $user = $::nifi_registry::params::user,
  String $group = $::nifi_registry::params::group,
  String $min_heap = '512m',
  String $max_heap = '512m',
  String $conf_dir = '/opt/nifi-registry/conf',
  Boolean $config_ssl = false,
  String $initial_admin_identity = undef,
  String $admin_cert_path = undef,
  String $admin_key_path = undef,
  Optional[Array[Struct[{pattern => String[1], value=>String[1], ensure => Optional[Enum[present,absent]], index => Optional[Integer[0,9]] }],0,9]] $id_mappings = undef,
  Optional[String] $ca_cert_path = undef,
  Optional[String] $server_cert_path = undef,
  Optional[String] $server_key_path = undef,
  String $keystore_pass = 'changeit',
  String $truststore_pass = 'changeit',
  String $key_pass = 'changeit',
  Integer $web_http_port = 18080,
  Integer $web_https_port = 18443,
  String $web_http_host = $::fqdn,
  String $web_https_host = $::fqdn,
  Hash $ldap_identity_provider_properties = {},
  Hash $ldap_user_group_properties = {},
  Array[String] $nifi_access_nodes = [],
  Boolean $manage_repo = false,
  Boolean $start_service = false,
  Boolean $client_auth = false,
) inherits ::nifi_registry::params {

  # validate parameters here

  include '::nifi_registry::install'
  include '::nifi_registry::config'
  include '::nifi_registry::service'

  Class['nifi_registry::install'] -> Class['nifi_registry::config'] ~> Class['nifi_registry::service']
  #-> Class['::nifi_registry']
}
