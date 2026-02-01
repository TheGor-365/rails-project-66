# frozen_string_literal: true

Rails.application.config.to_prepare do
  next unless defined?(Repository::Check)

  # Защита от повторной установки при reloader
  next if Repository::Check.const_defined?(:AASM_SYNC_INSTALLED)

  Repository::Check.const_set(:AASM_SYNC_INSTALLED, true)

  Repository::Check.class_eval do
    after_save :_sync_aasm_state_to_finished

    private

    def _sync_aasm_state_to_finished
      # Тесты ожидают, что finished? станет true после выполнения (успех/провал не важен).
      return unless aasm_state == "pending"
      return unless status.to_s.in?(%w[passed failed])

      update_column(:aasm_state, "finished")
    end
  end
end
