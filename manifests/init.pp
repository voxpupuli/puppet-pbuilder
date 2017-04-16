# pbuilder puppet module
# See README for more infos
#
# Copyright © 2007 Raphaël Pinson <raphink@gmail.com>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Define: pbuilder
#
# This definition provides a pbuilder resource.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
define pbuilder(
  $ensure       = 'present',
  $release      = $lsbdistcodename,
  $arch         = $architecture,
  $methodurl    = undef,
  $debbuildopts = '-b',
  $bindmounts   = undef,
  $rctemplate   = 'pbuilder/pbuilderrc.erb',
) {

  # Include commons (package, group and top level dirs)
  include '::pbuilder::common'

  $script = "${bindir}/pbuilder-${name}"

  # directories
  $_chrootdir           = ${::pbuilder::common::chrootdir}
  $bindir               = '/usr/local/bin'
  $pbuilder_confdir     = "${::pbuilder::common::confdir}/${name}"
  $pbuilder_cachedir    = "${::pbuilder::common::cachedir}/${name}"
  $builddir             = "${pbuilder_cachedir}/build"
  $resultdir            = "${pbuilder_cachedir}/result"
  $aptcachedir          = "${pbuilder_cachedir}/aptcache"

  # conf
  $pbuilderrc  = "${pbuilder_confdir}/pbuilderrc"
  $aptconfdir  = "${pbuilder_confdir}/apt.config"
  $hookdir     = "${pbuilder_confdir}/hooks"

  # base
  $basetgz     = "${_chrootdir}/base_${name}.tgz"

  case $ensure {
    'present': {
      file { [$pbuilder_confdir, $aptconfdir, $hookdir]:
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
      }
      file { [$pbuilder_cachedir, $builddir, $resultdir, $aptcachedir]:
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
      }

      file {$script:
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('pbuilder/script.erb'),
        require => Exec["bindir-${name}"],
      }

      file {$pbuilderrc:
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template($rctemplate),
      }

      # create the pbuilder if it was not created yet
      exec { "create_pbuilder_${name}":
        command => "${script} create",
        creates => $basetgz,
        require => [ Package[pbuilder],
        File[$script], File[$aptconfdir],
        File[$pbuilderrc], File[$builddir], File[$aptcachedir],
        Exec["chrootdir-${name}"]
        ],
      }

      # update the pbuilder if the config changes but only if $basetgz exists
      exec { "update_pbuilder_${name}":
        command     => "${script} update --override-config",
        onlyif      => "/usr/bin/test -f ${basetgz}",
        subscribe   => [ File[$aptconfdir], File[$pbuilderrc] ],
        refreshonly => true,
        require     => [ Package[pbuilder],
        File[$script], File[$aptconfdir],
        File[$pbuilderrc], File[$builddir], File[$aptcachedir],
        Exec["chrootdir-${name}"]
        ],
      }
    }

    'absent': {
      # clean pbuilder to be sure no proc/dev is mounted in $builddir
      exec { "clean_pbuilder_${name}":
        command => "${script} clean",
        onlyif  => "/usr/bin/test -f ${script}",
        require => Package[pbuilder],
      }

      file {
        # remove single files
        [ $script, $pbuilderrc, $basetgz]:
          ensure  => absent,
          require => Exec["clean_pbuilder_${name}"];

        # recursively remove internal directories
        [ $aptconfdir, $builddir, $resultdir, $aptcachedir ]:
          ensure  => absent,
          require => Exec["clean_pbuilder_${name}"],
          recurse => true,
          force   => true;

        # recursively remove containing directories
        [ $pbuilder_confdir, $pbuilder_cachedir ]:
          ensure  => absent,
          require => [ Exec["clean_pbuilder_${name}"],
          File[$script], File[$pbuilderrc],
          File[$aptconfdir],
          File[$builddir], File[$resultdir], File[$aptcachedir]
          ],
          force   => true;
      }
    }

    default: {
      fail "\$value must be one of 'present' or 'absent'."
    }
  }
}

