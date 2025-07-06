# @summary A Plan to set some csr attribuutes.
#
# @param targets
#   The targets to run on.
#
# @param pp_role
#   Set pp_role.
#
plan cde::csr_attributes (
  TargetSpec         $targets,
  Optional[String]   $pp_role = undef,
) {
  apply($targets, _catch_errors => false, _run_as => root) {
    $extension_requests = delete_undef_values(
      'pp_role' => $pp_role,
    )

    unless empty($extension_requests) {
      file { "/etc/puppetlabs/puppet/csr_attributes.yaml":
        ensure  => file,
        content => stdlib::to_yaml({ 'extension_requests' => $extension_requests }),
      }
    }
  }
}
