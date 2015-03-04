module statemachine::AST
extend lang::mbeddr::AST;

data Decl = stateMachine( list[Modifier] mods, Id name, list[Id] initial, list[StateMachineStat] body );

data StateMachineStat 
	= state( Id name, list[StateStat] body )
	| var( list[Modifier] mods, Type \type, Id name, Expr init )
	;

data StateStat
	= on( Id event, list[Expr] expr, Id next )
	| entry( list[Stat] body )
	| exit( list[Stat] body )
	; 
	
data Modifier
	= readable()
	;
	
data Type
	= stateMachine()
	;