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

	file { "/home/${git_owner}/.m2":
		ensure => "directory",
		require => Package["maven"],
		owner => $git_owner,
		group => $git_group 
	}

	file { "/home/${git_owner}/.m2/settings.xml":
		content => template("tomcat7/settings.xml.erb"),
		require => [ Package["maven"], File["/home/${git_owner}/.m2"] ],
		owner => $git_owner,
		group => $git_group 
	}
}
