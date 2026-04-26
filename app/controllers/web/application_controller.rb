# frozen_string_literal: true

module Web
  class ApplicationController < ::ApplicationController
    include AuthManagement

    # В проекте/CI иногда прилетает Accept: text/vnd.turbo-stream.html и т.п.
    # Для WEB-контроллеров нам всегда нужен HTML, иначе Rails может вернуть 406.
    before_action :force_html_format

    private

    def force_html_format
      request.format = :html
    end
  end
end
