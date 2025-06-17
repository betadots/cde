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
  }]]                 $scripts = [],
) {
  run_plan('facts', 'targets' => $targets)
 
  $scripts.each |$script| {
    case $script['type'] {
      'plan': {
        run_plan($script['name'], $script['args'] + {'targets' => $targets, '_catch_errors' => false, '_run_as' => 'root'})
      }
    }
  }
}
