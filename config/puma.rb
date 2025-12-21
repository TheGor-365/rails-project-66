environment ENV.fetch("RAILS_ENV", "production")

threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 3))
threads threads_count, threads_count

port ENV.fetch("PORT", 3000)

workers Integer(ENV.fetch("WEB_CONCURRENCY", 0))
preload_app!

plugin :tmp_restart
