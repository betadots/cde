# @summary A plan to mount several filesystems via sshfs
#
# @param targets
#   The targets to run on.
#
# @param sshfs_host
#   Destionation for ssh connection, set as default for all specified mounts.
#
# @param sshfs_user
#   Username for the ssh connection, set as default for all specified mounts.
#
# @param mounts
#   List of filesystem mounts.
#
plan cde::mount (
  TargetSpec             $targets,
  Optional[Stdlib::Host] $sshfs_host         = undef,
  Optional[String[1]]    $sshfs_user         = undef,
  Array[Struct[{
    src            => String[1],
    dst            => Stdlib::Absolutepath,
    Optional[host] => Stdlib::Host,
    Optional[user] => String[1],
    
  }]]                    $mounts             = [],
) {
  $mounts.each |Hash $mp| {
    $_mp = {
      host => $sshfs_host,
      user => $sshfs_user,
    } + $mp
 
    if $_mp['user'] and $_mp['host'] {
      out::message("Mounting ${_mp['dst']} from ${_mp['host']}:${_mp['src']}")
 
      apply($targets, _catch_errors => false, _run_as => root) {
        file { $_mp['dst']:
          ensure => directory,
        }
 
        file { '/etc/puppetlabs/code/environments/production':
          ensure => link,
          target => $_mp['dst'],
          force  => true,
        }
 
        package { 'sshfs':
          ensure => installed,
        }
 
        -> mount { $_mp['dst']:
          ensure  => 'mounted',
          device  => "${_mp['user']}@${_mp['host']}:${_mp['src']}",
          fstype  => 'fuse.sshfs',
          options => 'IdentityFile=/root/.ssh/identity,StrictHostKeyChecking=no,_netdev,allow_other',
          remounts => false,
          require  => File[$_mp['dst']],
        }
      }
    }
  }
}
