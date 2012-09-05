$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Для работы rvm
require 'rvm/capistrano' # Для работы rvm
require 'bundler/capistrano' # Для работы bundler. При изменении гемов bundler автоматически обновит все гемы на сервере, чтобы они в точности соответствовали гемам разработчика. 

set :domain, "gagarin.o7.com" # Это необходимо для деплоя через ssh. Именно ради этого я настоятельно советовал сразу же залить на сервер свой ключ, чтобы не вводить паролей.
set :user, "user"

set :application, "gagarin"
set :rails_env, "production"
set :deploy_to, "/home/#{user}/projects/#{application}"
set :use_sudo, false
set :unicorn_conf, "#{deploy_to}/shared/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"

set :rvm_ruby_string, "1.9.2@#{application}" # Это указание на то, какой Ruby интерпретатор мы будем использовать.

set :rvm_type, :user # Указывает на то, что мы будем использовать rvm, установленный у пользователя, от которого происходит деплой, а не системный rvm.

set :scm, :git # Используем git. Можно, конечно, использовать что-нибудь другое - svn, например, но общая рекомендация для всех кто не использует git - используйте git. 
set :repository,  "git://github.com/gitgash/gagarin.git" # Путь до вашего репозитария. Кстати, забор кода с него происходит уже не от вас, а от сервера, поэтому стоит создать пару rsa ключей на сервере и добавить их в deployment keys в настройках репозитария.
set :branch, "master" # Ветка из которой будем тянуть код для деплоя.

# set :deploy_via, :remote_cache # Указание на то, что стоит хранить кеш репозитария локально и с каждым деплоем лишь подтягивать произведенные изменения. Очень актуально для больших и тяжелых репозитариев.

role :web, domain
role :app, domain
role :db,  domain, :primary => true

after 'deploy:update_code', :roles => :app do
  # Здесь для примера вставлен только один конфиг с приватными данными - database.yml. Обычно для таких вещей создают папку /srv/myapp/shared/config и кладут файлы туда. При каждом деплое создаются ссылки на них в нужные места приложения.
  run "rm -f #{current_release}/config/database.yml"
  run "ln -s #{deploy_to}/shared/config/database.yml #{current_release}/config/database.yml"
  # Создаем симлинк на базу в формате SQLite (пока база вообще не нужна, а уж MySQL тем более).
  run "rm -f #{current_release}/db/production.sqlite3"
  run "ln -s #{deploy_to}/shared/production.sqlite3 #{current_release}/db/production.sqlite3"
end

# Закомментировал, т.к. пришел к выводу, что ассеты лучше компилить локально :)
# after 'deploy:update_code', 'deploy:compile_assets'

# Это дополнение к deploy:setup копирует файлы config/*.exapmle с настройками БД и unicorn-а в shared/config
after 'deploy:setup', :roles => :app do
  run "mkdir -p #{deploy_to}/shared/config"
  run "rm -fr /tmp/#{application}"
  run "git clone #{repository} /tmp/#{application}"
  run "cp /tmp/#{application}/config/database.yml.example #{deploy_to}/shared/config/database.yml"
  run "cp /tmp/#{application}/config/unicorn.rb.example #{unicorn_conf}"
  run "rm -fr /tmp/#{application}"
end

# Далее идут правила для перезапуска unicorn. Их стоит просто принять на веру - они работают.
# В случае с Rails 3 приложениями стоит заменять bundle exec unicorn_rails на bundle exec unicorn
namespace :deploy do
  task :restart do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D; fi"
  end
  task :start do
    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rails_env} -D"
  end
  task :stop do
    run "if [ -f #{unicorn_pid} ] && [ -e /proc/$(cat #{unicorn_pid}) ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
  end
  task :compile_assets do
    # Компилим ассеты
    run "cd #{current_release}; RAILS_ENV=production bundle exec rake assets:precompile"
  end
end
