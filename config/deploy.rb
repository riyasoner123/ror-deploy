# config valid for current version and patch releases of Capistrano
lock "~> 3.18.0"

set :application, "ror-deploy"
set :repo_url, 'https://github.com/riyasoner123/ror-deploy.git'
set :deploy_to, '/home/ubuntu/ror-deploy'
set :use_sudo, false
set :branch, 'main'
set :linked_files, []
set :rails_env, 'production'
set :rbenv_ruby, '3.3.0'

set :keep_releases, 2
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log,  "#{release_path}/log/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  desc 'Start Puma server'
  task :start do
    on roles(:app) do
      within current_path do
        execute :bundle, :exec, :puma, "--config", "#{fetch(:puma_config_file)}", "--daemon"
      end
    end
  end

  before :start, :make_dirs
end
