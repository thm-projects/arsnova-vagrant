define tomcat7::instance(
	$tomcat_version = "7.0.52",
	$tomcat_path = "/opt/tomcat",
	$tomcat_admin_user = "arsnova",
	$tomcat_admin_pass = "arsnova",
	$as_service = false
) {
	require tomcat7

	validate_bool($as_service)

	$dir = "apache-tomcat-$tomcat_version"
	$file = "$dir.tar.gz"
	$url = "http://archive.apache.org/dist/tomcat/tomcat-7/v$tomcat_version/bin/"
	$start_service = $as_service

	exec { "tomcat7-download-${name}":
		cwd => "/tmp",
		command => "/usr/bin/curl -s -o $file $url$file",
		creates => "/tmp/$file"
	}

	exec { "tomcat7-unpack-${name}":
		cwd => "/tmp",
		command => "/bin/tar xzf $file -C /opt && /bin/mv /opt/$dir $tomcat_path",
		creates => $tomcat_path,
		require => Exec["tomcat7-download-${name}"]
	}

	file { "$tomcat_path":
		owner => "tomcat",
		group => "tomcat",
		recurse => true,
		require => Exec["tomcat7-unpack-${name}"]
	}

	file { "$tomcat_path/conf/tomcat-users.xml":
		content => template("tomcat7/tomcat-users.xml.erb"),
		require => File["$tomcat_path/conf"],
		mode => "600",
		owner => "tomcat",
		group => "tomcat"
	}

	# Copy Tomcat configuration
	file { "$tomcat_path/conf":
		source => "/etc/puppet/files/tomcat/conf",
		recurse => true,
		require => Exec["tomcat7-unpack-${name}"],
		mode => "600",
		owner => "tomcat",
		group => "tomcat"
	}

	if $as_service {
		file{"/etc/init.d/${name}":
			ensure => "file",
			content => template("tomcat7/tomcat.erb"),
			mode => "755",
			require => File["$tomcat_path/conf/tomcat-users.xml"]
		}
		->
		service{"${name}":
			ensure => "running",
			enable => true,
			hasrestart => true,
			hasstatus => false, # init script does not return the right exit code!
			pattern => "org\\.apache\\.catalina\\.startup\\.Bootstrap"
		}
	}
}
