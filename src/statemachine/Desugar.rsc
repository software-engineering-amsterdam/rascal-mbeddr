module statemachine::Desugar
extend DesugarBase;

import IO;
import String;
import ext::List;
import ext::Node;

import util::Util;
import statemachine::AST;
import statemachine::typing::IndexTable;
import statemachine::typing::Resolver;

data StateMachine = statemachine( str name, Instance instance, map[ str, list[Param] ] inEvents, map[ str, State ] states );
data Instance = instance( Channels entries, Channels exits, list[StateMachineStat] vars, str currentState );
data State = state( str name, list[ Stat ] entries, Transitions transitions, list[ Stat ] exits );
data Transition = transition( list[Expr] cond, str next, list[Stat] body ); 
alias Transitions = map[ str name, list[Transition] transitions ];
alias Channels = map[ str event, list[Param] params];

StateMachine compile_statemachine( Decl d:stateMachine( _, _, _, _ ) ) {
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
		case s:on( _, _, _ ) : { transitions = putInMap( transitions, s.event.name, transition( s.cond, s.next.name, [] ) ); }
		case s:on( _, _, _, _ ) : { transitions = putInMap( transitions, s.event.name, transition( s.cond, s.next.name, s.body ) ); }
		case s:entry( _ ) : { entries += block(s.body); }
		case s:exit( _ ) : { exits += block(s.body); } 
	}
	
	return state( name, entries, transitions, exits ); 
}

Id currentState = id( "__currentState" );
Id instanceId = id( "instance" );
Expr instanceVar = var( instanceId );
Expr event = var( id( "event" ) );
Expr arguments = var( id( "arguments" ) );

Module desugar_statemachine( Module m ) {
	decls = [];
	
	visit( m ) {
		case Decl d:stateMachine( _, _, _, _ ) : {
			decls = desugar_statemachine( d, compile_statemachine( d ) );
			
			m.decls = insertListFor( m.decls, indexOf( m.decls, d ), decls );
		} 
	}
	
	return m;
}

list[Decl] desugar_statemachine( Decl d:stateMachine( _, _, _, _ ), StateMachine s ) {
	Decl initFunction = createInitialFunction( d, s );
	Decl execFunction = createExecFunction( d, s );
	list[Decl] headerConstructs = createHeader( d, s );
	list[Decl] entryExitFunctions = createEntryExitFunctions( s );
	
	result = headerConstructs + entryExitFunctions + [execFunction, initFunction];
	
	if( exported() in d.mods ) {
		result += function( execFunction.mods, execFunction.\type, execFunction.name, execFunction.params )[@header=true];
		result += function( initFunction.mods, initFunction.\type, initFunction.name, initFunction.params )[@header=true];
	}
	
	return result;
}

list[Decl] createHeader( Decl d:stateMachine(_,_,_,_), StateMachine s ) {
	result = [];
	result += typeDef( d.mods, enum( id( namespace( s.name, "states" ) ) ), id( "__" + namespace( s.name, "states" ) ) );
	
	// States Enumerable
	enums = for( str stateName <- s.states ) {
		append const( id( namespace_state( s.name, stateName ) ) );
	}
	result += enum( d.mods, id( namespace( s.name, "states" ) ), enums );
	
	// Inevents Enumerable
	result += typeDef( d.mods, enum( id( namespace( s.name, "inevents" ) ) ), id( "__" + namespace( s.name, "inevents" ) ) );
	enums = for( str eventName <- s.instance.entries ) {
		append const( id( namespace_event( s.name, eventName ) ) );
	} 
	
	result += enum( d.mods, id( namespace( s.name, "inevents" ) ), enums );
	
	// Data structs
	result += typeDef( d.mods, enum( id( namespace( s.name, "data_t" ) ) ), id( "__" + namespace( s.name, "data_t" ) ) );
	list[Field] fields = [ field( id( id( namespace( s.name, "state" ) ) ), currentState ) ];
	fields += for( var( _, Type \type, Id name, Expr init ) <- s.instance.vars ) {
		append field( \type, name ); 
	}
	
	result += struct( d.mods, id( namespace( s.name, "data" ) ), fields ); 
	
	return result;
}

Decl createExecFunction( Decl d:stateMachine(_,_,_,_), StateMachine s ) {
	params = 
	[ param( [], pointer( id( id( namespace( s.name, "data_t" ) ) ) ), id( "instance" ) ),
	  param( [],          id( id( namespace( s.name, "inevents" ) ) ), id( "event" ) ),
	  param( [], pointer( pointer( \void() ) ), id( "arguments" ) ) ];
	
	return function( 
		d.mods, 
		\void(), 
		id( namespace( s.name, "execute" ) ), 
		params, 
		[createStateSwitch( s )] 
	); 
}

