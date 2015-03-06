module statemachine::\test::Desugar

import IO;
import Node;

import lang::mbeddr::ToC;

import statemachine::AST;
import statemachine::Desugar;
import statemachine::\test::Helper;

private bool PRINT = true;

public test bool test_state_desugar() {
	str input = 
	" module Test;
	' statemachine FlightAnalyzer {
	'  state beforeFlight {
	'   on next [ ] -\> airborne
	'  }
	'  state airborne {
	'   on reset [] -\> beforeFlight
	'  }
	' }
	";
	ast = createAST( input );
	ast = desugar_statemachine( ast );
	
	if( PRINT ) {
		c = module2c( ast );
		println( c );
	}
	
	return true;
}

public test bool test_in_event_desugar() {
	str input = 
	" module Test;
	' statemachine FlightAnalyzer {
	'  in event next( int32 x )
	'  state beforeFlight {
	'   on next [ x == 0 ] -\> beforeFlight
	'  }
	' }
	";
	ast = createAST( input );
	ast = desugar_statemachine( ast );
	
	if( PRINT ) {
		c = module2c( ast );
		println( c );
	}
	
	return true;
}

public test bool test_init_desugar() {
	str input = 
	" module Test;
	' statemachine FlightAnalyzer initial = beforeFlight {
	'  in event next( int32 x )
	'
	'  var int8 points = 0
	'  state beforeFlight {
	'   on next [ x == 0 ] -\> beforeFlight
	'  }
	' }
	";
	ast = createAST( input );
	ast = desugar_statemachine( ast );
	
	if( PRINT ) {
		c = module2c( ast );
		println( c );
	}
	
	return true;
}

public test bool test_var_cond() {
	str input = 
	" module Test;
	' statemachine FlightAnalyzer initial = beforeFlight {
	'  in event next( int32 x )
	'  var int8 points = 0
	'  state beforeFlight {
	'   on next [ points == 0 ] -\> beforeFlight
	'  }
	' }
	";
	ast = createAST( input );
	ast = desugar_statemachine( ast );
	
	if( PRINT ) {
		c = module2c( ast );
		println( c );
	}
	
	return true;
}

public test bool test_entry_exit() {
	str input = 
	" module Test;
	' statemachine FlightAnalyzer initial = beforeFlight {
	'  in event next( int32 x )
	'  var int8 points = 0
	'  state beforeFlight {
	'   entry { points = 0; }
	'   on next [ x == 0 ] -\> beforeFlight
	'   exit { points += 10; }
	'  }
	' }
	";
	ast = createAST( input );
	ast = desugar_statemachine( ast );
	
	if( PRINT ) {
		c = module2c( ast );
		println( c );
	}
	
	return true;
}

public test bool test_compile_statemachines() {
	str input = 
	" module Test;
	' statemachine FlightAnalyzer initial = beforeFlight {
	'  in event next( int32 x )
	'
	'  var int8 points = 0
	'  state beforeFlight {
	'   on next [ x == 0 ] -\> airborne
	'  }
	'  state airborne {
	'   on next [ ] -\> beforeFlight
	'  }
	' }
	";
	ast = createAST( input );
	stateMachines = compileStateMachines( ast );
	
	if( PRINT ) {
		iprintln( delAnnotationsRec( stateMachines ) );
	}
	
	return true;
}