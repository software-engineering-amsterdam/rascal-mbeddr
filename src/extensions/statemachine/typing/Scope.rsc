module extensions::statemachine::typing::Scope
extend core::typing::Scope;

data Scope
	= stateMachine( Scope s )
	;
	
bool inStateMachine( Scope s ) = (/stateMachine(_) := s);