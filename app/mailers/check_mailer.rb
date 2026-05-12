# frozen_string_literal: true

class CheckMailer < ApplicationMailer
  helper ChecksHelper

  def check_report(check)
    @check      = check
    @repository = check.repository
    @user       = @repository.user

    mail(
      to: @user.email,
      subject: t('mailers.check_report.subject', repository: @repository.full_name)
    )
  end
end
