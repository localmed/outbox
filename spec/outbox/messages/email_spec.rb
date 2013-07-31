require 'spec_helper'

describe Outbox::Messages::Email do
  it 'sets common email fields' do
    email = Outbox::Messages::Email.new do
      to 'bob@gmail.com'
      from 'john@gmail.com'
      subject 'Simple email subject'
      body 'Hello world.'
    end
    expect(email.to).to eq(['bob@gmail.com'])
    expect(email.from).to eq(['john@gmail.com'])
    expect(email.subject).to eq('Simple email subject')
    expect(email.body).to eq('Hello world.')
  end

  it 'sets a multipart body' do
    email = Outbox::Messages::Email.new do
      text_part do
        body 'Hello world.'
      end
      html_part do
        body '<h1>Hello world.</h1>'
      end
    end
    expect(email.parts.length).to eq(2)
  end

  describe '.registered_client_aliases' do
    it 'includes TestClient' do
      expect(Outbox::Messages::Email.registered_client_aliases[:test]).to eq(Outbox::Clients::TestClient)
    end

    it 'includes MailClient' do
      expect(Outbox::Messages::Email.registered_client_aliases[:mail]).to eq(Outbox::Clients::MailClient)
    end
  end

  describe '.default_client' do
    it 'defaults to MailClient' do
      expect(Outbox::Messages::Email.default_client).to be_an_instance_of(Outbox::Clients::MailClient)
    end
  end

  describe '#audience=' do
    context 'with a string' do
      it 'sets the To: field' do
        email = Outbox::Messages::Email.new
        email.audience = 'bob@gmail.com'
        expect(email.to).to eq(['bob@gmail.com'])
      end
    end

    context 'with an array' do
      it 'sets the To: field' do
        email = Outbox::Messages::Email.new
        email.audience = ['bob@gmail.com', 'john@gmail.com']
        expect(email.to).to eq(['bob@gmail.com', 'john@gmail.com'])
      end
    end

    context 'with a hash' do
      it 'sets multiple fields' do
        email = Outbox::Messages::Email.new
        email.audience = {
          :to => 'bob@gmail.com',
          :cc => 'john@gmail.com',
          'bcc' => 'sally@gmail.com',
          :from => 'someone@gmail.com'
        }
        expect(email.to).to eq(['bob@gmail.com'])
        expect(email.cc).to eq(['john@gmail.com'])
        expect(email.bcc).to eq(['sally@gmail.com'])
        expect(email.from).to be_nil
      end
    end

    context 'with an object' do
      it 'sets multiple fields' do
        email = Outbox::Messages::Email.new
        email.audience = OpenStruct.new to: 'bob@gmail.com', cc: 'john@gmail.com'
        expect(email.to).to eq(['bob@gmail.com'])
        expect(email.cc).to eq(['john@gmail.com'])
      end
    end
  end

  describe '#validate_fields' do
    before do
      @valid_email = Outbox::Messages::Email.new do
        to 'bob@gmail.com'
        from 'john@gmail.com'
        body 'Hello world.'
      end
    end

    it 'does not raise an error with a valid email' do
      expect{@valid_email.validate_fields}.not_to raise_error()
    end

    it 'raises an error without a recipient' do
      @valid_email.to = nil
      expect{@valid_email.validate_fields}.to raise_error(Outbox::MissingRequiredFieldError)
    end

    it 'does not raise an error with a Cc: field' do
      @valid_email.to = nil
      @valid_email.cc = 'bob@gmail.com'
      expect{@valid_email.validate_fields}.not_to raise_error()
    end

    it 'does not raise an error with a Bcc: field' do
      @valid_email.to = nil
      @valid_email.bcc = 'bob@gmail.com'
      expect{@valid_email.validate_fields}.not_to raise_error()
    end

    it 'raises an error without a receiver' do
      @valid_email.from = nil
      expect{@valid_email.validate_fields}.to raise_error(Outbox::MissingRequiredFieldError)
    end

    it 'does not raise an error with a Return-path: field' do
      @valid_email.from = nil
      @valid_email.return_path = 'bob@gmail.com'
      expect{@valid_email.validate_fields}.not_to raise_error()
    end

    it 'does not raise an error with a Sender: field' do
      @valid_email.from = nil
      @valid_email.sender = 'bob@gmail.com'
      expect{@valid_email.validate_fields}.not_to raise_error()
    end
  end
end
