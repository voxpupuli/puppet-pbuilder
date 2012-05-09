define pbuilder::apt::sources_list (
  $pbuilder_name,
  $ensure='present',
  $source=false,
  $content=false,
  $pbuilder_type='pbuilder'
) {

  if $source {
    file {"/etc/pbuilder/${pbuilder_name}/apt/sources.list.d/${name}.list":
      ensure => $ensure,
      source => $source,
      notify => Exec["update ${pbuilder_type} ${pbuilder_name}"],
    }
  } else {
    file {"/etc/pbuilder/${pbuilder_name}/apt/sources.list.d/${name}.list":
      ensure  => $ensure,
      content => $content,
      notify => Exec["update ${pbuilder_type} ${pbuilder_name}"],
    }
  }
}
