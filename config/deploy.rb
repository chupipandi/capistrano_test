set :application, 'capistrano_test'
set :deploy_to,   "/var/www/#{fetch(:application)}"

set :nginx_server_name, 'capistrano.chupipandi.pw'
set :nginx_config_name, 'capistrano_test'

set :rvm_path,         '~/.rvm'
set :rvm_default_path, '~.rvm'
set :rvm_ruby_version, '2.1.2@capistranoTest'
set :rvm_type,         :user

server 'chupipandi.pw', user: 'www-data', roles: %w(web app db assets)

set :repo_url,     'git@github.com:chupipandi/capistrano_test'
set :copy_exclude, %w(.git .gitignore)
set :scm,          :git
set :use_sudo,     false

set :linked_files, %w(config/database.yml)
set :linked_dirs,  %w(bin)

set :keep_releases, 2

set :normalize_asset_timestamps, false

set :pty, true

namespace :deploy do
  task :migrate do
    on primary(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, 'exec rake db:migrate'
        end
      end
    end
  end

  namespace :assets do
    task :precompile do
      on roles(:web) do
        within release_path do
          with rails_env: fetch(:rails_env) do
            execute :bundle, 'exec rake assets:precompile'
          end
        end
      end
    end
  end

  after   :updated,            'deploy:assets:precompile'
  after   :updated,            'deploy:migrate'
  before  :finishing,          'puma:restart'
  before  :finishing,          'deploy:cleanup'
end