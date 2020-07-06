web: bundle exec passenger start /var/app/current --socket /var/run/puma/my_app.sock
worker: bundle exec sidekiq -C config/sidekiq_worker.yml