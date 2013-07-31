require 'spec_helper'

describe Outbox::Clients::TestClient do
  class Message < Outbox::Messages::Base
    default_client :test
    fields :to, :body
  end

  before { Outbox::Clients::TestClient.deliveries.clear }

  it 'defaults to no deliveries' do
    expect(Outbox::Clients::TestClient.deliveries).to be_empty
  end

  it 'appends the delivery to to deliveries array' do
    message = Message.new(to: 'Bob', body: 'Hi Bob')
    message.deliver
    expect(Outbox::Clients::TestClient.deliveries.length).to eq(1)
    expect(Outbox::Clients::TestClient.deliveries.first).to be(message)
  end

  it 'saves configuration' do
    client = Outbox::Clients::TestClient.new foo: 1, bar: 2
    expect(client.settings).to eq(foo: 1, bar: 2)
  end
end
