require 'spec_helper'

describe Outbox::Message do
  class Telepathy < Outbox::Messages::Base
    default_client :test
    fields :to, :from, :thought

    def body=(value)
      self.thought = value
    end
  end

  class MessageInABottle < Outbox::Messages::Base
    default_client :test
    fields :to, :bottle, :message

    def body=(value)
      self.message = value
    end
  end

  before do
    @original_message_types = Outbox::Message.message_types
    Outbox::Message.register_message_type :telepathy, Telepathy
    Outbox::Message.register_message_type :bottle, MessageInABottle
  end

  after do
    Outbox::Message.instance_variable_set :@message_types, @original_message_types
  end

  describe '.message_types' do
    it 'includes email' do
      expect(Outbox::Message.message_types[:email]).to eq(Outbox::Messages::Email)
    end
  end

  describe '.register_message_type' do
    it 'adds a message type' do
      expect(Outbox::Message.message_types[:telepathy]).to eq(Telepathy)
    end

    it 'defines a block accessor for that type' do
      message = Outbox::Message.new
      message.telepathy do
        thought 'Hello world.'
      end
      expect(message.telepathy.thought).to eq('Hello world.')
    end

    it 'defines a writer for that type' do
      message = Outbox::Message.new
      message.telepathy = Telepathy.new thought: 'Hello world.'
      expect(message.telepathy.thought).to eq('Hello world.')
    end
  end

  describe '.new' do
    it 'initializes with a block' do
      message = Outbox::Message.new do
        telepathy do
          thought 'Hello world.'
        end
      end
      expect(message.telepathy.thought).to eq('Hello world.')
    end

    it 'initializes with a hash' do
      message = Outbox::Message.new telepathy: { thought: 'Hello world.' }
      expect(message.telepathy.thought).to eq('Hello world.')
    end
  end

  describe 'default message type client' do
    after do
      Telepathy.registered_client_aliases.delete(:foo)
      Telepathy.default_client :test
    end

    it 'sets the default client for that message type' do
      client_class = Class.new
      Telepathy.register_client_alias :foo, client_class
      client = double :client
      options = { option_1: 1, option_2: 2 }
      expect(client_class).to receive(:new).with(options) { client}
      Outbox::Message.default_telepathy_client :foo, options
      expect(Telepathy.default_client).to be(client)
    end
  end

  describe 'message type reader' do
    context 'when uninitialized' do
      it 'returns nil' do
        expect(Outbox::Message.new.telepathy).to be_nil
      end

      context 'with a hash' do
        it 'creates a new instance' do
          message = Outbox::Message.new
          message.telepathy thought: 'What?'
          expect(message.telepathy.thought).to eq('What?')
        end
      end
    end

    context 'when initialized' do
      before do
        @message = Outbox::Message.new do
          telepathy do
            from 'Bob'
            thought 'What?'
          end
        end
      end

      context 'with a hash' do
        it 'applies the fields values' do
          @message.telepathy thought: 'Hello world.'
          expect(@message.telepathy.from).to eq('Bob')
          expect(@message.telepathy.thought).to eq('Hello world.')
        end
      end

      context 'with a block' do
        it 'applies the fields values' do
          @message.telepathy do
            thought 'Hello world.'
          end
          expect(@message.telepathy.from).to eq('Bob')
          expect(@message.telepathy.thought).to eq('Hello world.')
        end
      end
    end
  end

  describe '#deliver' do
    before do
      @message = Outbox::Message.new do
        telepathy do
          thought 'Hello world.'
        end
      end
    end

    context 'with a hash' do
      it 'deilvers the message to that audience' do
        @message.deliver telepathy: 'Bob', bottle: 'John'
        message = Outbox::Clients::TestClient.deliveries.last
        expect(Outbox::Clients::TestClient.deliveries.length).to eq(1)
        expect(message).to be(@message.telepathy)
        expect(message.to).to eq('Bob')
      end
    end

    context 'with an audience object' do
      it 'delivers the messages to the audience' do
        audience = OpenStruct.new
        audience.telepathy = 'Bob'
        audience.bottle = 'John'

        @message.bottle do
          bottle 'Coke'
          message 'Hello world.'
        end

        @message.deliver(audience)
        expect(Outbox::Clients::TestClient.deliveries.length).to eq(2)
        expect(@message.telepathy.to).to eq('Bob')
        expect(@message.bottle.to).to eq('John')
      end
    end
  end

  describe '#body' do
    it 'assigns the value to all message types' do
      message = Outbox::Message.new do
        email {}
        telepathy {}
        bottle {}
        body 'Simple Message'
      end
      expect(message.email.body.encoded).to eq('Simple Message')
      expect(message.telepathy.thought).to eq('Simple Message')
      expect(message.bottle.message).to eq('Simple Message')
    end
  end
end
