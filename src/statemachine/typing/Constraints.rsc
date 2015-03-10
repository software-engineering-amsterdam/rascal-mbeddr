module statemachine::typing::Constraints
extend typing::Constraints;

import Node;

import statemachine::AST;

StateStat constraint( StateStat s:entry(_) ) {
	s.body = removeSendMessage( s.body );
	return s;
}

StateStat constraint( StateStat s:exit(_) ) {
	s.body = removeSendMessage( s.body );
	return s;
} 

private list[Stat] removeSendMessage( list[Stat] body ) {
	return for( Stat stat <- body ) {
		if( send(_,_) := stat ) {
			stat = delAnnotation( stat, "message" );
		}
		append stat;
	}
}

Stat constraint( Stat s:send( _, _ ) ) {
	return s[@message=error("send statement is constrained to entry or exit bodies",s@location)];
}