require "test/unit"

$:.unshift File.dirname(__FILE__) + "/../lib"
require 'rubypython_bridge2'

class TestRubyPythonBridge2Extn2 < Test::Unit::TestCase
  
  def test_func_with_module
    pickle_return = RubyPythonBridge2.func("cPickle",
                                          "loads",  "(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns.")
    
    assert_equal({"a"=>"n", [1, "2"]=>4},pickle_return)
  end
  
  def test_start_stop
    assert(RubyPythonBridge2.start, "Embedded python interpreter failed to start correctly.")
    
    assert(!RubyPythonBridge2.start, "Interpreter attempted to start while running.")
    
    assert(RubyPythonBridge2.stop, "Interpreter failed to halt.")
    
    assert(!RubyPythonBridge2.stop, "Interpreter ran into trouble while halting.")
  end
  
  def test_new_instance
    RubyPythonBridge2.start
    
    urllib2 = RubyPythonBridge2.import "urllib2"
    
    assert_instance_of(RubyPythonBridge2::RubyPyClass,
                       urllib2.Request,
                       "Wrapped Python class not of correct type.")
    
    assert_instance_of(RubyPythonBridge2::RubyPyInstance,
                       urllib2.Request("google.com"),
                       "Wrapped python instance not of correct type.")
    
    RubyPythonBridge2.stop
  end
  
#  def test_new_instance_with_new_method
#    RubyPythonBridge2.start
#    
#    urllib2=RubyPythonBridge2.import "urllib2"
#    
#    assert_instance_of(RubyPythonBridge2::RubyPyClass,
#                       urllib2.Request,
#                       "Wrapped Python class not of correct type.")
#    
  ######    Would ``new`` method be nice? isn't it that common? ######
#    assert_instance_of(RubyPythonBridge2::RubyPyInstance,
#                       urllib2.Request.new("google.com"),
#                       "New call misbehaving of wrapped class.")
#    
#    RubyPythonBridge2.stop
#  end
  
end

class TestRubyPythonBridge2WithCPickle < Test::Unit::TestCase
  def setup
    RubyPythonBridge2.start
    @cPickle = RubyPythonBridge2.import "cPickle"
  end
  
  def teardown
#    ObjectSpace.each_object(RubyPythonBridge2::RubyPyObject) do |o|
#      o.free_pobj
#    end
    RubyPythonBridge2.stop
  end
  
  def test_mod_respond_to
    assert(@cPickle.respond_to?(:loads),
           "Ruby respond to method not working on wrapped module.")
  end
  
  def test_data_passing
    assert_equal({"a"=>"n", [1, "2"]=>4},
                 @cPickle.loads( "(dp1\nS'a'\nS'n'\ns(I1\nS'2'\ntp2\nI4\ns."),
                 "Data returned from wrapped cPickle is incorrect." )
    
    orig_array = [1,2,3,4]
    dumped_array = @cPickle.dumps(orig_array)
    
    assert_equal(orig_array,
                 @cPickle.loads(dumped_array),
                 "Array returned from cPickle is not equivalent to input array.")
  end
  
  def test_unknown_method
    assert_raise(NoMethodError, "Missing method failed to raise NoMethodError") do
      @cPickle.splack
    end
  end
  
  def test_class_wrapping
    assert_instance_of(RubyPythonBridge2::RubyPyClass,
                       @cPickle.PicklingError,
                       "Wrapped class is not an instance of RubyPyClass.")
  end
 
  def test_module_wrapping
    assert_instance_of(RubyPythonBridge2::RubyPyModule,
                       @cPickle,
                       "Wrapped module is not of class RubyPyModule.")
  end
  
end


class TestRubyPythonBridge2WithUrllib2 < Test::Unit::TestCase
  def setup
    RubyPythonBridge2.start
    @urllib2 = RubyPythonBridge2.import "urllib2"
  end
#  
  def teardown
#    ObjectSpace.each_object(RubyPythonBridge2::RubyPyObject) do |o|
#      o.free_pobj
#    end
    RubyPythonBridge2.stop
  end

  def test_class_respond_to
    assert(@urllib2.Request.respond_to? :get_data)
  end
  
  def test_instance_respond_to
    assert(@urllib2.Request("google.com").respond_to? :get_data)
  end
  
end

