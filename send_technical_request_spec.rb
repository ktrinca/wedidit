
# spec/models/user_spec.rb
#
describe User do

  describe '#send_technical_request_to' do
    
    let(:user){ build(:registered_user) }

    let(:technical_request){ build(:technical_request) }
    
    it 'sends an email to the sysadmin' do
      expect( user.send_technical_request_to(technical_request) ).to be true
    end

    it 'sends the email using the mailer' do
      expect( UserMailer ).to receive ( :send_technical_request ).
                              with(technical_request)

      user.send_technical_request_to(technical_request)
    end   

  end
end

# spec/mailers/user_mailer_spec.rb
#
describe UserMailer do
  describe '.send_technical_request' do

    before do
      @email = UserMailer.send_technical_request( technical_request )
    end
    
    it 'the email got queued' do
      expect( ActionMailer::Base.deliveries ).not_to be_empty
    end

    it 'send the mail to the sys admin email' do
      expect( @email.to ).to eq( ENV['ADMIN_EMAIL'] )
    end

    it 'send the email from the user email' do
      expect( @email.from ).to eq( technical_request.user.email )
    end

    it 'sets the right subject' do
      expect( @email.subject ).to eq( technical_request.title )
    end  
  end
end

# spec/models/technical_request_spec.rb
#
describe TechnicalRequest do
  describe '#after_create' do

    let(:technical_request){ build(:technical_request) }
    
    it 'sends the email to the admin' do
      expect( UserMailer ).to receive ( :send_technical_request ).
                                        with(technical_request)
      
      technical_request = TechnicalRequest.create do |tr|
        tr.user        = user
        tr.description = 'The staging server is down'
      end
    end  
  end  
end  


# spec/features/sending_technical_request_spec.rb

def login
  visit new_user_session_path

  within("#session") do
    fill_in 'Email', :with => 'user@wedidit.com'
    fill_in 'Password', :with => 'password'
  end

  click_button 'Sign in'
  expect(page).to have_content 'Success'
end

describe "sending technical request", :type => feature do
  it 'sends email technical request' do
    login
    visit new_technical_request_path

    within("#technical_request") do
      fill_in 'title', :with => 'staging server down'
      fill_in 'description', :with => 'is down'
    end
    
    click_button 'create'
    expect(page).to have_content 'Email technical request sent to #{ENV['ADMIN_EMAIL']}'
  end
  
end

