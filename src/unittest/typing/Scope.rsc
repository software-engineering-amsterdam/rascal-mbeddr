module unittest::typing::Scope
extend typing::Scope;

data Scope
	= \test( Scope scope )
	;

bool inTest( Scope s ) {
	visit( s ) {
		case \test( _ ) : return true;
	}
	return false;
}