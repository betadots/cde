# @summary A Plan to dipatch several plans.
#
# @param targets
#   The targets to run on.
#
# @param scripts
#   List of plans to applied.
#
plan cde::dispatch (
  TargetSpec $targets,
  Array[Struct[{
    name => String[1],
    type => Enum['plan'],
    args => Optional[Hash],
  }]]   $scripts = [],
) {
  run_plan('facts', 'targets' => $targets)
 
  apply($targets, _catch_errors => false, _run_as => root) {
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

  $scripts.each |$script| {
    case $script['type'] {
      'plan': {
        run_plan($script['name'], $script['args'] + {'targets' => $targets, '_catch_errors' => false, '_run_as' => 'root'})
      }
    }
  }
}
