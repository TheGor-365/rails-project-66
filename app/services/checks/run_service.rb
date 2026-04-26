# frozen_string_literal: true

module Checks
  class RunService
    class << self
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      def run(check:, commit_id: nil)
        notify_failure = lambda do
          CheckMailer.check_report(check).deliver_now
        rescue StandardError => e
          Rails.logger.error(
            "[CheckMailer] Failed to send report for check_id=#{check.id}: #{e.class}: #{e.message}"
          )
        end

        return check unless check.may_run_check?

        check.run_check!

        result = ApplicationContainer[:code_checker].run(
          repository: check.repository,
          commit_id: commit_id
        )

        offenses_count = result.offenses_count.to_i
        passed = result.success? && offenses_count.zero?
        final_status = passed ? 'passed' : 'failed'
        stored_commit_id = result.commit_id.presence || commit_id

        check.update!(
          commit_id: stored_commit_id,
          output: result.output,
          violations_count: offenses_count,
          passed: passed,
          status: final_status
        )

        check.finish! if check.may_finish?
        notify_failure.call if offenses_count.positive?

        check
      rescue StandardError => e
        check.update!(
          commit_id: commit_id,
          status: 'failed',
          passed: false,
          output: e.full_message(highlight: false, order: :top)
        )

        check.fail! if check.may_fail?
        notify_failure.call

        check
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize
    end
  end
end
