define socketio(
  $file = "/etc/arsnova/arsnova.properties",
  $ip = "0.0.0.0",
  $port = "10443"
) {
  file_line { "socket-ip":
    path => $file,
    match => "socketio\\.ip=.*",
    line => "socketio.ip=$ip"
  }

  file_line { "socket-port":
    path => $file,
    match => "socketio\\.port=.*",
    line => "socketio.port=$port"
  }
}
