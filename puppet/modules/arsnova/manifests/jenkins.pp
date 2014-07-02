define jenkins::job(
	$name,
	$config_file,
	$host = "localhost",
	$port = "9090"
) {
	$jenkins_url = "http://${host}:${port}"

	exec { "arsnova-jenkins-job-${name}":
		require => Service["jenkins"],
		command => "/usr/bin/curl -X POST -H 'Content-Type: application/xml' -d @${config_file} -s -o /dev/null -w '%{http_code}' ${jenkins_url}/createItem?name=${name}",
		unless => "/usr/bin/test `curl -s -o /dev/null -I -w '%{http_code}' -m 5 ${jenkins_url}/job/${name}/` = 200",
		tries => 5,
		try_sleep => 5,
		returns => 200
	}
}
