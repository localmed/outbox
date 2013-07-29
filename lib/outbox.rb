module Outbox
  require 'outbox/errors'
  require 'outbox/version'

  autoload 'Message', 'outbox/message'
  autoload 'MessageClients', 'outbox/message_clients'
  autoload 'MessageFields', 'outbox/message_fields'
  autoload 'MessageTypes', 'outbox/message_types'

  module Clients
    autoload 'TestClient', 'outbox/clients/test_client'
  end

  module Messages
    autoload 'Base', 'outbox/messages/base'
  end
end
