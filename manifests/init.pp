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
  Optional[String] $ca_cert_path = undef,
  Optional[String] $server_cert_path = undef,
  Optional[String] $server_key_path = undef,
  String $keystore_pass = 'changeit',
  String $truststore_pass = 'changeit',
  String $key_pass = 'changeit',
  Integer $http_port = 18080,
  Integer $https_port = 18443,
  String $http_host = $::fqdn,
  Hash $ldap_identity_provider_properties = {},
  Hash $ldap_user_group_properties = {},
  Array $nifi_access_nodes = [],
  Boolean $manage_repo = false,

) inherits ::nifi_registry::params {

  # validate parameters here

  class { '::nifi_registry::install': }
  -> class { '::nifi_registry::config': }
  ~> class { '::nifi_registry::service': }
  -> Class['::nifi_registry']
}
