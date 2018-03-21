# == Class nifi_registry::service
#
# This class is meant to be called from nifi_registry.
# It ensure the service is running.
#
class nifi_registry::service {

  service { $::nifi_registry::service_name:
    ensure     => running,
    enable     => true,
  }
}
