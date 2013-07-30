module Outbox
  # Accessor is a simple object for wrapping access to either a hash's keys
  # or an object's properties. You can arbitrarily get/set either. Note that
  # with hashes, the keys are symbolized and a new hash is created - so if you
  # set properties you'll need to get the resulting hash from the #object
  # method.
  #
  # Example:
  #
  #   hash = { :a => 1, 'b' => 2 }
  #   hash_accessor = Outbox::Accessor.new(hash)
  #   hash_accessor[:a] #=> 1
  #   hash_accessor[:b] #=> 2
  #   hash_accessor[:c] #=> nil
  #   hash_accessor[:c] = 3
  #   hash_accessor.object[:c] #=> 3
  #   hash_accessor.object #=> { a: 1, b: 2, c: 3 }
  #
  #   object = OpenStruct.new
  #   object.a = 1
  #   object.b = 2
  #   object_accessor = Outbox::Accessor.new(object)
  #   object_accessor[:a] #=> 1
  #   object_accessor[:b] #=> 2
  #   object_accessor[:c] #=> nil
  #   object_accessor[:c] = 3
  #   object_accessor.object.c #=> 3
  class Accessor
    attr_reader :object

    def initialize(object)
      if object.instance_of? Hash
        @object = convert_keys(object)
      else
        @object = object
      end
    end

    def []=(key, value)
      setter = "#{key}="
      if @object.respond_to?(setter)
        @object.public_send(setter, value)
      elsif @object.respond_to? :[]=
        @object[convert_key(key)] = value
      end
    end

    def [](key)
      key = convert_key(key)
      if @object.respond_to?(key)
        @object.public_send(key)
      elsif @object.respond_to? :[]
        @object[key]
      end
    end

    protected

    def convert_keys(hash)
      result = {}
      hash.each_key do |key|
        result[convert_key(key)] = hash[key]
      end
      result
    end

    def convert_key(key)
      key.to_sym rescue key
    end
  end
end
