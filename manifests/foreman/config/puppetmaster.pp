define puppet::foreman::config::puppetmaster(
  $foreman_url = undef,
  $ssl_ca = undef,
  $ssl_cert = undef,
  $ssl_key = undef,
  $foreman_user = undef,
  $foreman_password = undef,
  $puppet_home = '/var/lib/puppet',
  $puppet_user = 'puppet',
  $facts = true) {

  include puppet

  if $foreman_url == undef {
    fail("Reporting::Foreman::Config::Puppetmaster[$foreman_url]: foreman_url must be defined")
  }

  if $foreman_url !~ /^https?:\/\/.*$/ {
    fail("Reporting::Foreman::Config::Puppetmaster[$foreman_url]: foreman_url must be a valid URL")
  }

  file { '/etc/puppet/foreman.yaml':
    ensure  => file,
    owner   => $puppet_user,
    group   => $puppet_user,
    mode    => '0440',
    content => template("${module_name}/foreman/etc/foreman.yaml.erb")
  }

  case $operatingsystemmajrelease {
    6: { $report_location = '/usr/lib/ruby/site_ruby/1.8/puppet/reports' }
    7: { $report_location = '/usr/share/ruby/vendor_ruby/puppet/reports/' }
  }

  file { "${report_location}/foreman.rb":
    ensure  => file,
    owner   => $puppet_user,
    group   => $puppet_user,
    mode    => '0644',
    source  => "puppet:///modules/${module_name}/foreman.rb",
    notify  => Service['puppet']
  }

  file { '/usr/local/scripts/push_facts_to_foreman.rb':
    ensure  => file,
    owner   => $puppet_user,
    group   => $puppet_user,
    mode    => '0755',
    source  => "puppet:///modules/${module_name}/push_facts_to_foreman.rb"
  }

  cron { 'push_facts_to_foreman':
    command => 'sudo -u puppet /usr/local/scripts/push_facts_to_foreman.rb --push-facts-parallel',
    user    => root,
    hour    => 2,
    minute  => 0,
    require => File['/usr/local/scripts/push_facts_to_foreman.rb']
  }

}
