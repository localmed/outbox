require 'spec_helper'

describe Outbox::Clients::MailClient do
  describe '.new' do
    it 'configures the delivery method' do
      client = Outbox::Clients::MailClient.new delivery_method: :smtp, smtp_settings: {
        address: 'smtp.mockup.com',
        port: 587
      }
      expect(client.delivery_method).to eq(:smtp)
      expect(client.delivery_method_settings[:address]).to eq('smtp.mockup.com')
      expect(client.delivery_method_settings[:port]).to eq(587)
    end
  end

  describe '#deliver' do
    before do
      @client = Outbox::Clients::MailClient.new delivery_method: :smtp, smtp_settings: {
        address: 'smtp.mockup.com',
        port: 587
      }
      @email = Outbox::Messages::Email.new do
        to 'bob@gmail.com'
        from 'john@gmail.com'
        body 'Hello world.'
      end
    end

    it 'configures the delivery method' do
      message = double(:message, deliver: true)
      expect(@email.message_object).to receive(:dup) { message }
      expect(message).to receive(:delivery_method).with(:smtp, address: 'smtp.mockup.com', port: 587)
      @client.deliver(@email)
    end

    it 'delivers the email' do
      message = double(:message, delivery_method: true)
      expect(@email.message_object).to receive(:dup) { message }
      expect(message).to receive(:deliver)
      @client.deliver(@email)
    end
  end
end
