module Outbox
  module Messages
    # SMS tend to support very different types of parameters, so only
    # the most common ones will be directly applied to the SMS message class.
    # All of the other ones can be set using the arbitrary field access with
    # [] and []=.
    #
    #   sms = Outbox::Messages::SMS.new do
    #     to '+14155551212'
    #     from 'Company Name'
    #     body 'Hellow world'
    #   end
    #   sms.client :twilio, api_key: '...'
    #   sms.deliver
    class SMS < Base
      required_fields :to, :from, :body

      fields :type, :reference, :vcard, :vcal, :callback, :application_id
    end
  end
end
