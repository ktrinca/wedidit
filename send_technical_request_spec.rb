describe User do

  describe '.send_technical_request_to' do
    
    let(:user){ build(:registered_user) }

    let(:admin){ build(:admin_user) }
    
    it 'sends an email to the sysadmin' do
      expect( user.send_technical_request_to(admin) ).to be true
    end

    it 'sends the email using the mailer' do
      expect( UserMailer ).to receive ( :send_technical_request ).
                              with(user, admin)

      user.send_technical_request_to(admin)
    end   
end
