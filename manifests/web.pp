class gitolite::web {

  # Some basic info
  $gitolite_user = hiera('gitolite_user')
  $gitolite_home = hiera('gitolite_home')
  $project_root  = "${gitolite_home}/repositories"
  $projects_list = "${gitolite_home}/projects.list"

  # Required packages
  $packages = ['gitweb', 'highlight']
  package { $packages:
    ensure => latest,
    notify => exec['add www-data to gitolite_user group'],
  }

  # Modify the /etc/gitweb.conf file as needed
  file_line {
    '/etc/gitweb.conf projectroot':
      path  => '/etc/gitweb.conf',
      line  => "\$projectroot = '${project_root}';",
      match => '^\$projectroot =';
    '/etc/gitweb.conf projects_list':
      path  => '/etc/gitweb.conf',
      line  => "\$projects_list = '${projects_list}';";
    '/etc/gitweb.conf highlight':
      path  => '/etc/gitweb.conf',
      line  => "\$feature{'highlight'}{'default'} = [1];";
  }

  # Put the www-data user in the git group
  # This is just plain sloppy
  exec { "add www-data to gitolite_user group":
    unless      => "grep -q '${gitolite_user}\\S*www-data' /etc/group",
    command     => "usermod -aG ${gitolite_user} www-data",
    path        => ['/bin', '/usr/bin', '/usr/sbin'],
    refreshonly => true,
  }

}
