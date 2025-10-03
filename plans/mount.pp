# @summary A plan created with bolt plan new.
#
# @param targets The targets to run on.
#
plan cde::mount (
  TargetSpec             $targets            = 'localhost',
  Optional[String[1]]    $sshfs_user         = undef,
  Optional[Stdlib::Host] $sshfs_host         = undef,
  Array[Struct[{
    src            => String[1],
    dst            => Stdlib::Absolutepath,
    Optional[host] => Stdlib::Host,
    Optional[user] => String[1],

  }]]                    $mounts             = [],
) {
  apply($targets, _catch_errors => false, _run_as => root) {
    Exec {
      path => ['/usr/bin'],
    }

    package { 'sshfs':
      ensure => installed,
    }
    -> file { '/root/.ssh':
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0700',
    }
    -> exec { 'install private key for identity':
      command => 'install -o root -g root -m600 /tmp/identity /root/.ssh/ && rm /tmp/identity',
      onlyif  => 'stat /tmp/identity',
    }

    $mounts.each |Hash $mp| {
      $_mp = {
        host => $sshfs_host,
        user => $sshfs_user,
      } + $mp

      if $_mp['user'] and $_mp['host'] {
        exec { "create directory for mount point ${_mp['dst']}":
          command => "mkdir -p ${_mp['dst']}",
          unless  => "stat ${_mp['dst']}",
        }
        -> mount { $_mp['dst']:
          ensure  => 'mounted',
          device  => "${_mp['user']}@${_mp['host']}:${_mp['src']}",
          fstype  => 'fuse.sshfs',
          options => 'IdentityFile=/root/.ssh/identity,StrictHostKeyChecking=no,_netdev,allow_other',
          remounts => false,
          require  => Exec['install private key for identity'],
        }
      }
    }
  }
}
