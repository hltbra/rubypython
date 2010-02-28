$:.unshift File.dirname(__FILE__) + "/../ext/rubypyapi/"
require 'rubypyapi'

module RubyPythonBridge2
  
  def self.start
    RubyPyApi.start
  end

  def self.stop
    RubyPyApi.stop
  end

  def self.import(module_name)
    RubyPythonBridge2::RubyPyModule.new module_name
  end

  def self.func(module_name, func_name, *args)
    args_list = RubyPyApi::PyObject.newList(*args.map{|x| RubyPyApi::PyObject.new x})
    args_tuple = RubyPyApi::PyObject.makeTuple args_list
    start
    modulepy = import module_name
    funcpy = modulepy.getAttr func_name
    result = funcpy.callObject args_tuple
    stop
    result.rubify
  end

end


class RubyPythonBridge2::RubyPyModule
  def initialize(module_name)
    @module = RubyPyApi.import module_name
  end

  def getAttr(attrname)
    @module.getAttr attrname
  end

  def Request(*args)
    args.empty? ? RubyPythonBridge2::RubyPyClass.new : RubyPythonBridge2::RubyPyInstance.new
  end
end


class RubyPythonBridge2::RubyPyClass
end


class RubyPythonBridge2::RubyPyInstance
end
