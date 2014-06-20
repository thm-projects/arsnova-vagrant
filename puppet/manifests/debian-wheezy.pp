include arsnova

# Ensure the repository is updated before any package is installed
exec { "apt-update":
  command => "/usr/bin/apt-get update"
}
Exec["apt-update"] -> Package <| |>

# Use Mac style installation folder
file { "/usr/local/bin":
  owner => $git_owner,
  group => $git_group,
  recurse => true
}

# GUI, see https://wiki.debian.org/Xfce
package { "xfce4": ensure => "latest" }
package { "xfce4-goodies": ensure => "latest" }
package { "chromium-browser": ensure => "latest" }
file { "/home/${git_owner}/.xsession":
  owner => $git_owner,
  group => $git_group,
  content => "exec ck-launch-session startxfce4"
}
# Adds multiple lines, but that doesn't seem to be a problem
file_line { "pam":
  path => "/etc/pam.d/common-session",
  match => "session\\s*required\\s*pam_unix.so",
  line => "session required pam_unix.so\nsession optional pam_loginuid.so"
}
# Strangely, bash is not the default...
user { $git_owner:
  ensure => present,
  shell  => "/bin/bash"
}
