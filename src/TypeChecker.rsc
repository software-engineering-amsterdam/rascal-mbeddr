module TypeChecker

import lang::mbeddr::AST;
import typing::TypeMessage;

extend extensions::baseextensions::TypeChecker;
extend extensions::unittest::TypeChecker;
extend extensions::statemachine::TypeChecker;

extend extensions::statemachine::typing::resolver::Helper;
extend typing::indexer::Helper;
extend typing::constraints::Helper;

Module runTypeChecker( Module m ) { 
	m = createIndexTable( m );
	m = constraints( m );
	m = resolver( m );
	return m;
}

private default Message convertMessage( Message msg ) = msg;
private Message convertMessage( Message m:error( _, str msg, loc at ) ) = error( msg, at );

public map[loc,Message] collectMessages( Module m ) {
	result = ();
	
	visit( m ) {
		case &T <: node n : {
			if( "message" in getAnnotations( n ) ) {
				result[n@location] = convertMessage( n@message );
			}
		}
	}
	
	return result;
}

public map[loc,loc] collectLinks( Module m ) {
	result = ();
	
	visit( m ) {
		case &T <: node n : {
			if( "link" in getAnnotations( n ) ) {
				result[n@location] = n@link;
			}
		}
	}
	
	return result;
}


bool hasErrors( Module m ) {
	visit( m ) {
		case &T <: node n : {
			if( "message" in getAnnotations( n ) ) {
				return true;
			}
		}
	}
	
	return false;
}
