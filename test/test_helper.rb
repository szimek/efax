require 'rubygems'
gem 'test-unit', '~> 2'
require 'test/unit'
require 'mocha'

class Class
  def publicize_instance_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public(*saved_private_instance_methods) }
    yield
    self.class_eval { private(*saved_private_instance_methods) }
  end

  def publicize_class_methods
    saved_private_class_methods = self.private_methods(false)
    self.class_eval { public_class_method(*saved_private_class_methods) }
    yield
    self.class_eval { private_class_method(*saved_private_class_methods) }
  end
end
