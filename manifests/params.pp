# default parameters as provided by the OS
class pbuilder::params {

  case $::osfamily {
    'Debian': {
      $package   = 'pbuilder'
      $confdir   = '/etc/pbuilder'
      $chrootdir = '/var/chroot/pbuilder'
      $cachedir  = '/var/cache/pbuilder'
      $group     = 'pbuilder'
    }
    default: {
      fail( "Module ${module_name} is not supported on ${::osfamily} based system" )
    }
  }
}
