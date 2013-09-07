class gitolite (
  $source        = $::gitolite::params::source,
  $version       = $::gitolite::params::version,
  $gitolite_user = $::gitolite::params::gitolite_user,
  $gitolite_home = $::gitolite::params::gitolite_home
) inherits gitolite::params {

  $gitolite_src  = "${gitolite_home}/gitolite"
  $gitolite_cmd  = "${gitolite_src}/install -ln ${gitolite_home}/bin"

  vcsrepo { $gitolite_src:
    provider => 'git',
    ensure   => present,
    source   => $source,
    revision => $version,
    owner    => $gitolite_user,
    group    => $gitolite_user,
    notify   => Exec['gitolite/install'],
  }

  exec { 'gitolite/install':
    command     => $gitolite_cmd,
    cwd         => $gitolite_src,
    user        => $gitolite_user,
    group       => $gitolite_user,
    logoutput   => "on_failure",
    refreshonly => true,
    require     => Vcsrepo[$gitolite_src],
    notify      => Exec['gitolite_setup'],
  }

  exec { 'gitolite_setup':
    require     => Exec['gitolite/install'],
    environment => [
      "HOME=${gitolite_home}",
      "USER=${gitolite_user}",
    ],
    command     => "gitolite setup -pk ${gitolite_home}/.ssh/id_rsa.pub",
    cwd         => $gitolite_home,
    user        => $gitolite_user,
    group       => $gitolite_user,
    logoutput   => 'on_failure',
    path        => ["${gitolite_home}/bin", '/bin', '/usr/bin'],
    refreshonly => true,
  }

}
