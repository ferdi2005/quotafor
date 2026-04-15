# config valid for current version and patch releases of Capistrano
lock "~> 3.20.0"

set :application, "quotafor"
set :repo_url,    "git@github.com:ferdi2005/quotafor.git"
set :user,        "deploy"
set :branch,      :main

set :deploy_to,   "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :keep_releases, 5

# SSH
set :pty,         true
set :use_sudo,    false
set :deploy_via,  :remote_cache
set :ssh_options, { forward_agent: true, user: fetch(:user), keys: %w[~/.ssh/id_rsa.pub] }

set :rvm_ruby_version, File.read(".ruby-version").strip
set :nvm_type, :user
set :nvm_node, File.read(".nvmrc").strip
set :nvm_map_bins, %w[node npm yarn bundle rake rails]
# jemalloc
set :default_env, { "LD_PRELOAD" => "/usr/lib/x86_64-linux-gnu/libjemalloc.so.2" }


# Bundler
set :bundle_flags, "--without development test"

# Puma
set :puma_threads,          [ 4, 16 ]
set :puma_workers,          0
set :puma_preload_app,      true
set :puma_worker_timeout,   nil
set :puma_phased_restart,   true
set :puma_init_active_record, true
set :puma_user,             fetch(:user)

# Sidekiq
set :sidekiq_config,             "config/sidekiq.yml"
set :sidekiq_user,               fetch(:user)
set :sidekiq_service_unit_user,  :system

# Linked files e dirs (persistono tra i release)
append :linked_files, ".env", "config/puma.rb"
append :linked_dirs,  "log", "tmp/pids", "tmp/sockets", "tmp/cache", "public/uploads", "storage"

namespace :rails do
  desc "Open a Rails console: cap production rails:console"
  task :console do
    server = roles(:app).first
    cmd = "ssh #{fetch(:user)}@#{server.hostname} -p #{server.port || 22} -t " \
          "'cd #{fetch(:deploy_to)}/current && RAILS_ENV=production bundle exec rails console'"
    puts cmd
    exec cmd
  end
end

namespace :deploy do
    namespace :check do
      before :linked_files, :set_master_key do
        on roles(:app), in: :sequence, wait: 10 do
            puts "Uploading .env file..."
            upload! ".env", "#{shared_path}/.env"
        end
      end
    end
end



namespace :deploy do
    namespace :check do
      before :linked_files, :set_master_key do
        on roles(:app), in: :sequence, wait: 10 do
            puts "Uploading config file file..."
            upload! "config/puma.rb", "#{shared_path}/config/puma.rb"
        end
      end
    end
end



# Default branch is :master
set :branch, :main
