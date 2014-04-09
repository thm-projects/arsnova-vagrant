class arsnova {
  include senchacmd
  include git

  case $environment {
    development: { $sencha_env = "testing" }
    production: { $sencha_env = "production" }
    default: { fail("Unrecognized environment $environment") }
  }

  $base_path = "/vagrant"
  $server_path = "$base_path/arsnova-war"
  $mobile_path = "$base_path/arsnova-mobile"
  $mobile_target = "$mobile_path/src/main/webapp/build/$sencha_env/ARSnova"
  $server_pid = "server.pid"
  $mobile_pid = "mobile.pid"

  package { "maven": ensure => "latest" }
  package { "couchdb": ensure => "latest" }
  package { "openjdk-7-jdk": ensure => "latest" }
  package { "ant": ensure => "latest" }

  service { "couchdb":
    ensure => "running",
    enable => true
  }

  git::repo { "arsnova-war":
    path => $server_path,
    source => "git://scm.thm.de/arsnova/arsnova-war.git",
    owner => "vagrant",
    group => "vagrant"
  }

  git::repo { "arsnova-mobile":
    path => $mobile_path,
    source => "git://scm.thm.de/arsnova/arsnova-mobile.git",
    owner => "vagrant",
    group => "vagrant"
  }

  git::repo { "arsnova-setuptool":
    path => "$base_path/arsnova-setuptool",
    source => "git://scm.thm.de/arsnova/setuptool.git",
    owner => "vagrant",
    group => "vagrant"
  }

  file { "/etc/arsnova":
    ensure => "directory"
  }

  file { "/etc/arsnova/arsnova.properties":
    source => "$server_path/src/main/webapp/arsnova.properties.example",
    ensure => "present",
    require => [ File["/etc/arsnova"], Git::Repo["arsnova-war"] ]
  }

  exec { "initialize-couchdb":
  	cwd => "$base_path/arsnova-setuptool",
  	command => "/usr/bin/python tool.py",
  	require => [ Git::Repo["arsnova-setuptool"], Service["couchdb"], File["/etc/arsnova/arsnova.properties"] ],
  	user => "vagrant"
  }

  file { "/home/vagrant/start.sh":
    owner => "vagrant",
    group => "vagrant",
    content => template("arsnova/start.sh.erb"),
    mode => "744"
  }

  file { "/home/vagrant/stop.sh":
    owner => "vagrant",
    group => "vagrant",
    content => template("arsnova/stop.sh.erb"),
    mode => "744"
  }

  class { "motd":
    template => "arsnova/motd.erb"
  }
}
