# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

task :version do
  p "v%d.%d.%d" % [
    CertManager::Application.config.version[:major],
    CertManager::Application.config.version[:minor],
    CertManager::Application.config.version[:patch]
  ]
end
