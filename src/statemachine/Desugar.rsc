module statemachine::Desugar
extend DesugarBase;

import IO;
import List;
import String;

import statemachine::AST;

data StateMachine = statemachine( str name, Instance instance, map[ str, list[Param] ] inEvents, map[ str, State ] states );
data Instance = instance( Channels entries, Channels exits, list[StateMachineStat] vars, str currentState );
data State = state( str name, list[ Stat ] entries, Transitions transitions, list[ Stat ] exits );
data Transition = transition( list[Expr] cond, str next ); 
alias Transitions = map[ str name, list[Transition] transitions ];
alias Channels = map[ str event, list[Param] params];

list[StateMachine] compileStateMachines( Module m ) {
	result = [];
	
	visit( m ) {
		case Decl d:stateMachine( _, _, _, _ ) : {
			result += compileStateMachine( namespace_statemachine( d ) );
		} 
	}
	
	return result;
}

StateMachine compileStateMachine( Decl d:stateMachine( _, _, _, _ ) ) {
	return statemachine(
		d.name.name,
		compileInstance( d ),
		compileInEvents( d ),
		compileStates( d )
	);
}

default str extractInitial( _ ) = "";
str extractInitial( [ Id( initial ) ] ) = initial;
Instance compileInstance( Decl d:stateMachine( _, _, list[Id] initial, _ ) ) {
	vars = for( v:var( _, _, _, _ ) <- d.body ) {
		append v;
	} 
	
	entries = exits = ();
	
	for( e:inEvent( _, _ ) <- d.body ) {
		entries[ e.name.name ] = e.params;
	}
	
	return instance( entries, exits, vars, extractInitial( initial ) );
}

map[ str, list[Param] ] compileInEvents( Decl d:stateMachine( _, _, _, _ ) ) {
	result = ();
	
	for( inEvent( id( name ), list[Param] params ) <- d.body ) {
		result[ name ] = params;
	}
	
	return result;
}

map[ str, State ] compileStates( Decl d:stateMachine( _, _, _, _ ) ) {
	result = ();
	for( state( id( name ), list[StateStat] body ) <- d.body ) {
		result[ name ] = compileState( name, body );
	}
	return result;
}

State compileState( str name, list[StateStat] body ) {
	transitions = ();
	entries = exits = [];
	visit( body ) {
		case s:on( _, _, _ ) : { 
			if( s.event.name in transitions ) {
				transitions[ s.event.name ] += transition( s.cond, s.next.name ); 
			} else {
				transitions[ s.event.name ] = [transition( s.cond, s.next.name )];
			} 
		}
		case s:entry( _ ) : { entries += s.body; }
		case s:exit( _ ) : { exits += s.body; } 
	}
	
	return state( name, entries, transitions, exits ); 
}

Id currentState = id( "__currentState" );
Id instanceId = id( "instance" );
Expr instanceVar = var( instanceId );
Expr event = var( id( "event" ) );
Expr arguments = var( id( "arguments" ) );

Module desugar_statemachine( Module m ) {
	list[StateMachine] stateMachines = compileStateMachines( m );
	
	for( s <- stateMachines ) {
		decls = desugar_statemachine( s );
		
		m = visit( m ) {
			case Decl d:stateMachine( _, _, _, _ ) : {
				if( d.name.name == s.name ) {
					insert decls[0];
				}
			} 
		}
		
		m.decls += decls[1..size(decls)];
	}
	
	return m;
}

list[Decl] desugar_statemachine( StateMachine s ) {
	Decl initFunction = createInitialFunction( s );
	Decl execFunction = createExecFunction( s );
	list[Decl] entryExitFunctions = createEntryExitFunctions( s );
	
	return [execFunction] + [initFunction] + entryExitFunctions;
}

Decl createExecFunction( StateMachine s ) {
	params = 
	[ param( [], pointer( id( id( namespace( s.name, "data_t" ) ) ) ), id( "instance" ) ),
	  param( [],          id( id( namespace( s.name, "inevents" ) ) ), id( "event" ) ),
	  param( [], pointer( pointer( \void() ) ), id( "arguments" ) ) ];
	
	return function( 
		[], 
		\void(), 
		id( namespace( s.name, "execute" ) ), 
		params, 
		[createStateSwitch( s )] 
	); 
}

Decl createInitialFunction( StateMachine s ) {
	list[Stat] funBody = [];
	
	if( !isEmpty(s.instance.currentState) ) {
		funBody += [ expr( assign( ptrField( instance, currentState ), var( s.instance.currentState ) ) ) ];	
	}
	 
	funBody += for( var( list[Modifier] mods, Type \type, Id varName, Expr init ) <- s.instance.vars ) {
		append expr( assign( ptrField( instanceVar, varName ), init ) );
	}
	
	// void init( data_t* instance ) { funBody }
	return function( 
		[], 
		\void(), 
		id( namespace( s.name, "init" ) ), 
		[ 
			param( 
				[], 
				pointer( id( id( namespace( s.name, "data_t" ) ) ) ), 
				instanceId 
				) 
		], 
		funBody 
	);
}

