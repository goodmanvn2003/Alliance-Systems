require "spec_helper"

describe UserMailer do

  describe "Send email to reset password" do
    before do
      @user = create(:validUser)
    end

    after do
      @user.destroy
    end

    let(:mail) { UserMailer.reset_passwords_email(@user,"http://example.com","123456") }

    it "should send email to user" do
      mail.subject.should == '[Alliance-CMS] Password Reset'
    end

    it "should contain request code" do
      mail.body.encoded.should include('123456')
    end
  end

  describe "Send email to activate user" do
    before do
      @user = create(:validUser)
    end

    after do
      @user.destroy
    end

    let (:actMail) { UserMailer.activate_account_email(@user,"http://example.com") }

    it "should send email to activate user" do
      actMail.subject.should == '[Alliance-CMS] Account Activation'
    end
  end

  describe "Send email to invite user" do
    before do
      @user = create(:validUser)
    end

    after do
      @user.destroy
    end

    let (:actMail) { UserMailer.invite_email(@user,"test@test.com","workspace","http://example.com") }

    it "should send email to invite user" do
      actMail.subject.should == 'Invite email'
    end
  end

end
