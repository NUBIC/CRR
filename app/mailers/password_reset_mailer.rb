class PasswordResetMailer < ActionMailer::Base
  def password_reset_instructions(account)
    @account = account
    mail(:from=>"commresearchregistry@northwestern.edu",:to=>@account.email, :subject=> "Password Reset Instructions")
  end
end