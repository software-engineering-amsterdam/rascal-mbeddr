module extensions::baseextensions::typing::Scope
extend core::typing::Scope;

data Scope
	= comprehension( Scope scope )
	;