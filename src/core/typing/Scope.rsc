module core::typing::Scope

data Scope 
	= global( )
	| function( Scope scope )
	| block( Scope scope )
	| \switch( Scope scope )
	;
	
bool inSwitch( Scope s ) = (/\switch(_) := s);
bool inGlobal( Scope s ) = global() := s;

