require "test_helper"

class RepositoryTest < ActiveSupport::TestCase
  test "fixture is valid" do
    repo = repositories(:one)

    assert { repo.valid? }
    assert { repo.language.to_s == "Ruby" }
  end
end
