define couchdb(
  $config = "/etc/couchdb/local.ini",
  $bind_address = "0.0.0.0"
) {
  package { "python-couchdb": ensure => "latest" }

  file_line { "couchdb-bind_address-${bind_address}":
    path => $config,
    match => ";?bind_address",
    line => "bind_address = $bind_address"
  }
}
