# frozen_string_literal: true

# Compatibility namespace for external fixture loaders that expect Repository::Check.
class Repository < ApplicationRecord
  class Check < ::Check
  end
end
