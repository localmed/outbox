module Outbox
  require 'outbox/errors'
  require 'outbox/version'

  autoload 'Accessor', 'outbox/accessor'
  autoload 'DefineInheritableMethod', 'outbox/define_inheritable_method'
  autoload 'Message', 'outbox/message'
  autoload 'MessageClients', 'outbox/message_clients'
  autoload 'MessageFields', 'outbox/message_fields'
  autoload 'MessageTypes', 'outbox/message_types'

  module Clients
    autoload 'Base', 'outbox/clients/base'
    autoload 'MailClient', 'outbox/clients/mail_client'
    autoload 'TestClient', 'outbox/clients/test_client'
  end

  module Messages
    autoload 'Base', 'outbox/messages/base'
    autoload 'Email', 'outbox/messages/email'
    autoload 'SMS', 'outbox/messages/sms'
  end
end
