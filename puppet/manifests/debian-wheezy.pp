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

$sencha_version = "4.0.3.74"
$sencha_cmd_download = "http://cdn.sencha.com/cmd/$sencha_version/SenchaCmd-$sencha_version-linux-x64.run.zip"
$sencha_cmd_install = "SenchaCmd-$sencha_version-linux-x64.run"
$sencha_path = "/usr/local/bin/Sencha/Cmd/$sencha_version"
exec { "install-sencha-cmd":
	cwd => "/tmp",
	command => "/usr/bin/curl -s -o sencha-cmd.zip $sencha_cmd_download \
			&& /usr/bin/unzip -q sencha-cmd.zip \
			&& chmod o+x $sencha_cmd_install \
			&& ./$sencha_cmd_install --mode unattended --prefix /usr/local/bin",
	creates => "$sencha_path/sencha",
	require => Package["unzip"]
}

file { "/usr/local/bin/sencha":
	ensure => "link",
	target => "$sencha_path/sencha",
	require => Exec["install-sencha-cmd"]
}

#
# Work in Progress:
#
# - Ensure arsnova.properties is present
# - Start CouchDB service
# - Initialize Setup Tool
# - Install ARSnova into /vagrant instead of /opt
#

exec { "arsnova-war-checkout":
	cwd => "/opt",
	command => "/usr/bin/git clone git://scm.thm.de/arsnova/arsnova-war",
	require => Package["git"],
	creates => "/opt/arsnova-war"
}

file { "/opt/arsnova-war":
	owner => "vagrant",
	group => "vagrant",
	recurse => true,
	require => Exec["arsnova-war-checkout"]
}

exec { "arsnova-war-install":
	cwd => "/opt/arsnova-war",
	user => "vagrant",
	command => "/usr/bin/mvn clean install",
	require => Exec["arsnova-war-checkout"]
}

File["/opt/arsnova-war"] -> Exec["arsnova-war-install"]