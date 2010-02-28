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
  
  def method_missing(meth_name, *args)
    attr_obj = @module.getAttr meth_name.to_s
    RubyPythonBridge2::RubyPyObjectFactory.create(attr_obj, *args)
  end

  def respond_to?(meth_name)
    @module.hasAttr(meth_name.to_s)
  end
end


class RubyPythonBridge2::RubyPyClass
  def initialize(pyobj)
    @pyobj = pyobj
  end

  def self.create_rubypy_new_instance
      RubyPythonBridge2::RubyPyInstance.new
  end

  def self.create_rubypy_obj(pyobj, *args)
    if args.empty?
      RubyPythonBridge2::RubyPyClass.new pyobj
    else
      self.create_rubypy_new_instance
    end
  end
end


class RubyPythonBridge2::RubyPyInstance
#  def initialize(pyobj, *params)
#  end
end

class RubyPythonBridge2::RubyPyFunction
  def self.create_rubypy_obj(pyobj, *args)
    args_list = RubyPyApi::PyObject.newList(*args.map{|x| RubyPyApi::PyObject.new x})
    args_tuple = RubyPyApi::PyObject.makeTuple args_list
    return pyobj.callObject(args_tuple).rubify
  end
end

class RubyPythonBridge2::RubyPyObjectFactory
  def self.create(pyobj, *args)
    return RubyPythonBridge2::RubyPyClass.create_rubypy_obj(pyobj, *args) if pyobj.isClass
    return RubyPythonBridge2::RubyPyFunction.create_rubypy_obj(pyobj, *args) if pyobj.isCallable
  end
end
