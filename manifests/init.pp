class doderby (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'web',

  # end of class arguments
  # ----------------------
  # begin class

) {

  # install derby and generators
  if ! defined(Package['derby']) {
    package { 'derby':
      ensure   => present,
      provider => 'npm',
    }
  }
  if ! defined(Package['generator-derby']) {
    package { 'generator-derby':
      ensure   => present,
      provider => 'npm',
    }
  }

  # no longer required (I think)
  # inserted this hack because npm update -g (run as part of the donodejs install)
  # breaks derby so that /usr/bin/derby returns "No such file or directory"
  # exec { 'doderby-install-hack-after-npm-update-destruction' :
  #   path => '/bin:/usr/bin:/sbin:/usr/sbin',
  #   command => 'npm install -g derby',
  # }

}