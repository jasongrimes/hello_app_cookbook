# MySQL username and password for this application
default['hello_app']['db_user'] = 'hello_app'
default['hello_app']['db_name'] = 'hello_app'

# Apache configuration
default['hello_app']['server_name'] = 'hello_app.example.com'
default['hello_app']['docroot'] = '/srv/hello_app/current'

# Directory in which application config files should be stored
default['hello_app']['config_dir'] = '/srv/hello_app/shared/config'

# Deployment settings
default['hello_app']['deploy_dir'] = '/srv/hello_app'
#default['hello_app']['deploy_repo'] = 'git@github.com:jasongrimes/hello_app' # Format for private repos
default['hello_app']['deploy_repo'] = 'git://github.com/jasongrimes/hello_app' # Format for public repos
default['hello_app']['deploy_branch'] = 'HEAD'

