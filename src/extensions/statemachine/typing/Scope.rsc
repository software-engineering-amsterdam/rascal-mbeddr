module extensions::statemachine::typing::Scope
extend typing::Scope;

data Scope
	= stateMachine( Scope s )
	;
	
bool inStateMachine( Scope s ) = (/stateMachine(_) := s);