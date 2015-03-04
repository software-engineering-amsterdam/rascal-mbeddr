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

bool sameFunctionScope( Scope s1, Scope s2 ) {
	funsS1 = 0;
	funsS2 = 0;
	
	visit( s1 ) {
		case function(_) : { funsS1 += 1; }
	}
	
	visit( s2 ) {
		case function(_) : { funsS2 += 1; }
	}
	
	return funsS2 == funsS1;
}
