$:.unshift File.dirname(__FILE__) + "/../ext/rubypyapi/"
require 'rubypyapi'

module RubyPythonBridge2
  
  def self.start
    RubyPyApi.start
  end

  def self.stop
    RubyPyApi.stop
  end

  def self.func(module_name, func_name, *args)
    start
    modulepy = RubyPyApi.import module_name
    args_list = RubyPyApi::PyObject.newList(*args.map{|x| RubyPyApi::PyObject.new x})
    args_tuple = RubyPyApi::PyObject.makeTuple args_list
    funcpy = modulepy.getAttr(func_name)
    result = funcpy.callObject args_tuple
    stop
    result.rubify
  end

end
