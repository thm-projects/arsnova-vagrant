class tomcat7 (
	$tomcat_version = "7.0.52",
	$tomcat_path = "/opt/tomcat",
	$tomcat_admin_user = "arsnova",
	$tomcat_admin_pass = "arsnova",
	$tomcat_server_id = "arsnova",
	$tomcat_root_context = "arsnova-war"
) {

	$dir = "apache-tomcat-$tomcat_version"
	$file = "$dir.tar.gz"
	$url = "http://archive.apache.org/dist/tomcat/tomcat-7/v$tomcat_version/bin/"

	exec { "tomcat7-download":
		cwd => "/tmp",
		command => "/usr/bin/curl -s -o $file $url$file && /bin/tar xzf $file -C /opt && /bin/mv /opt/$dir $tomcat_path",
		creates => $tomcat_path
	}

	file { "$tomcat_path":
		owner => "vagrant",
		group => "vagrant",
		recurse => true,
		require => Exec["tomcat7-download"]
	}

	file { "$tomcat_path/conf/tomcat-users.xml":
		content => template("tomcat7/tomcat-users.xml.erb"),
		require => File["$tomcat_path"],
		owner => "vagrant",
		group => "vagrant"
	}

	file_line { "tomcat-root-context":
		path => "$tomcat_path/conf/server.xml",
		match => "\\s*</Host>",
		line => "<Context path=\"\" docBase=\"$tomcat_root_context\">\n<WatchedResource>WEB-INF/web.xml</WatchedResource>\n</Context>\n</Host>",
		require => File["$tomcat_path"]
	}

	file { "/home/vagrant/.m2":
		ensure => "directory",
		require => Package["maven"],
		owner => "vagrant",
		group => "vagrant"
	}

	file { "/home/vagrant/.m2/settings.xml":
		content => template("tomcat7/settings.xml.erb"),
		require => [ Package["maven"], File["/home/vagrant/.m2"] ],
		owner => "vagrant",
		group => "vagrant"
	}

	exec { "tomcat7-executable":
		cwd => "$tomcat_path/bin",
		command => "/bin/chmod u+x catalina.sh",
		unless => "/bin/sh -c '[ $(/usr/bin/stat -c %a catalina.sh) == 755 ]'",
		require => File["$tomcat_path"]
	}
}
