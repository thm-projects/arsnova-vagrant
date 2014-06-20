class senchacmd {
  package { "unzip": ensure => "latest" }

  $sencha_version = "4.0.4.84"
  $sencha_cmd_download = "http://cdn.sencha.com/cmd/$sencha_version/SenchaCmd-$sencha_version-linux-x64.run.zip"
  $sencha_cmd_install = "SenchaCmd-$sencha_version-linux-x64.run"
  $sencha_path = "/usr/local/bin/Sencha/Cmd/$sencha_version"
  exec { "install-sencha-cmd":
    cwd => "/tmp",
    command => "/usr/bin/curl -s -o sencha-cmd.zip $sencha_cmd_download \
        && /usr/bin/unzip -q sencha-cmd.zip \
        && chmod u+x $sencha_cmd_install \
        && ./$sencha_cmd_install --mode unattended --prefix /usr/local/bin",
    creates => "$sencha_path/sencha",
    require => [ Package["unzip"], File["/usr/local/bin"] ],
    user => $git_owner,
    timeout => "0"
  }

  # Make Sencha Cmd available in PATH
  file { "/etc/profile.d/senchacmd.sh":
    content => template("senchacmd/senchacmd.sh.erb")
  }
}
