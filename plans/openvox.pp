# @summary A plan to install and configure an OpenVox agent.
#
# @param targets The targets to run on.
#
plan cde::openvox (
  TargetSpec                     $targets          = 'localhost',
  Integer[7-8]                   $collection       = 8,
  String[1]                      $version          = 'latest',
  Optional[Stdlib::Absolutepath] $prod_environment = undef,
  Optional[Hash]                 $csr_attributes   = undef,
) {
  out::message("Setting up OpenVox ${collection}")
  run_task('openvox_bootstrap::install', $targets, 'collection' => "openvox${collection}", 'version' => $version)
  run_task('openvox_bootstrap::configure', $targets,
    'puppet_service_running' => false,
    'puppet_service_enabled' => false,
    'csr_attributes'         => $csr_attributes,
  )

  if $prod_environment {
    out::message("Linking production environment to ${prod_environment}")
    apply($targets, _catch_errors => false, _run_as => root) {
      file { '/etc/puppetlabs/code/environments/production':
        ensure => link,
        target => $prod_environment,
        force  => true,
      }
    }
  }
}
