module extensions::statemachine::typing::Constraints
extend typing::constraints::Constraints;

import Node;

import extensions::statemachine::AST;

StateStat constraint( StateStat s:entry(_) ) = s[body = removeSendMessage( s.body )];

StateStat constraint( StateStat s:exit(_) ) = s[body = removeSendMessage( s.body )];

private list[Stat] removeSendMessage( list[Stat] body ) = [ checkSend( stat ) | Stat stat <- body ];

private default Stat checkSend( Stat s ) = s;
private Stat checkSend( Stat s:send(_,_) ) = delAnnotation( s, "message" );

Stat constraint( Stat s:send( _, _ ) ) {
	return s[@message=error("send statement is constrained to entry or exit bodies",s@location)];
}