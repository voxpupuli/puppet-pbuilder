# @summary Manage a cowbuilder environment
#
# @param ensure
#   Whether the pbuilder should be present
# @param release
#   The Debian/Ubuntu release to be used (Buster, Bionic, etc)
# @param arch
#   The architecture of the pbuilder (i386, amd64, etc.)
# @param cachedir
#   Where to create the aptcache, build and result directories
# @param confdir
#   Where to store the configuration for the script
# @param methodurl
#   The URL used to grab the packages from
#   (e.g. http://deb.debian.org/debian)
# @param debbuildopts
#   The options to send to debuild (see `man dpkg-buildpackage`)
# @param bindmounts
#   A list of space-separated directories to bind-mount in the chroot
# @param rctemplate
#   The pbuilderrc ERB template to use
define pbuilder::cowbuilder (
  Enum['present', 'absent'] $ensure = 'present',
  String[1] $release = $facts['os']['distro']['codename'],
  String[1] $arch = $facts['os']['architecture'],
  Stdlib::Absolutepath $cachedir = '/var/cache/pbuilder',
  Optional[String[1]] $methodurl = undef,
  String $debbuildopts = '-b',
  Optional[String[1]] $bindmounts = undef,
  Stdlib::Absolutepath $confdir = '/etc/pbuilder',
  String[1] $rctemplate = 'pbuilder/pbuilderrc.erb',
) {
  include pbuilder::cowbuilder::common

  $cowbuilder = '/usr/sbin/cowbuilder'

  # directories
  $pbuilder_confdir     = "${confdir}/${name}"
  $pbuilder_cachedir    = "${cachedir}/${name}"
  $builddir             = "${pbuilder_cachedir}/build"
  $resultdir            = "${pbuilder_cachedir}/result"
  $aptcachedir          = "${pbuilder_cachedir}/aptcache"

  # conf
  $pbuilderrc  = "${pbuilder_confdir}/pbuilderrc"
  $aptconfdir  = "${pbuilder_confdir}/apt.config"
  $hookdir     = "${pbuilder_confdir}/hooks"

  # base
  $basepath = "${cachedir}/base-${name}.cow"

  concat { "${aptconfdir}/preferences":
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['pbuilder'],
  }

  case $ensure {
    'present': {
      file {
        $pbuilder_confdir:
          ensure  => directory,
          require => Package['pbuilder'];

        $pbuilder_cachedir:
          ensure  => directory,
          require => Package['pbuilder'];

        [$builddir, $resultdir, $aptcachedir]:
          ensure  => directory;

        $aptconfdir:
          ensure  => directory;

        "${aptconfdir}/sources.list.d":
          ensure  => directory,
          recurse => true,
          purge   => true;

        $hookdir:
          ensure  => directory,
          recurse => true;

        $pbuilderrc:
          ensure  => file,
          content => template($rctemplate);
      }

      -> exec {
        "create cowbuilder ${name}":
          command     => "${cowbuilder} --create --basepath ${basepath} --dist ${release} --architecture ${arch}",
          environment => ["NAME=${name}"], # used in /etc/pbuilderrc
          require     => File['/etc/pbuilderrc'],
          timeout     => 0,
          creates     => $basepath;

        "update cowbuilder ${name}":
          command     => "${cowbuilder} --update --configfile ${confdir}/${name}/pbuilderrc --basepath ${basepath} --dist ${release} --architecture ${arch} --override-config",
          environment => ["NAME=${name}"], # used in /etc/pbuilderrc
          timeout     => 0,
          refreshonly => true;
      }
    }

    'absent': {
      file {
        $pbuilder_confdir:
          ensure => absent;

        $basepath:
          ensure => absent;
      }
    }

    default: {
      fail("Wrong value for ensure: ${ensure}")
    }
  }
}