Decl createInitialFunction( Decl d:stateMachine(_,_,_,_), StateMachine s ) {
	list[Stat] funBody = [];
	
	if( !isEmpty(s.instance.currentState) ) {
		funBody += [ expr( assign( ptrField( instance, currentState ), var( s.instance.currentState ) ) ) ];	
	}
	 
	funBody += for( var( list[Modifier] mods, Type \type, Id varName, Expr init ) <- s.instance.vars ) {
		append expr( assign( ptrField( instanceVar, varName ), init ) );
	}
	
	// void init( data_t* instance ) { funBody }
	return function( 
		d.mods, 
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
			var( id( namespace_state( s.name, name ) ) ),
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
					size(t.cond) > 0 ? createParamVarReference( t.cond[0], s.inEvents[ eventName ], s.instance.vars ) : lit( boolean( "true" ) ), 
					block(
						[ createParamVarReference( block( t.body ), s.inEvents[ eventName ], s.instance.vars ) ] +
						exits +
						[expr( assign( ptrField( instanceVar, currentState ), var( id( t.next ) ) ) )] +
						entries +
						[\return()]	
					) 
				); 
		}
		
		append \case( 
			var( id( namespace_event( s.name, eventName ) ) ), 
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
		
		for( block( body ) <- s.states[ stateName ].entries ) {
			i += 1;
			entries += createEntryExitFunction( s, s.name, stateName, "EntryAction<i>", body );
		}
		
		i = -1;
		for( block( body ) <- s.states[ stateName ].exits ) {
			i += 1;
			exits += createEntryExitFunction( s, s.name, stateName, "ExitAction<i>", body ); 
		}
		
	}
	return entries + exits;
}

Decl createEntryExitFunction( StateMachine s, str name, str stateName, str actionName, list[Stat] body ) {
	return function(
		[static(),inline()],
		\void(),
		id( namespace( name, "<stateName>_<actionName>"  ) ),
		[ param( [], pointer( id( id( namespace( name, "data_t" ) ) ) ), instanceId ) ],
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

&T <: node createParamVarReference( &T <: node n, list[Param] params, list[StateMachineStat] vars ) {
	return visit( n ) {
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
str namespace_state( str name, str i ) = "StateMachines_<name>__states__<name>_<i>__state";
str namespace_event( str name, str i ) = "StateMachines_<name>__inevents__<name>_<i>__event";

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

Decl desugar( Decl d:variable(list[Modifier] mods, id( id( typeName ) ), Id name) ) {
	if( typeName in d@symboltable && stateMachine(_) := d@symboltable[ typeName ].\type ) {
		d.\type =  id( id( namespace( typeName, "data_t" ) ) );
		d.name = name;
	}
	
	return d; 
}

Expr desugar( Expr e:dotField( Expr record, id( str name ) ) ) {
	e_type = getType( e );
	record_type = getType( record );
	
	if( stateMachine( str stateMachineName ) := record_type && state() := e_type ) {
		e = var( id( namespace_state( stateMachineName, name ) ) );
	}
	
	return e;
}

Stat desugarTrigger( Expr record, str stateMachineName, str eventName, list[Expr] args ) {
	list[Stat] bl = [];
	i = 1;
	for( arg <- args ) {
		bl += expr( assign( refOf( subscript( var( id( "___args" ) ), lit( \int( "<i>" ) ) ) ), addrOf( arg ) ) );
		i += 1;
	}
	Expr callFun = var( id( namespace( stateMachineName, "execute" ) ) );
	list[Expr] callArgs = [ addrOf( record ), var( id( namespace_event( stateMachineName, eventName ) ) ), var( id( "___args" ) ) ];
	bl += expr( call( callFun, callArgs ) );
	return block( bl );
}

default Stat desugarDotFieldCall( Type t:stateMachine( str stateMachineName ), Expr record, str eventName, list[Expr] args ) {
	return desugarTrigger( record, stateMachineName, eventName, args );
}

Stat desugarDotFieldCall( Type t:stateMachine( str stateMachineName ), Expr record, "init", [] ) {
	e = call( var( id( namespace( stateMachineName, "init" ) ) ), [ addrOf(record) ] );
	return expr( e );
}

Stat desugarDotFieldCall( Type t:stateMachine( str stateMachineName ), Expr record, "setState", [ dotField( Expr record, id( stateName ) ) ] ) {
	e =  assign( dotField( record, currentState ), var( id( namespace_state( stateMachineName, stateName ) ) ) );
	return expr( e );
}

Stat desugarDotFieldCall( Type t:stateMachine( str stateMachineName ), Expr record, "isInState", [ dotField( Expr record, id( stateName ) ) ]  ) {
	e = eq( dotField( record, currentState ), var( id( namespace_state( stateMachineName, stateName ) ) ) );
	return expr( e );
}
