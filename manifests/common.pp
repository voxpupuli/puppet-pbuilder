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


# Class: pbuilder::common
#
# This class is imported from the pbuilder type. It manages generic resources for pbuilder.
#
# Parameters:
#
# Actions:
#   Installs the pbuilder package and UNIX group.
#
# Requires:
#
# Sample Usage:
#   include "pbuilder::common"
#
class pbuilder::common(
  $package   = $pbuilder::params::package,
  $confdir   = $pbuilder::params::confdir,
  $cachedir  = $pbuilder::params::cachedir,
  $chrootdir = $pbuilder::params::chrootdir,
  $group     = $pbuilder::params::group,
) inherits pbuilder::params {
  # validate parameters
  validate_string($package)
  validate_absolute_path($confdir)
  validate_absolute_path($cachedir)
  validate_absolute_path($chrootdir)
  validate_string($group)

  # Call this class from within the pbuilder definition

  package { $package:
    ensure => installed,
  }

  group { $group:
    ensure => present,
    system => true,
  }

  # The directories should be created by the package, but Puppet doesn't know that, so tell it.
  file { $confdir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $cachedir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Package does not create the chroot dir
  file { $chrootdir:
    ensure => directory,
    owner  => 'root',
    group  => $group,
    mode   => '0755',
  }
}

