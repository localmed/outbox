require 'ostruct'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'outbox'

RSpec.configure do |config|
  config.after(:each) do
    Outbox::Clients::TestClient.deliveries.clear
  end
end
