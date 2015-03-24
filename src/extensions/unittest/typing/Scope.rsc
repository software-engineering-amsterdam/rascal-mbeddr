module extensions::unittest::typing::Scope
extend typing::Scope;

data Scope
	= \test( Scope scope )
	;

bool inTest( Scope s ) = (/\test(_) := s );