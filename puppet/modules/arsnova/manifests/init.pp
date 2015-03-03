class arsnova {
  include senchacmd
  include git
  if $environment == "production" {
    include tomcat7
  }

  $base_path = "/vagrant"
  $server_path = "$base_path/arsnova-backend"
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
  package { "ant": ensure => "latest" }
  package { "ruby-dev": ensure => "latest" }
  package { "listen": ensure => "latest", provider => "gem" }

  service { "couchdb":
    ensure => "running",
    enable => true,
    require => Package["couchdb"]
  }

  git::repo { "arsnova-backend":
    path => $server_path,
    source => "https://github.com/thm-projects/arsnova-backend.git",
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
    source => "https://github.com/thm-projects/arsnova-setuptool.git",
    owner => "vagrant",
    group => "vagrant"
  }

  file { "/etc/arsnova":
    ensure => "directory"
  }

  file { "/etc/arsnova/arsnova.properties":
    source => "$server_path/src/main/resources/arsnova.properties.example",
    ensure => "present",
    require => [ File["/etc/arsnova"], Git::Repo["arsnova-backend"] ]
  }

  config { "arsnova-config":
    file => "/etc/arsnova/arsnova.properties",
    sio_ip => $socketio_ip,
    sio_port => $socketio_port,
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

  if $environment == "production" {
    package { "apache2": ensure => "latest" }
    package { "libapache2-mod-jk": ensure => "latest" }
    package { "openjdk-7-jdk": ensure => "latest" }

    service { "apache2":
      ensure => "running",
      enable => "true",
      require => Package["apache2"]
    }

    exec { "arsnova-apache-modules":
      command => "/usr/sbin/a2enmod proxy proxy_ajp proxy_http headers jk status ssl mime rewrite",
      require => [ Package["apache2"], Package["libapache2-mod-jk"] ],
      notify => Service["apache2"]
    }

    file { "/etc/apache2/workers.properties":
      source => "/etc/puppet/files/apache/workers.properties"
    }

    file { "/etc/apache2/mods-available/jk.conf":
      source => "/etc/puppet/files/apache/jk.conf",
      require => Exec["arsnova-apache-modules"]
    }
    ->
    file { "/etc/apache2/mods-enabled/jk.conf":
      ensure => "link",
      target => "/etc/apache2/mods-available/jk.conf",
      notify => Service["apache2"]
    }

    # Initialize Apache sites-enabled
    file { "arsnova-sites-available":
      path => "/etc/apache2/sites-enabled",
      source => "/etc/puppet/files/apache/sites",
      recurse => true,
      require => Package["apache2"],
      notify => Service["apache2"]
    }

    # Copy Apache configuration
    file { "arsnova-apache-conf":
      path => "/etc/apache2/apache2.conf",
      source => "/etc/puppet/files/apache/apache2.conf",
      notify => Service["apache2"]
    }
    file { "/etc/apache2/httpd.conf":
      source => "/etc/puppet/files/apache/httpd.conf",
      notify => Service["apache2"]
    }

    # Tomcat
    tomcat7::instance { "tomcat1":
      tomcat_path => "/opt/tomcat1"
    }
    tomcat7::instance { "tomcat2":
      tomcat_path => "/opt/tomcat2",
      as_service => true
    }
  } else {
    class { "nodejs":
      version => "stable"
    }

    package { "grunt-cli": provider => "npm", require => Class["nodejs"] }

    class { 'sonarqube': }

    class { "jenkins":
      config_hash => {
        "HTTP_PORT" => { "value" => "9090" },
        "AJP_PORT" => { "value" => "9009" }
      },
      plugin_hash => {
        "git-client" => {},
        "scm-api" => {},
        "git" => {},
        "clone-workspace-scm" => {},
        "deploy" => {},
        "disk-usage" => {},
        "build-blocker-plugin" => {},
        "log-parser" => {},
        "sonar" => {},
        "dashboard-view" => {},
        "jquery" => {},
        "parameterized-trigger" => {},
        "build-pipeline-plugin" => {}
      }
    }

    jenkins::job { "arsnova-jenkins-job-mobile":
      name => "ARSnova-Mobile",
      config_file => "/etc/puppet/files/jenkins/arsnova-mobile.config.xml"
    }

    jenkins::job { "arsnova-jenkins-job-mobile-deploy":
      name => "ARSnova-Mobile.deploy",
      config_file => "/etc/puppet/files/jenkins/arsnova-mobile-deploy.config.xml"
    }

    jenkins::job { "arsnova-jenkins-job-backend":
      name => "ARSnova-Backend",
      config_file => "/etc/puppet/files/jenkins/arsnova-backend.config.xml"
    }

    jenkins::job { "arsnova-jenkins-job-backend-deploy":
      name => "ARSnova-Backend.deploy",
      config_file => "/etc/puppet/files/jenkins/arsnova-backend-deploy.config.xml"
    }

    jenkins::job { "arsnova-jenkins-job-backend-sonar":
      name => "ARSnova-Backend.sonar",
      config_file => "/etc/puppet/files/jenkins/arsnova-backend-sonar.config.xml"
    }

    # Jenkins might be installed to different paths depending on OS
    $jenkins_home = $::osfamily ? {
      "Debian" => "/var/lib/jenkins",
      default => fail("Unsupported OS family: ${::osfamily}")
    }

    file { "${jenkins_home}/hudson.tasks.Maven.xml":
      require => Class["jenkins::package"],
      source => "/etc/puppet/files/jenkins/hudson.tasks.Maven.xml",
      notify => Service["jenkins"]
    }

    file { "${jenkins_home}/hudson.plugins.sonar.SonarPublisher.xml":
      require => Class["jenkins::package"],
      source => "/etc/puppet/files/jenkins/hudson.plugins.sonar.SonarPublisher.xml",
      notify => Service["jenkins"]
    }

    file { ["${jenkins_home}/.sencha", "${jenkins_home}/.sencha/cmd"]:
      ensure => "directory",
      require => [Group["jenkins"], User["jenkins"]]
    }
    ->
    file { "${jenkins_home}/.sencha/cmd/sencha.cfg":
      content => 'repo.local.dir=${home.dir}/../repo',
    }
    ->
    exec { "jenkins-sencha-permissions":
      command => "/bin/chown -R jenkins:jenkins ${jenkins_home}/.sencha"
    }

  }
}
