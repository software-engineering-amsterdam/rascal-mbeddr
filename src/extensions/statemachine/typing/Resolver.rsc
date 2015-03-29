module extensions::statemachine::typing::Resolver
extend typing::Resolver;

import extensions::statemachine::AST;
import extensions::statemachine::typing::IndexTable;

default StateStat resolve( StateStat s ) = s;
default StateMachineStat resolve( StateMachineStat s ) = s;

StateMachineStat resolve( StateMachineStat s:outEvent( id( name ), list[Param] params, id( ref ) ) ) {
	table = s@indextable;
	
	if( contains( table, symbolKey(ref) ) ) {
		
		if( Type t:function(_,_) := lookup( table, symbolKey(ref) ).\type ) {
			
			if( parameterTypes(params) != t.args ) {
				s@message = error( argumentsMismatchError(), "wrong argument type(s)", s@location );
			} 
			
		} else {
			s@message = error( functionReferenceError(), "\'<ref>\' is not a function, but \'<typeToString( lookup( table, symbolKey(ref) ).\type)>\'", s@location );
		}
		
	} else {
		s@message = error( referenceError(), "unkown function \'<ref>\'", s@location );
	}
	
	return s;
}

Stat resolve( Stat s:send( id( name ), list[Expr] args ) ) {
	table = s@indextable;
	
	if( contains( table, symbolKey( name ) ) ) {
	
		if( outEvent( list[Type] argsTypes ) := lookup( table, symbolKey( name ) ).\type ) {
			
			if( size( argsTypes ) != size( args ) ) {
				s@message = error( argumentsMismatchError(), "too many arguments to out event call, expected <size(argsTypes)>, have <size(args)>", s@location );
			} else {
			
				for( i <- [0..size( argsTypes )] ) {
					argType = getType( args[i] );
					if( !isEmpty( argType ) && !(argsTypes[i] in CTypeTree[ argType ]) ) {
						s@message = error( argumentsMismatchError(), "wrong argument type(s)", s@location );
					}
				}
			
			}
			
		} else {
			s@message = error( typeMismatchError(), "\'<name>\' is not an out event, but \'<typeToString( lookup( table, symbolKey(name) ).\type )>\'", s@location );
		} 
	
	} else {
		s@message = error( referenceError(), "unkown out event \'<name>\'", s@location );
	}
	
	return s;
}

StateStat resolve( StateStat s:on( Id event, list[Expr] cond, Id next, list[Stat] body ) ) {
	return resolveOn( s, event, cond, next ); 
}
StateStat resolve( StateStat s:on( Id event, list[Expr] cond, Id next ) ) {
	return resolveOn( s, event, cond, next ); 
}
private StateStat resolveOn( StateStat s, id( event ), list[Expr] cond, id( next ) ) {
	table = s@indextable;
	
	if( contains( table, symbolKey( event ) ) ) {
		
		if( inEvent(_) := lookup( table, symbolKey( event ) ).\type ) {
			
			if( size(cond) > 0 ) { 
				e = cond[0];
				exprType = getType( e );
				
				if( ! isEmpty( exprType ) && !(boolean() := exprType) ) { 
					e@message = error( conditionalAbuseError(), "expression expected to be of \'boolean\' type", e@location );
					s.cond = [e];
				}
			}
			
			if( !( contains( table, symbolKey(next) ) && lookup( table, symbolKey(next) ).\type == state() ) ) {
				s.next@message = error( referenceError(), "unknown event \'<next>\'", s@location );
			}
			
		} else {
			s@message = error( typeMismatchError(), "\'<event>\' is not an in event, but \'<typeToString(lookup( table, symbolKey(event) ).\type)>\'", s@location );
		}
		
	} else {
		s@message = error( referenceError(), "unkown in event \'<event>\'", s@location );	
	}
	
	return s;
}

Decl resolve( Decl d:stateMachine( list[Modifier] mods, Id name, list[Id] initial, list[StateMachineStat] body ) ) {
	if( size(initial) > 0 ) {
		initialState = initial[0];
		table = body[0]@indextable;

		if( !contains( table, symbolKey(initialState.name) ) ) {
			initialState@message = error( referenceError(), "undefined initial state \'<initialState.name>\'", initialState@location );
		} else if( contains( table, symbolKey(initialState.name) ) && lookup( table, symbolKey(initialState.name) ).\type != state() ) {
			initialState@message = error( typeMismatchError(), "initial state \'<initialState.name>\' is not of the type \'state\'", initialState@location );
		}
		
		d.initial = [initialState];
	}
	
	return d;
}

StateMachineStat resolve( StateMachineStat s:var( list[Modifier] mods, Type \type, Id name, Expr init ) ) {
	initType = getType( init );
	
	if( isEmpty( initType ) ) { return s; }
	
	if( !(\type in CTypeTree[ initType ]) ) {
		s@message = error( incompatibleTypesError(), "\'<typeToString(initType)>\' not a subtype of \'<typeToString(\type)>\'", s@location );
	}
	
	return s;
}

IndexTable convertInEventToFunction( IndexTable table, str name ) {
	if( contains( table, symbolKey(name) ) && inEvent( params ) := lookup( table, symbolKey( name ) ).\type ) {
		table = update( table, symbolKey(name), lookup( table, symbolKey(name) )[\type=function( \void(), [ t | param(_,t,_) <- params ] )] );
	}
	
	return table;
}
Expr resolve( Expr e:call( e2:dotField( Expr record, id( name ) ), list[Expr] args ) ) {
	recordType = getType( record );
	e.func = var( id( name ) );

	if( stateMachine( str stateMachineName ) := recordType ) {
		symbols = lookup( e@indextable, objectKey( stateMachineName ) ).symbols;
		symbols = convertInEventToFunction( symbols, name );
		
		e2 = delAnnotation( e2, "message" );
		e = resolveCall( e, symbols );
	}
	
	e.func = e2;
	return e;
}

public Expr resolveField( Expr e, stateMachine( str stateMachineName ), str name ) {
	symbols = lookup( e@indextable, objectKey( stateMachineName ) ).symbols;

    if( contains( symbols, symbolKey(name) ) ) {
    
        e@\type = lookup( symbols, symbolKey(name) ).\type;
    } else {
        e@message = error( fieldReferenceError(), "unkown statemachine property \'<name>\' for statemachine \'<stateMachineName>\'", e@location );
    } 
    return e;
}
