module Outbox
  module DefineInheritableMethod
    # Similar to .define_method, but adds a dynamic module in the inheritance
    # change to attach the method to. See:
    #
    # http://thepugautomatic.com/2013/07/dsom/
    def define_inheritable_method(mod_name, *args, &block)
      mod = get_inheritable_module(mod_name)
      mod.module_eval do
        define_method(*args, &block)
      end
    end

    protected

    def get_inheritable_module(mod_name)
      if const_defined?(mod_name, false)
        const_get(mod_name)
      else
        include const_set(mod_name, Module.new)
      end
    end
  end
end
