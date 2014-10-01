define config(
  $file = "/etc/arsnova/arsnova.properties",
  $root_url = "http://localhost:8080",
  $sio_ip = "0.0.0.0",
  $sio_port = "10443"
) {
  file_line { "arsnova-root-url":
    path => $file,
    match => "root-url=.*",
    line => "root-url=$root_url"
  }

  file_line { "socket-ip":
    path => $file,
    match => "socketio\\.ip=.*",
    line => "socketio.ip=$sio_ip"
  }

  file_line { "socket-port":
    path => $file,
    match => "socketio\\.port=.*",
    line => "socketio.port=$sio_port"
  }
}
