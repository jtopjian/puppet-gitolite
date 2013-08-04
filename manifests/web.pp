# This is a pretty sloppy class that doesn't conform to best module
# practices. For example, it install gitweb and highlight, assumes
# a www-user, etc...
#
# However, in the right environment, it's an easy way to get gitweb
# installed and running
#
class gitolite::web (
  $gitolite_user = $::gitolite::params::gitolite_user,
  $gitolite_home = $::gitolite::params::gitolite_home
) {

  # Some basic info
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
