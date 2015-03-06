module statemachine::Desugar
extend DesugarBase;

import IO;
import List;

import statemachine::AST;

data StateMachine = statemachine( Instance instance, map[ str, list[Param] ] inEvents, map[ str, State ] states );
data Instance = instance( list[StateMachineStat] vars, str currentState );
data State = state( list[ Stat ] entries, list[ StateStat ] transitions, list[ Stat ] exits );

list[StateMachine] compileStateMachines( Module m ) {
	result = [];
	
	visit( m ) {
		case Decl d:stateMachine( _, _, _, _ ) : {
			result += compileStateMachine( d );
		} 
	}
	
	return result;
}

StateMachine compileStateMachine( Decl d:stateMachine( _, _, _, _ ) ) {
	return statemachine(
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
	
	return instance( vars, extractInitial( initial ) );
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
		result[ name ] = compileState( body );
	}
	return result;
}

State compileState( list[StateStat] body ) {
	transitions = entries = exits = [];
	visit( body ) {
		case s:on( _, _, _ ) : { transitions += s; }
		case s:entry( _, _, _ ) : { entries += s.body; }
		case s:exit( _, _, _ ) : { exits += s.body; } 
	}
	
	return state( entries, transitions, exits ); 
}

Id currentState = id( "__currentState" );
Id instanceId = id( "instance" );
Expr instanceVar = var( instanceId );
Expr event = var( id( "event" ) );
Expr arguments = var( id( "arguments" ) );

Module desugar_statemachine( Module m ) {

	visit( m ) {
		case Decl d:stateMachine( _, _, _, _ ) : {
			decls = desugar_statemachine( d );
			
			m.decls = (m.decls - d) + decls;
		} 
	}
	
	return m;
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

Expr desugar_condition( Expr cond, list[Param] params ) {
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
		}
	}
}

list[Decl] desugar_statemachine( Decl d:stateMachine( list[Modifier] mods, id( name ), list[Id] initial, list[StateMachineStat] body ) ) {
	d = desugar_on_conditions( d );
	d = namespace_statemachine( d );
	
	params = 
	[ param( [], pointer( id( id( namespace( name, "data_t" ) ) ) ), id( "instance" ) ),
	  param( [],          id( id( namespace( name, "inevents" ) ) ), id( "event" ) ),
	  param( [], pointer( pointer( \void() ) ), id( "arguments" ) ) ];
	
	Decl executeFunction = function( [], \void(), id( namespace( name, "execute" ) ), params, [desugarStates( d.body )] );
	Decl initFunction = createInitialFunction( d );
	
	return [ executeFunction, initFunction ]; 
}

Decl createInitialFunction( Decl d:stateMachine( _, id( name ), list[Id] initial, _ ) ) {
	list[Stat] funBody = [];
	
	if( !isEmpty(initial) ) {
		funBody += [ expr( assign( ptrField( instance, currentState ), var( initial[0] ) ) ) ];	
	}
	 
	funBody += for( var( list[Modifier] mods, Type \type, Id varName, Expr init ) <- d.body ) {
		append expr( assign( ptrField( instance, varName ), init ) );
	}
	
	// void init( data_t* instance ) { funBody }
	return function( 
		[], 
		\void(), 
		id( namespace( name, "init" ) ), 
		[ 
			param( 
				[], 
				pointer( id( id( namespace( name, "data_t" ) ) ) ), 
				instanceId 
				) 
		], 
		funBody 
	);
}

Stat desugarStates( list[StateMachineStat] body ) {
	states = for( s:state( Id name, list[StateStat] body ) <- body ) {
		
		append \case( 
			var( name ), 
			\switch( event, block( 
				desugarOn( s )
			) )
		);
	}
	
	// switch( instance->__currentState ) { states }
	return \switch( ptrField( instance, currentState ), block(states) );
}

list[Stat] desugarEntryExit( list[StateStat] body ) {
	i = -1;
	for( entry( list[Stat] body ) <- body ) {
		i += 1;
		append
		function(
			[static(),inline()],
			\void(),
			id( namespace( name, "<stateName>_EntryAction<i>"  ) ),
			[ param( [], pointer( id( namespace( name, "data_t" ) ) ), instanceId ) ],
			body
		);
	}
}

list[Stat] desugarOn( s:state( Id name, list[StateStat] body ) ) {
	map[ Id, list[Stat] ] triggers = ();
	for( s:on( Id event, list[Expr] cond, Id next ) <- s.body ) {
		// if( cond ) {
		// 	instance->__currentState = next
		// 	return;
		// }
		
		Stat \test = ifThen( 
			size(cond) > 0 ? cond[0] : lit( boolean( "true" ) ), 
			block(
			desugarExit( state ) +
			
			[
				expr( assign( ptrField( instance, currentState ), var( next ) ) ),
				\return()	
			] +
			
			desugarEntry( state, next )
			) 
		); 

		if( event in triggers ) {
			triggers[ event ] += \test;
		} else {
			triggers[ event ] = [ \test ];
		}
	}
	
	return for( Id event <- triggers ) {
		append \case( var( event ), block( triggers[ event ] ) ); 
	}
}