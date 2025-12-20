# frozen_string_literal: true

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS", max_threads_count)
threads min_threads_count, max_threads_count

environment ENV.fetch("RAILS_ENV", "production")

port = ENV.fetch("PORT", 3000)

bind "tcp://0.0.0.0:#{port}"

pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")
workers ENV.fetch("WEB_CONCURRENCY", 1)

plugin :tmp_restart
