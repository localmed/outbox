require 'mail'

module Outbox
  module Messages
    # Email messages use the same interface for composing emails as
    # Mail::Message from the mail gem. The only difference is the abstraction
    # of the client interface, which allows you to send the email using
    # whatever client you wish.
    #
    #   email = Outbox::Messages::Email.new do
    #     to 'nicolas@test.lindsaar.net.au'
    #     from 'Mikel Lindsaar <mikel@test.lindsaar.net.au>'
    #     subject 'First multipart email sent with Mail'
    #
    #     text_part do
    #       body 'This is plain text'
    #     end
    #
    #     html_part do
    #       content_type 'text/html; charset=UTF-8'
    #       body '<h1>This is HTML</h1>'
    #     end
    #   end
    #   email.client :mandrill, api_key: '...'
    #   email.deliver
    class Email < Base
      register_client_alias :mail, Outbox::Clients::MailClient

      default_client :mail

      required_fields :smtp_envelope_from, :smtp_envelope_to,
                      :encoded, accessor: false

      fields :bcc, :cc, :content_description, :content_disposition,
             :content_id, :content_location, :content_transfer_encoding,
             :content_type, :date, :from, :in_reply_to, :keywords,
             :message_id, :mime_version, :received, :references, :reply_to,
             :resent_bcc, :resent_cc, :resent_date, :resent_from,
             :resent_message_id, :resent_sender, :resent_to, :return_path,
             :sender, :to, :comments, :subject, accessor: false

      undef :body=, :[], :[]=

      def initialize(fields = nil, &block) # :nodoc:
        @message = ::Mail::Message.new
        super
      end

      # Returns the internal Mail::Message instance
      def message_object
        @message
      end

      def audience=(audience) # :nodoc:
        case audience
        when String, Array
          self.to = audience
        else
          audience = Outbox::Accessor.new(audience)
          self.to = audience[:to]
          self.cc = audience[:cc]
          self.bcc = audience[:bcc]
        end
      end

      protected

      def method_missing(method, *args, &block)
        if @message.respond_to?(method)
          @message.public_send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        super || @message.respond_to?(method, include_private)
      end
    end
  end
end
