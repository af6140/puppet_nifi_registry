# == Class nifi_registry::install
#
# This class is called from nifi_registry for install.
#
class nifi_registry::install {

  if $::nifi_registry::manage_repo {
    yumrepo { 'bintray-nifi-1.5':
      name => 'bintray-nifi-1.5',
      baseurl => 'https://dl.bintray.com/daweiwang/nifi-1.5',
      gpgcheck => false,
      enabled => true,
    }
  }
  group {$::nifi_registry::group:
    ensure => 'present',
  }
  -> user {$::nifi_registry::user:
    ensure => 'present',
    groups => [$::nifi_registry::user],
  }
  package { $::nifi_registry::package_name:
    ensure => $::nifi_registry::package_version,
    require => User[$::nifi_registry::user],
  }
}
