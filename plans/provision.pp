# @summary A plan created with bolt plan new.
#
# @param targets The targets to run on.
#
plan cde::provision (
  TargetSpec             $targets            = 'localhost',
  Integer[7-8]           $openvox_collection = 8,
  String[1]              $openvox_version    = 'latest',
  Optional[String[1]]    $sshfs_user         = undef,
  Optional[Stdlib::Host] $sshfs_host         = undef,
  String[1]              $sshfs_src          = 'puppetcode',
  Stdlib::Absolutepath   $sshfs_dst          = '/root/puppetcode',
) {
  out::message("Setting up OpenVox ${openvox_collection}")
  run_task('cde::install_agent', $targets, 'collection' => "openvox${openvox_collection}", 'version' => $openvox_version)

  if $sshfs_user and $sshfs_host {
    out::message("Mounting ${sshfs_dst} from ${sshfs_host}:${sshfs_src}")
    apply($targets, _catch_errors => false, _run_as => root) {
      file { $sshfs_dst:
        ensure => directory,
      }
      
      file { '/etc/puppetlabs/code/environments/production':
        ensure => link,
        target => $sshfs_dst,
        force  => true,
      }
      
      package { 'sshfs':
        ensure => installed,
      }
      
      -> mount { $sshfs_dst:
        ensure  => 'mounted',
        device  => "${sshfs_user}@${sshfs_host}:$sshfs_src",
        fstype  => 'fuse.sshfs',
        options => 'IdentityFile=/root/.ssh/identity,StrictHostKeyChecking=no,_netdev,allow_other',
        remounts => false,
        require  => File[$sshfs_dst],
      }    
    }
  }
}
