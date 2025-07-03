# @summary A Plan to set the correct domain. Also do a renew of a DHCP request.
#
# @param targets
#   The targets to run on.
#
# @param my_domain
#   The domain name to use.
#
plan cde::dhcp_client (
  TargetSpec $targets,
  String[1]  $my_domain,
) {
  apply($targets, _catch_errors => false, _run_as => root) {
    file_line { 'ipv4 hostname':
      ensure => present,
      path   => '/etc/hosts',
      line   => "127.0.1.1 ${facts['hostname']}.${my_domain} ${facts['hostname']}",
      match  => "^127.*${facts['hostname']}",
    }
    if $facts['networking']['ip6'] {
      file_line { 'ipv6 hostname':
        ensure => present,
        path   => '/etc/hosts',
        line   => "::1 ${facts['hostname']}.${my_domain} ${facts['hostname']}",
        match  => "^::.*${facts['hostname']}",
      }
    }

    case $facts['os']['family'] {
      'debian': {
        $cmd = if $facts['os']['name'] == 'ubuntu' {
          'netplan apply'
        } else {
          'dhclient -r;dhclient'
        }
        exec { 'refresh dhcp lease':
          path => $facts['path'],
          command => $cmd,
        }
      }
      'redhat': {
        file { '/etc/NetworkManager/conf.d/99-cloud-init.conf':
          ensure => absent,
          notify => Service['NetworkManager'],
        }
        file { '/etc/NetworkManager/system-connections/cloud-init-eth0.nmconnection':
          ensure => file,
          mode   => '0600',
        }
        -> file_line { 'remove dns entries':
          ensure            => 'absent',
          path              => '/etc/NetworkManager/system-connections/cloud-init-eth0.nmconnection',
          match             => '^dns',
          match_for_absence => true,
          multiple          => true,
        }
        ~> service { 'NetworkManager':
          ensure => running,
        }
      }
      default: {}
    }
  }
}
