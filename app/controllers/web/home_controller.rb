# frozen_string_literal: true

module Web
  class HomeController < ApplicationController
    # В тестах/CI иногда прилетает формат/Accept, из-за которого Rails уходит в UnknownFormat => 406.
    # Жёстко рендерим HTML-шаблон, чтобы всегда получать 200 и корректную страницу.
    def index
      render template: "web/home/index", formats: [ :html ]
    end
  end
end
