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
  
  def self.convert_args_to_pytuple(args)
    args_list = RubyPyApi::PyObject.newList(*args.map{|x| RubyPyApi::PyObject.new x})
    RubyPyApi::PyObject.makeTuple args_list
  end

  def self.func(module_name, func_name, *args)
    start
    args_tuple = convert_args_to_pytuple args
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
  
  def method_missing(meth_name, *args)
    raise NoMethodError if !@module.hasAttr(meth_name.to_s)
    attr_obj = @module.getAttr meth_name.to_s
    rubypy_type = RubyPythonBridge2::RubyPyTypes.get_type attr_obj
    if args.empty?
      rubypy_type
    else
      rubypy_type.call(*args)
    end
  end

  def respond_to?(meth_name)
    @module.hasAttr(meth_name.to_s)
  end
end


class RubyPythonBridge2::RubyPyClass
  def initialize(pyobj)
    @pyobj = pyobj
  end

  def call(*args)
      RubyPythonBridge2::RubyPyInstance.new(@pyobj, *args)
  end

  def respond_to?(meth_name)
    @pyobj.hasAttr(meth_name.to_s)
  end
end


class RubyPythonBridge2::RubyPyInstance
  def initialize(pyobj, *args)
    @pyobj = pyobj
  end

  def respond_to?(meth_name)
    @pyobj.hasAttr(meth_name.to_s)
  end
end

class RubyPythonBridge2::RubyPyFunction
  def initialize(pyobj)
    @pyobj = pyobj
  end

  def call(*args)
    args_tuple = RubyPythonBridge2::convert_args_to_pytuple args
    return @pyobj.callObject(args_tuple).rubify
  end
end

class RubyPythonBridge2::RubyPyTypes
  def self.get_type(pyobj, *args)
    return RubyPythonBridge2::RubyPyClass.new pyobj if pyobj.isClass
    return RubyPythonBridge2::RubyPyFunction.new pyobj if pyobj.isFunction or
                                                          pyobj.isMethod or
                                                          !pyobj.hasAttr('__dict__')
  end
end
