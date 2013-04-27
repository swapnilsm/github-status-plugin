Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = "github-status"
  plugin.display_name = "GitHub Status Plugin"
  plugin.version = '0.0.1'
  plugin.description = 'Publish build statuses to GitHub Status API'

  # You should create a wiki-page for your plugin when you publish it, see
  # https://wiki.jenkins-ci.org/display/JENKINS/Hosting+Plugins#HostingPlugins-AddingaWikipage
  # This line makes sure it's listed in your POM.
  plugin.url = 'https://wiki.jenkins-ci.org/display/JENKINS/Github+Status+Plugin'

  # The first argument is your user name for jenkins-ci.org.
  plugin.developed_by "thomasvandoren", "Thomas Van Doren <thomas.vandoren@gmail.com>"

  # This specifies where your code is hosted.
  # Alternatives include:
  #  :github => 'myuser/github-status-plugin' (without myuser it defaults to jenkinsci)
  #  :git => 'git://repo.or.cz/github-status-plugin.git'
  #  :svn => 'https://svn.jenkins-ci.org/trunk/hudson/plugins/github-status-plugin'
  plugin.uses_repository :github => "thomasvandoren/github-status-plugin"

  # This is a required dependency for every ruby plugin.
  plugin.depends_on 'ruby-runtime', '0.10'
end
