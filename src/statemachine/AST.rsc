module statemachine::AST
extend lang::mbeddr::AST;

anno loc StateMachineStat@location;
anno loc StateStat@location;

data Decl = stateMachine( list[Modifier] mods, Id name, list[Id] initial, list[StateMachineStat] body );

data StateMachineStat 
	= state( Id name, list[StateStat] body )
	| var( list[Modifier] mods, Type \type, Id name, Expr init )
	| inEvent( Id name, list[Param] params )
	;

data StateStat
	= on( Id event, list[Expr] cond, Id next )
	| entry( list[Stat] body )
	| exit( list[Stat] body )
	; 
	
data Modifier
	= readable()
	;
	
data Type
	= stateMachine()
	| state()
	;