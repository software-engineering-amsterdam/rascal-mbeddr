module TypeChecker

import lang::mbeddr::AST;

extend baseextensions::TypeChecker;
extend unittest::TypeChecker;
extend statemachine::TypeChecker;

extend statemachine::typing::resolver::Helper;
extend typing::indexer::Helper;
extend typing::constraints::Helper;

Module runTypeChecker( Module m ) { 
	m = createIndexTable( m );
	m = constraints( m );
	m = resolver( m );
	return m;
}

public map[loc,Message] collectMessages( Module m ) {
	result = ();
	
	visit( m ) {
		case &T <: node n : {
			if( "message" in getAnnotations( n ) ) {
				result[n@location] = n@message;
			}
		}
	}
	
	return result;
}


bool hasErrors( Module m ) {
	visit( m ) {
		case &T <: node n : {
			if( "message" in getAnnotations( n ) && error(_,_) := n@message ) {
				return true;
			}
		}
	}
	
	return false;
}
