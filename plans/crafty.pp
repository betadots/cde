# @summary A Plan to setup Docker and OpenVox containers for server, openvoxdb and hdm. 
#
# @param targets
#   The targets to run on.
#
# @param code_dir
#   OpenVox code directory to mount into the required containers.
#
plan cde::crafty (
  TargetSpec           $targets,
  Stdlib::Absolutepath $code_dir = '/etc/puppetlabs/code',
) {
  out::message("Installing OpenVox Server...")
#  run_plan('facts', 'targets' => $targets)
 
  apply($targets, _catch_errors => false, _run_as => root) {
    File {
      ensure  => file,
      require => Vcsrepo['/opt/crafty'],
      notify  => Docker_compose['openvox'],
    }

    include docker::compose
    
    package { 'git':
      ensure => installed,
    }
    
    -> vcsrepo { '/opt/crafty':
      ensure   => present,
      provider => git,
      source   => 'https://github.com/voxpupuli/crafty.git',
      revision => '4bd0ee29d43bfa206069e8aa2ccb9cb7484a854c',
    }
    
    file { '/opt/crafty/openvox/oss/.env':
      content => 'COMPOSE_PROFILES=openvox,hdm',
    }
    
    file { '/opt/crafty/openvox/oss/compose.override.yaml':
      content => inline_template('services:
  openvoxserver:
    environment:
      - OPENVOXSERVER_ENVIRONMENT_TIMEOUT=0
    volumes:
      - <%= @code_dir %>:/etc/puppetlabs/code
  postgres:
    ports:
      - 5432:5432
  hdm:
    environment:
      - SECRET_KEY_BASE=9dea7603c008dec285e4b231602a00b2
    volumes:
      - <%= @code_dir %>:/etc/puppetlabs/code
  webhook:
    volumes:
      - <%= @code_dir %>:/etc/puppetlabs/code'),
    }
    
    docker_compose { 'openvox':
      ensure        => present,
      compose_files => ['/opt/crafty/openvox/oss/compose.yaml', '/opt/crafty/openvox/oss/compose.override.yaml'],
    }
  }
}
