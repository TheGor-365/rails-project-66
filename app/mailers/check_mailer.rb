# frozen_string_literal: true

class CheckMailer < ApplicationMailer
  def check_report(check)
    @check      = check
    @repository = check.repository
    @user       = @repository.user

    mail(
      to: @user.email,
      subject: "Результат проверки репозитория #{@repository.full_name}"
    )
  end
end
