# Ensure the repository is updated before any package is installed
exec { "apt-update":
	command => "/usr/bin/apt-get update"
}
Exec["apt-update"] -> Package <| |>

# Install required software
package { "unzip": ensure => "latest" }
package { "git": ensure => "latest" }
package { "ant": ensure => "latest" }
package { "maven": ensure => "latest" }
package { "couchdb": ensure => "latest" }
package { "openjdk-7-jdk": ensure => "latest" }

file { "/usr/local/bin":
	owner => "vagrant",
	group => "vagrant",
	recurse => true
}

$sencha_version = "4.0.3.74"
$sencha_cmd_download = "http://cdn.sencha.com/cmd/$sencha_version/SenchaCmd-$sencha_version-linux-x64.run.zip"
$sencha_cmd_install = "SenchaCmd-$sencha_version-linux-x64.run"
$sencha_path = "/usr/local/bin/Sencha/Cmd/$sencha_version"
exec { "install-sencha-cmd":
	cwd => "/tmp",
	command => "/usr/bin/curl -s -o sencha-cmd.zip $sencha_cmd_download \
			&& /usr/bin/unzip -q sencha-cmd.zip \
			&& chmod u+x $sencha_cmd_install \
			&& ./$sencha_cmd_install --mode unattended --prefix /usr/local/bin",
	creates => "$sencha_path/sencha",
	require => [ Package["unzip"], File["/usr/local/bin"] ],
	user => "vagrant"
}

file { "/etc/profile.d/senchacmd.sh":
	content => template("senchacmd/senchacmd.sh.erb")
}

service { "couchdb":
	ensure => "running",
	enable => true
}

exec { "checkout-arsnova-war":
	cwd => "/vagrant",
	command => "/usr/bin/git clone git://scm.thm.de/arsnova/arsnova-war.git",
	require => Package["git"],
	user => "vagrant",
	creates => "/vagrant/arsnova-war"
}

exec { "checkout-arsnova-mobile":
	cwd => "/vagrant",
	command => "/usr/bin/git clone git://scm.thm.de/arsnova/arsnova-mobile.git",
	require => Package["git"],
	user => "vagrant",
	creates => "/vagrant/arsnova-mobile"
}

exec { "checkout-arsnova-setuptool":
	cwd => "/vagrant",
	command => "/usr/bin/git clone git://scm.thm.de/arsnova/setuptool.git arsnova-setuptool",
	require => Package["git"],
	user => "vagrant",
	creates => "/vagrant/arsnova-setuptool"
}

file { "/etc/arsnova":
	ensure => "directory"
}

file { "/etc/arsnova/arsnova.properties":
	source => "/vagrant/arsnova-war/src/main/webapp/arsnova.properties.example",
	ensure => "present",
	require => File["/etc/arsnova"]
}

exec { "initialize-couchdb":
	cwd => "/vagrant/arsnova-setuptool",
	command => "/usr/bin/python tool.py",
	require => [ Exec["checkout-arsnova-setuptool"], Service["couchdb"], File["/etc/arsnova/arsnova.properties"] ],
	user => "vagrant"
}

exec { "build-arsnova-war":
	cwd => "/vagrant/arsnova-war",
	user => "vagrant",
	command => "/usr/bin/mvn clean install",
	require => [ Exec["checkout-arsnova-war"], Package["maven"], Exec["build-arsnova-mobile"] ]
}

exec { "build-arsnova-mobile":
	cwd => "/vagrant/arsnova-mobile",
	user => "vagrant",
	command => "/usr/bin/mvn clean install",
	require => [ Exec["checkout-arsnova-mobile"], Exec["install-sencha-cmd"], Package["maven"] ]
}

exec { "start-arsnova-mobile":
	cwd => "/vagrant/arsnova-mobile",
	user => "vagrant",
	command => "/usr/bin/ant sencha:app:watch & echo $! > app.pid",
	require => [ Exec["build-arsnova-mobile"], Package["maven"] ],
	creates => "/vagrant/arsnova-mobile/app.pid"
}

exec { "start-arsnova-war":
	cwd => "/vagrant/arsnova-war",
	user => "vagrant",
	command => "/usr/bin/mvn jetty:run & echo $! > app.pid",
	require => [ Exec["start-arsnova-mobile"], Exec["build-arsnova-war"], Package["maven"] ],
	creates => "/vagrant/arsnova-war/app.pid"
}
