module statemachine::AST
extend lang::mbeddr::AST;

import statemachine::typing::IndexTable;

anno loc StateMachineStat@location;
anno loc StateStat@location;

anno Message StateMachineStat@message;
anno Message StateStat@message;

data Decl = stateMachine( list[Modifier] mods, Id name, list[Id] initial, list[StateMachineStat] body );

data StateMachineStat 
	= state( Id name, list[StateStat] body )
	| var( list[Modifier] mods, Type \type, Id name, Expr init )
	| inEvent( Id name, list[Param] params )
	| outEvent( Id name, list[Param] params, Id ref )
	;

data StateStat
	= on( Id event, list[Expr] cond, Id next )
	| on( Id event, list[Expr] cond, Id next, list[Stat] body )
	| entry( list[Stat] body )
	| exit( list[Stat] body )
	; 
	
data Stat
	= send( Id name, list[Expr] args )
	;

data Modifier
	= readable()
	;
	
data Type
	= stateMachine( str stateMachineName )
	| state()
	| inEvent( list[Param] params )
	| outEvent( list[Type] args )
	;