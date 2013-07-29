require 'spec_helper'

describe Outbox::Message do
  class Telepathy < Outbox::Messages::Base
    default_client :test
    fields :to, :from, :thought
  end

  class MessageInABottle < Outbox::Messages::Base
    default_client :test
    fields :to, :bottle, :message
  end

  before do
    @original_message_types = Outbox::Message.message_types
    Outbox::Message.register_message_type :telepathy, Telepathy
    Outbox::Message.register_message_type :bottle, MessageInABottle
  end

  after do
    Outbox::Message.instance_variable_set :@message_types, @original_message_types
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
end
