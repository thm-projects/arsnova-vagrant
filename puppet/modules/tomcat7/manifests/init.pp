class tomcat7 (
	$tomcat_admin_user = "arsnova",
	$tomcat_admin_pass = "arsnova",
	$tomcat_server_id = "arsnova"
) {
	user { "tomcat":
		ensure => "present"
	}
	group { "tomcat":
		ensure => "present"
	}

	file { "/home/vagrant/.m2":
		ensure => "directory",
		require => Class["maven::maven"],
		owner => "vagrant",
		group => "vagrant"
	}

	file { "/home/vagrant/.m2/settings.xml":
		content => template("tomcat7/settings.xml.erb"),
		require => File["/home/vagrant/.m2"],
		owner => "vagrant",
		group => "vagrant"
	}
}
