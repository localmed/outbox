Outbox
======

[![Gem Version](https://badge.fury.io/rb/outbox.png)](http://badge.fury.io/rb/outbox)

Outbox is a factory for creating notifications in a variety of protocols, including: email, SMS, and push notifications. Each protocol is built as a generic interface where the actual delivery method or service can be configured independently of the message itself.


Installation
------------

Add this line to your application's Gemfile:

``` ruby
gem 'outbox'
```

And then execute:

``` bash
$ bundle
```

Or install it yourself as:

``` bash
$ gem install outbox
```

Support
-------

This gem is still in early development with plans to support email, SMS, and push notificaitons. As protocols and services are added, this support table will be updated:

### Email

| Service                                   | Alias   | Client     |
|-------------------------------------------|---------|------------|
| [Mail gem](https://github.com/mikel/mail) | `:mail` | MailClient |

### SMS

TODO…

### Push

TODO…

Usage
-----

Outbox is inspired by [Mail's](https://github.com/mikel/mail) syntax for creating emails.

### Making a Message

An Outbox message is actually a factory for creating many different types of messages with the same **topic**. For example: a **topic** could be an event reminder in a calendar application. You want to send out essentially the same content (the reminder) as an email, SMS, and/or push notifications depending on user preferences:

``` ruby
message = Outbox::Message.new do
  email do
    from 'noreply@myapp.com'
    subject 'You have an upcoming event!'
  end

  sms do
    from '+15557654321'
  end

  ios_push do
    badget '+1'
    sound 'default'
  end

  body "Don't forget, you have an upcoming event on 8/15/2013."
end

# This will deliver the message to User's given contact points.
message.deliver email: 'user@gmail.com', sms: '+15551234567', ios_push: 'FE66489F304DC75B8D6E8200DFF8A456E8DAEACEC428B427E9518741C92C6660'
```

### Making an email

Making just an email is done just how you would using the [Mail gem](https://github.com/mikel/mail), so look there for in-depth examples. Here's a simple one to get you started:

``` ruby
email = Outbox::Messages::Email.new do
  to 'user@gmail.com'
  from 'noreply@myapp.com'
  subject 'You have an upcoming event!'

  text_part do
    body "Don't forget, you have an upcoming event on 8/15/2013."
  end

  html_part do
    body "<h1>Event Reminder</h1>..."
  end
end

# Configure the client. If you use the MailClient, you can specify
# the actual delivery method:
email.client :mail, delivery_method: :smtp, smtp_settings: {}

# And deliver using the specified client
email.deliver
```

Configuration
-------------

TODO...

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
