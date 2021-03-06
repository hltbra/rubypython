#include "rp_blankobject.h"

RUBY_EXTERN VALUE mRubyPythonBridge;

VALUE cBlankObject;

// :nodoc:
/* This functions is used as a predicate function. Every function name
for which it returns true will be removed from the blank object
dictionary.
*/
VALUE blank_undef_if(VALUE name, VALUE klass)
{
	VALUE mname = rb_funcall(name, rb_intern("to_s"), 0);
	VALUE methodRe = rb_str_new2("(?:^__)|(?:\\?$)|(?:^send$)|(?:^class$)");
	
	if(rb_funcall(mname, rb_intern("match"), 1, methodRe) == Qnil)
	{
		rb_undef_method(klass, STR2CSTR(mname));
		return Qtrue;
	}
	else
	{
		return Qfalse;
	}
}

// :nodoc:
VALUE blank_obj_prep(VALUE self)
{
	VALUE instance_methods = rb_funcall(self, rb_intern("instance_methods"), 0);
	
	rb_iterate(rb_each, instance_methods, blank_undef_if, self);
	return self;
}

// :nodoc:
inline void Init_BlankObject()
{
	cBlankObject = rb_define_class_under(mRubyPythonBridge,"BlankObject", rb_cObject);
	blank_obj_prep(cBlankObject);
}