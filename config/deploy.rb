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

# jemalloc
set :default_env, { "LD_PRELOAD" => "/usr/lib/x86_64-linux-gnu/libjemalloc.so.2" }

# Rbenv
set :rbenv_type,     :user
set :rbenv_ruby,     File.read(".ruby-version").strip
set :rbenv_prefix,   "/usr/bin/rbenv exec"
set :rbenv_map_bins, %w[rake gem bundle ruby rails sidekiq]
set :rbenv_roles,    :all

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
append :linked_files, ".env"
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
