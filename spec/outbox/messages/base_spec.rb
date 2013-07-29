require 'spec_helper'

describe Outbox::Messages::Base do
  class Message < Outbox::Messages::Base
    default_client :test
    fields :to, 'from'
    field :foo
  end

  class MessageWithRequiredField < Outbox::Messages::Base
    default_client :test
    field :foo, required: true
  end

  class MessageWithRequiredFields < Outbox::Messages::Base
    default_client :test
    required_fields :to, :from
    fields :foo
  end

  describe '.default_client' do
    it 'sets the default client' do
      client = double :client
      allow(client).to receive(:dup) { client }
      Message.default_client(client)
      message = Message.new
      expect(message.client).to be(client)
    end
  end

  describe '.register_client' do
    it 'registers a client alias' do
      Client = Class.new
      Message.register_client_alias :foo, Client
      client = double :client
      options = { option_1: 1, option_2: 2 }
      expect(Client).to receive(:new).with(options) { client}
      Message.default_client :foo, options
      expect(Message.default_client).to be(client)
    end
  end

  describe '.field' do
    it 'creates accessors for defined fields' do
      message = Message.new
      message.foo = :foo
      expect(message.foo).to eq(:foo)
      message.foo :bar
      expect(message.foo).to eq(:bar)
    end
  end

  describe '.defaults' do
    it 'sets the fields defaults' do
      Message.defaults from: 'John'
      message = Message.new
      expect(message.from).to eql('John')
    end
  end

  describe '.new' do
    it 'initializes with a hash' do
      message = Message.new to: 'Bob', oops: 'John'
      expect(message.to).to eq('Bob')
      expect(message).to_not respond_to(:oops)
    end

    it 'initializes with a block' do
      message = Message.new do
        to 'Bob'
        from 'John'
      end
      expect(message.to).to eq('Bob')
      expect(message.from).to eq('John')
    end
  end

  describe '#fields' do
    it 'returns a hash of the fields' do
      message = Message.new
      message.to = 'Bob'
      message.from = 'John'
      expect(message.fields).to eq(to: 'Bob', from: 'John')
    end
  end

  describe '#deliver' do
    context 'when valid' do
      it 'delivers the message using a client' do
        client = double :client
        message = Message.new
        message.client(client)
        expect(client).to receive(:deliver).with(message)
        message.deliver
      end
    end

    context 'with a required field' do
      it 'raises an error' do
        message = MessageWithRequiredField.new
        expect{message.deliver}.to raise_error(Outbox::MissingRequiredFieldError)
      end
    end

    context 'with required fields' do
      it 'raises an error' do
        message = MessageWithRequiredFields.new to: 'Bob'
        expect{message.deliver}.to raise_error(Outbox::MissingRequiredFieldError)
      end
    end
  end
end
