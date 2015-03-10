module statemachine::typing::Resolver
extend typing::Resolver;

import statemachine::AST;
import statemachine::typing::IndexTable;

default StateStat resolve( StateStat s ) = s;
default StateMachineStat resolve( StateMachineStat s ) = s;

StateMachineStat resolve( StateMachineStat s:outEvent( id( name ), list[Param] params, id( ref ) ) ) {
	symbols = s@symboltable;
	
	if( ref in symbols ) {
		
		if( Type t:function(_,_) := symbols[ ref ].\type ) {
			
			if( parameterTypes(params) != t.args ) {
				s@message = error( "wrong argument type(s)", s@location );
			} 
			
		} else {
			s@message = error( "\'<ref>\' is not a function, but \'<typeToString(symbols[ref].\type)>\'", s@location );
		}
		
	} else {
		s@message = error( "unkown function \'<ref>\'", s@location );
	}
	
	return s;
}

Stat resolve( Stat s:send( id( name ), list[Expr] args ) ) {
	symbols = s@symboltable;
	
	if( name in symbols ) {
	
		if( outEvent( list[Type] argsTypes ) := symbols[ name ].\type ) {
			
			if( size( argsTypes ) != size( args ) ) {
				s@message = error( "too many arguments to out event call, expected <size(argsTypes)>, have <size(args)>", s@location );
			} else {
			
				for( i <- [0..size( argsTypes )] ) {
					arg_type = getType( args[i] );
					if( !isEmpty( arg_type ) && !(argsTypes[i] in CTypeTree[ arg_type ]) ) {
						s@message = error( "wrong argument type(s)", s@location );
					}
				}
			
			}
			
		} else {
			s@message = error( "\'<name>\' is not an out event, but \'<typeToString(symbols[name].\type)>\'", s@location );
		} 
	
	} else {
		s@message = error( "unkown out event \'<name>\'", s@location );
	}
	
	return s;
}

StateStat resolve( StateStat s:on( Id event, list[Expr] cond, Id next, list[Stat] body ) ) {
	return resolve_on( s, event, cond, next ); 
}
StateStat resolve( StateStat s:on( Id event, list[Expr] cond, Id next ) ) {
	return resolve_on( s, event, cond, next ); 
}
private StateStat resolve_on( StateStat s, id( event ), list[Expr] cond, id( next ) ) {
	symbols = s@symboltable;
	
	if( event in symbols ) {
		
		if( inEvent(_) := symbols[event].\type ) {
			
			if( size(cond) > 0 ) { 
				e = cond[0];
				expr_type = getType( e );
				
				if( ! isEmpty( expr_type ) && !(boolean() := expr_type) ) { 
					e@message = error( "expression expected to be of \'boolean\' type", e@location );
					s.cond = [e];
				}
			}
			
			if( !( next in symbols && symbols[ next ].\type == state() ) ) {
				s.next@message = error( "unknown event \'<next>\'", s@location );
			}
			
		} else {
			s@message = error( "\'<event>\' is not an in event, but \'<typeToString(symbols[event].\type)>\'", s@location );
		}
		
	} else {
		s@message = error( "unkown in event \'<event>\'", s@location );	
	}
	
	return s;
}

Decl resolve( Decl d:stateMachine( list[Modifier] mods, Id name, list[Id] initial, list[StateMachineStat] body ) ) {
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

StateMachineStat resolve( StateMachineStat s:var( list[Modifier] mods, Type \type, Id name, Expr init ) ) {
	init_type = getType( init );
	
	if( isEmpty( init_type ) ) { return s; }
	
	if( !(\type in CTypeTree[ init_type ]) ) {
		s@message = error( "\'<typeToString(init_type)>\' not a subtype of \'<typeToString(\type)>\'", s@location );
	}
	
	return s;
}

Expr resolve( Expr e:call( e2:dotField( Expr record, Id name ), list[Expr] args ) ) {
	record_type = getType( record );
	
	iprintln( record_type );
	
	return e;
}