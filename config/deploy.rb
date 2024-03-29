# config valid for current version and patch releases of Capistrano
lock "~> 3.17.0"

DEPLOY_CONFIG = YAML.load(File.open('config/deploy_config.yml'))

set :application, DEPLOY_CONFIG['application']
set :repo_url,    DEPLOY_CONFIG['repository']

set :rvm_type, :system
set :rvm_ruby_version, 'ruby-3.0.2'

set :passenger_restart_with_touch, true

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :migration_role, :app

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, DEPLOY_CONFIG['linked_files']

# Default value for linked_dirs is []
append :linked_dirs, "log", "storage", "public/system", "tmp/pids", "tmp/cache", "tmp/sockets"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
# set :keep_assets, 2

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