Stat createStateSwitch( StateMachine s ) {
	states = for( str name <- s.states ) {
		append \case(
			var( id( name ) ),
			\switch( event, block(
				createStateCases( s, s.states[name] )
			) )
		);
	}
	
	// switch( instance->__currentState ) { states }
	return \switch( ptrField( instanceVar, currentState ), block( states ) );
}

list[Stat] createStateCases( StateMachine s, State state ) {
	return for( str eventName <- state.transitions ) {
		list[Stat] tests = [];
		for( Transition t <- state.transitions[ eventName ] ) {
			i = 0;
			exits = [];
			for( Stat exit <- state.exits ) {
				exits += expr( call( var( id( namespace( s.name, "ExitAction<i>" ) ) ), [instanceVar] ) );
				i += 1;
			}
			
			i = 0;
			entries = [];
			for( Stat entry <- s.states[ t.next ].entries ) {
				entries += expr( call( var( id( namespace( s.name, "EntryAction<i>" ) ) ), [instanceVar] ) );
				i += 1;
			}
			
			tests +=
				ifThen( 
					size(t.cond) > 0 ? createCondition( t.cond[0], s.inEvents[ eventName ], s.instance.vars ) : lit( boolean( "true" ) ), 
					block(
						exits +
						[expr( assign( ptrField( instanceVar, currentState ), var( id( t.next ) ) ) )] +
						entries +
						[\return()]	
					) 
				); 
		}
		
		append \case( 
			var( id( eventName ) ), 
			block( 
				tests
			) 
		);
	}
}

list[Decl] createEntryExitFunctions( StateMachine s ) {
	entries = exits = [];
	for( str stateName <- s.states ) {
		
		i = -1;
		entries = for( list[Stat] body <- s.states[ stateName ].entries ) {
			i += 1;
			append createEntryExitFunction( s, name, stateName, "EntryAction<i>", body ); 
		}
		
		i = -1;
		exits = for( list[Stat] body <- s.states[ stateName ].exits ) {
			i += 1;
			append createEntryExitFunction( s, name, stateName, "ExitAction<i>", body ); 
		}
		
	}
	iprintln( "exits <exits>" );
	return entries + exits;
}

Decl createEntryExitFunction( StateMachine s, str name, str stateName, str actionName, list[Stat] body ) {
	return function(
		[static(),inline()],
		\void(),
		id( namespace( name, "<stateName>_<actionName>"  ) ),
		[ param( [], pointer( id( namespace( name, "data_t" ) ) ), instanceId ) ],
		createEntryExitBody( s, body )
	);
}

list[Stat] createEntryExitBody( StateMachine s, list[Stat] body ) {
	return visit( body ) {
		case var( id( name ) ) : {
			for( v:var(_,_,_,_) <- s.instance.vars, v.name.name == name ) {
				insert ptrField( instanceVar, id( name ) );
			}
		}
	}
}

Expr createCondition( Expr cond, list[Param] params, list[StateMachineStat] vars ) {
	return visit( cond ) {
		case var( id( varName ) ) : {
			i = 0;
			for( param( _, Type \type, id( paramName ) ) <- params ) {
				if( paramName == varName ) {
					// *((\type*)((arguments[i])))
					insert refOf( cast( pointer( \type ), subscript( arguments, lit( \int( "<i>" ) ) ) ) );
				} else {
					i += 1;
				}
			}
			
			for( s:var( _, _, id( name ), _ ) <- vars ) {
				if( name == varName ) {
					insert ptrField( instanceVar, id( name ) );
				}
			}
		}
	}
}


Decl namespace_statemachine( Decl d:stateMachine( _, id( name ), _, _ ) ) {
	return visit( d ) {
		case s:state( id( stateName ), _ ) : { 
			s.name = id("StateMachines_<name>__states__<name>_<stateName>__state");
			insert s; 
		}
		case s:on( id( eventName ), _, id( nextStateName ) ) : {
			s.event = id("StateMachines_<name>__inevents__<name>_<eventName>__event");
			s.next =  id("StateMachines_<name>__states__<name>_<nextStateName>__state");
			insert s;
		}
		case s:inEvent( id( eventName ), _ ) : {
			s.name = id("StateMachines_<name>__inevents__<name>_<eventName>__event");
			insert s;
		}
	}
}

str namespace( str name, str i ) ="StateMachines_<name>__<i>";

Decl desugar_on_conditions( Decl d:stateMachine( _, id( name ), _, _ ) ) {
	inEvents = ();
	for( inEvent( id( eventName ), list[Param] params ) <- d.body ) {
		inEvents[ eventName ] = params;
	}
	
	return visit( d ) {
		case s:on( id( eventName ), list[Expr] cond, _ ) : {
			if( size(cond) > 0 ) {
				params = inEvents[ eventName ];
				
				s.cond = [desugar_condition( s.cond[0], params )];
				
				insert s;
			}
		}
	}
}
