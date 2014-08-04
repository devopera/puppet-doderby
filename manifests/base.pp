define doderby::base (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',
  $group = 'www-data',
  $port = 3000,
  $app_name = $title,
  $app_script = 'server.js',
  $content = 'derbyjs',

  # install directory
  $target_dir = '/var/www/node',

  $firewall = true,
  $monitor = true,
  
  # create symlink and if so, where
  $symlinkdir = false,

  # end of class arguments
  # ----------------------
  # begin class

) {

  if ($firewall) {
    # open port
    @docommon::fireport { "doderby-node-server-${port}":
      port => $port,
      protocol => 'tcp',
    }
  }

  if ($monitor) {
    # setup monitoring
    @nagios::service { "http_content:${port}-doderby-${::fqdn}":
      # no DNS, so need to refer to machine by external IP address
      check_command => "check_http_port_url_content!${::ipaddress}!${port}!/!'${content}'",
    }
    @nagios::service { "int:process_node-doderby-${::fqdn}":
      check_command => "check_nrpe_procs_node",
    }
  }

  # if we've got a message of the day, include
  @domotd::register { "Derby(${port})" : }

  # check that target dir exists
  if ! defined(File["${target_dir}"]) {
    docommon::stickydir { "${target_dir}":
      user => $user,
      group => $group,
      context => 'httpd_sys_content_t',
      before => [Exec["doderby-base-create-${title}"]],
    }
  }
  # check that app dir exists
  if ! defined(File["${target_dir}/${app_name}"]) {
    docommon::stickydir { "${target_dir}/${app_name}":
      user => $user,
      group => $group,
      context => 'httpd_sys_content_t',
      before => [Exec["doderby-base-create-${title}"]],
    }
  }

  # create and inflate node/express example
  exec { "doderby-base-create-${title}" :
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
    # old-syntax, now deprecated
    # command => "derby new ${target_dir}/${app_name} && cd ${target_dir}/${app_name} && npm install",
    command => "bash -c \"cd ${target_dir}/${app_name} && yo --insight derby\"",
    user => $user,
    group => $group,
    cwd => "/home/${user}",
    # @todo add creates
    # creates => "${target_dir}/${app_name}/something",
  }

  # create service and start on machine startup
  donodejs::foreverservice { "doderby-base-service-${title}":
    app_name => $app_name,
    app_script => $app_script,
    target_dir => $target_dir,
    require => [Exec["doderby-base-create-${title}"]],
  }

  # create symlink from our home folder
  if ($symlinkdir) {
    # create symlink from directory to repo (e.g. user's home folder)
    file { "${symlinkdir}/${app_name}" :
      ensure => 'link',
      target => "${target_dir}/${app_name}",
      require => [Exec["doderby-base-create-${title}"]],
    }
  }

}
