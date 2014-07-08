define jenkins::job(
	$name,
	$config_file,
	$host = "localhost",
	$port = "9090"
) {
	$jenkins_url = "http://${host}:${port}"

	exec { "arsnova-jenkins-job-${name}":
		require => Service["jenkins"],
		command => "/usr/bin/test `curl -X POST -H 'Content-Type: application/xml' -d @${config_file} -s -o /dev/null -w '%{http_code}' ${jenkins_url}/createItem?name=${name}` = 200",
		onlyif => "/usr/bin/test `curl -s -o /dev/null -I -w '%{http_code}' -m 5 ${jenkins_url}/job/${name}/` != 200",
		tries => 5,
		try_sleep => 5
	}
}
