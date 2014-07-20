require 'spec_helper'

describe Outbox::Messages::SMS do
  it 'sets common sms fields' do
    sms = Outbox::Messages::SMS.new do
      to '+14155551212'
      from 'Company Name'
      body 'Hello world.'
    end
    expect(sms.to).to eq('+14155551212')
    expect(sms.from).to eq('Company Name')
    expect(sms.body).to eq('Hello world.')
  end

  describe '#audience=' do
    context 'with a string' do
      it 'sets the To: field' do
        email = Outbox::Messages::SMS.new
        email.audience = '+14155551212'
        expect(email.to).to eq('+14155551212')
      end
    end

    context 'with a hash' do
      it 'sets multiple fields' do
        email = Outbox::Messages::SMS.new
        email.audience = { to: '+14155551212' }
        expect(email.to).to eq('+14155551212')
      end
    end

    context 'with an object' do
      it 'sets multiple fields' do
        email = Outbox::Messages::SMS.new
        email.audience = OpenStruct.new to: '+14155551212'
        expect(email.to).to eq('+14155551212')
      end
    end
  end

  describe '#validate_fields' do
    before do
      @valid_sms = Outbox::Messages::SMS.new do
        to '+14155551212'
        from 'john@gmail.com'
        body 'Hello world.'
      end
    end

    it 'requires a To: field' do
      @valid_sms.to = nil
      expect {
        @valid_sms.validate_fields
      }.to raise_error(Outbox::MissingRequiredFieldError)
    end

    it 'requires a From: field' do
      @valid_sms.from = nil
      expect {
        @valid_sms.validate_fields
      }.to raise_error(Outbox::MissingRequiredFieldError)
    end

    it 'requires a Body: field' do
      @valid_sms.body = nil
      expect {
        @valid_sms.validate_fields
      }.to raise_error(Outbox::MissingRequiredFieldError)
    end
  end
end
