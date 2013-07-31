require 'spec_helper'

describe Outbox::Clients::Base do
  class Client < Outbox::Clients::Base
    defaults foo: 10
  end

  describe '.defaults' do
    it 'defines default settings' do
      client = Client.new
      expect(client.settings[:foo]).to eq(10)
    end
  end

  describe '.new' do
    it 'initializes settings' do
      client = Client.new foo: 1, bar: 2
      expect(client.settings[:foo]).to eq(1)
      expect(client.settings[:bar]).to eq(2)
    end
  end

  describe '#deliver' do
    it 'raises an error' do
      client = Client.new
      expect{client.deliver(Outbox::Messages::Base.new)}.to raise_error(NotImplementedError)
    end
  end
end
