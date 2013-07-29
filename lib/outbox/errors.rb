module Outbox
  # Raised when a message is missing data for a required field.
  class MissingRequiredFieldError < StandardError
  end
end
