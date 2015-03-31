module extensions::unittest::typing::Scope
extend core::typing::Scope;

data Scope
	= \test( Scope scope )
	;

bool inTest( Scope s ) = (/\test(_) := s );