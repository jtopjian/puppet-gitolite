class gitolite::user (
  $gitolite_user = $::gitolite::params::gitolite_user,
  $gitolite_home = $::gitolite::params::gitolite_home
) inherits ::gitolite::params {

  user { $gitolite_user:
    ensure     => present,
    password   => '*',
    shell      => '/bin/bash',
    home       => $gitolite_home,
    managehome => true,
    comment    => 'git user',
  }

  file { "${gitolite_home}/bin":
    ensure  => directory,
    mode    => '0755',
    owner   => $gitolite_user,
    group   => $gitolite_user,
    require => User[$gitolite_user],
  }

}
