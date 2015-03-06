module statemachine::typing::Evaluator
extend typing::Evaluator;

import statemachine::AST;
import statemachine::typing::IndexTable;

default StateStat evaluate( StateStat s ) = s;
default StateMachineStat evaluate( StateMachineStat s ) = s;

StateStat evaluate( StateStat s:on( id( event ), list[Expr] cond, id( next ) ) ) {
	if( size(cond) > 0 ) { 
		e = cond[0];
		expr_type = getType( e );
		
		if( ! isEmpty( expr_type ) && !(boolean() := expr_type) ) { 
			e@message = error( "expression expected to be of \'boolean\' type", e@location );
			s.cond = [e];
		}
	}
	
	if( !( next in s@symboltable && s@symboltable[ next ].\type == state() ) ) {
		s.next@message = error( "uknown event \'<next>\'", s@location );
	}
	
	return s;
}

Decl evaluate( Decl d:stateMachine( list[Modifier] mods, Id name, list[Id] initial, list[StateMachineStat] body ) ) {
	if( size(initial) > 0 ) {
		initialState = initial[0];
		symbols = body[0]@symboltable;

		if( !(initialState.name in symbols) ) {
			initialState@message = error( "undefined initial state \'<initialState.name>\'", initialState@location );
		} else if( initialState.name in symbols && symbols[ initialState.name ].\type != state() ) {
			initialState@message = error( "initial state \'<initialState.name>\' is not of the type \'state\'", initialState@location );
		}
		
		d.initial = [initialState];
	}
	
	return d;
}

StateMachineStat evaluate( StateMachineStat s:var( list[Modifier] mods, Type \type, Id name, Expr init ) ) {
	init_type = getType( init );
	
	if( isEmpty( init_type ) ) { return s; }
	
	if( !(\type in CTypeTree[ init_type ]) ) {
		s@message = error( "\'<typeToString(init_type)>\' not a subtype of \'<typeToString(\type)>\'", s@location );
	}
	
	return s;
}