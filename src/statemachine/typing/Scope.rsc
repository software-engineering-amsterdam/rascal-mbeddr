module statemachine::typing::Scope
extend typing::Scope;

data Scope
	= stateMachine( Scope s )
	;
	
bool inStateMachine( Scope s ) {
	visit( s ) {
		case stateMachine(_) : return true;
	}
	return false;
}