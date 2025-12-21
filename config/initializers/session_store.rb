# frozen_string_literal: true

Rails.application.config.session_store :cookie_store,
  key: "_github_quality_session",
  same_site: :lax,
  secure: Rails.env.production?
