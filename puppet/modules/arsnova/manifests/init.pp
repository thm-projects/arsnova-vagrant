class arsnova {
  include senchacmd
  include git
  if $environment == "production" {
    include tomcat7
  }

  $base_path = "/vagrant"
  $server_path = "$base_path/arsnova-war"
  $mobile_path = "$base_path/arsnova-mobile"
  $server_pid = "server.pid"
  $mobile_pid = "mobile.pid"
  $listen_pid = "listen.pid"

  case $environment {
    development: {
      $deploy_path = $server_path
      $sencha_env = "testing"
      $socketio_ip = "0.0.0.0"
      $socketio_port = "10443"
    }
    production: {
      $deploy_path = "$tomcat7::tomcat_path/bin"
      $sencha_env = "production"
      $socketio_ip = "0.0.0.0"
      $socketio_port = "10444"
    }
    default: { fail("Unrecognized environment $environment") }
  }
  $mobile_target = "$mobile_path/src/main/webapp/build/$sencha_env/ARSnova"

  package { "maven": ensure => "latest" }
  package { "couchdb": ensure => "latest" }
  package { "openjdk-7-jdk": ensure => "latest" }
  package { "ant": ensure => "latest" }
  package { "ruby-dev": ensure => "latest" }
  package { "listen": ensure => "latest", provider => "gem" }

  service { "couchdb":
    ensure => "running",
    enable => true,
    require => Package["couchdb"]
  }

  git::repo { "arsnova-war":
    path => $server_path,
    source => "https://github.com/thm-projects/arsnova-war.git",
    owner => "vagrant",
    group => "vagrant"
  }

  git::repo { "arsnova-mobile":
    path => $mobile_path,
    source => "https://github.com/thm-projects/arsnova-mobile.git",
    owner => "vagrant",
    group => "vagrant"
  }

  git::repo { "arsnova-setuptool":
    path => "$base_path/arsnova-setuptool",
    source => "https://github.com/thm-projects/setuptool.git",
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

  socketio { "socketio-config":
    file => "/etc/arsnova/arsnova.properties",
    ip => $socketio_ip,
    port => $socketio_port,
    require => File["/etc/arsnova/arsnova.properties"]
  }

  couchdb { "couchdb-host-access":
    notify => Service["couchdb"],
  }

  exec { "initialize-couchdb":
    cwd => "$base_path/arsnova-setuptool",
    # CouchDB uses delayed commits, so wait a few seconds to ensure documents are written to disk
    command => "/bin/sleep 5 && /usr/bin/python tool.py && /bin/sleep 5",
    require => [ Git::Repo["arsnova-setuptool"], File["/etc/arsnova/arsnova.properties"], Couchdb["couchdb-host-access"] ],
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

  file { "/home/vagrant/listen.rb":
    owner => "vagrant",
    group => "vagrant",
    content => template("arsnova/listen.rb.erb")
  }

  class { "motd":
    template => "arsnova/motd.erb"
  }

  # Peer-Review WE3 Homework #0
  file { "/home/vagrant/review.sh":
    owner => "vagrant",
    group => "vagrant",
    content => template("arsnova/review.sh.erb"),
    mode => "744"
  }
}
