# frozen_string_literal: true

require 'test_helper'

class CodeCheckerTest < ActiveSupport::TestCase
  class FakeRunner
    Status = Struct.new(:ok) do
      def success?
        ok
      end
    end

    Result = Struct.new(:stdout, :status, keyword_init: true)

    def initialize(output:, success: true)
      @output = output
      @success = success
    end

    def capture3(*, chdir:)
      _ = chdir
      Result.new(stdout: @output, status: Status.new(@success))
    end
  end

  def checker_for(output)
    checker = CodeChecker.new(repository: repositories(:one))
    runner = FakeRunner.new(output:)
    checker.define_singleton_method(:command_runner) { runner }
    checker
  end

  test 'RuboCop cannot pass with zero inspected files' do
    output = { 'files' => [], 'summary' => { 'offense_count' => 0, 'inspected_file_count' => 0 } }.to_json

    _output, offenses, passed = checker_for(output).send(:run_rubocop, Rails.root.join('tmp/check'))

    assert_equal 0, offenses
    assert_equal false, passed
  end

  test 'RuboCop passes with inspected files and no offenses' do
    output = { 'files' => [], 'summary' => { 'offense_count' => 0, 'inspected_file_count' => 2 } }.to_json

    _output, offenses, passed = checker_for(output).send(:run_rubocop, Rails.root.join('tmp/check'))

    assert_equal 0, offenses
    assert_equal true, passed
  end

  test 'ESLint cannot pass with zero inspected files' do
    _output, offenses, passed = checker_for('[]').send(:run_eslint, Rails.root.join('tmp/check'))

    assert_equal 0, offenses
    assert_equal false, passed
  end
end
