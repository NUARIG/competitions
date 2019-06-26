# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

DEPLOY_CONFIG = YAML.load(File.open('config/deploy_config.yml'))

set :application, DEPLOY_CONFIG['application']
set :repo_url,    DEPLOY_CONFIG['repository']

# set :linked_files, %w{.env}
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets tmp/setup public/system storage}
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

set :rvm_type, :system
set :rvm_ruby_version, 'ruby-2.6.1'

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
# append :linked_files, "/etc/competitions/database.yml"
set :linked_files, %w{config/master.key}

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
# set :keep_assets, 2

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure


namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      execute :mkdir, '-p', release_path.join('tmp')
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  # task :httpd_graceful do
  #   on roles(:web), in: :sequence, wait: 5 do
  #     execute :sudo, "service httpd graceful"
  #   end
  # end
end



# namespace :deploy do
#   namespace :symlink do
#     task :database_config do
#       on roles(:web) do
#         execute "ln -nfs /etc/arig/competitions/database.yml #{release_path}/config/database.yml"
#       end
#     end
#   end
#   before 'deploy:assets:precompile', 'deploy:symlink:database_config'
# #   after: finishing, 'service:nginx:restart'
# end

# after "deploy:updated", "deploy:migrate"
# after "deploy:migrate", "deploy:httpd_graceful"
# after "deploy:httpd_graceful", "deploy:restart"
after "deploy:finished", "deploy:restart"