# frozen_string_literal: true

module Checks
  class RunService
    class << self
      def run(check:, commit_id: nil)
        check.run_check! if check.may_run_check?

        result = run_code_checker(check, commit_id)

        run_data = persist_successful_run(check, result, fallback_commit_id: commit_id)
        finalize(check, passed: run_data[:passed], offenses_count: run_data[:offenses_count])

        check
      rescue StandardError => e
        handle_failed_run(check, commit_id, e)
      end

      private

      def run_code_checker(check, commit_id)
        code_checker = ApplicationContainer[:code_checker]
        code_checker.run(repository: check.repository, commit_id: commit_id)
      end

      def persist_successful_run(check, result, fallback_commit_id:)
        offenses_count = result.offenses_count.to_i
        passed = result.success? && offenses_count.zero?
        final_status = passed ? 'passed' : 'failed'
        stored_commit_id = result.commit_id.presence || fallback_commit_id

        check.update!(
          commit_id: stored_commit_id,
          output: result.output,
          violations_count: offenses_count,
          passed: passed,
          status: final_status
        )

        { passed: passed, offenses_count: offenses_count }
      end

      def finalize(check, passed:, offenses_count:)
        check.finish! if check.may_finish?
        notify_if_failed(check, offenses_count) unless passed
      end

      def handle_failed_run(check, commit_id, error)
        check.update!(
          commit_id: commit_id,
          status: 'failed',
          passed: false,
          output: error.full_message(highlight: false, order: :top)
        )

        check.fail! if check.may_fail?
        notify_if_failed(check, nil)

        check
      end

      def notify_if_failed(check, offenses_count)
        failed = offenses_count.nil? || offenses_count.positive?
        return unless failed

        CheckMailer.check_report(check).deliver_now
      rescue StandardError => e
        Rails.logger.error(
          "[CheckMailer] Failed to send report for check_id=#{check.id}: #{e.class}: #{e.message}"
        )
      end
    end
  end
end
