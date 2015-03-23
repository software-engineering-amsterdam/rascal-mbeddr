module typing::Scope

data Scope 
	= global( )
	| function( Scope scope )
	| block( Scope scope )
	| \switch( Scope scope )
	;
	
bool inSwitch( Scope s ) {
	visit( s ) {
		case \switch(_) : return true;
	}
	
	return false;
}

bool inGlobal( Scope s ) = global() := s;

