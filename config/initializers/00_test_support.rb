# frozen_string_literal: true

return unless Rails.env.test?

require Rails.root.join("test/support/code_checker_stub")
require Rails.root.join("test/support/github_client_stub")
