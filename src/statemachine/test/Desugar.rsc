module statemachine::\test::Desugar
extend \test::TestBase;

import ext::Node;

import statemachine::AST;
import statemachine::Desugar;
import statemachine::\test::Helper;

public test bool test_state_desugar() {
	str testCaseName = "test_state_desugar";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' exported statemachine FlightAnalyzer {
	'  in event next()
	'  in event reset()
	'  state beforeFlight {
	'   on next [ ] -\> airborne
	'  }
	'  state airborne {
	'   on reset [] -\> beforeFlight
	'  }
	' }
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	return passed;
}

public test bool test_in_event_desugar() {
    str testCaseName = "test_in_event_desugar";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' statemachine FlightAnalyzer {
	'  in event next( int32 x )
	'  state beforeFlight {
	'   on next [ x == 0 ] -\> beforeFlight
	'  }
	' }
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	
	return passed;
}

public test bool test_init_desugar() {
    str testCaseName = "test_init_desugar";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
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
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	
	return passed;
}

public test bool test_var_cond() {
    str testCaseName = "test_var_cond";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
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
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	return passed;
}

public test bool test_entry_exit() {
    str testCaseName = "test_entry_exit";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' exported statemachine FlightAnalyzer initial = beforeFlight {
	'  in event next( int32 x )
	'  var int8 points = 0
	'  state beforeFlight {
	'   entry { points = 0; }
	'   on next [ x == 0 ] -\> airborne { points = 100; }
	'   exit { points += 10; }
	'  }
	'  state airborne { }
	' }
	'
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	
	return passed;
}

public test bool test_initialization() {
    str testCaseName = "test_initialization";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' exported statemachine FlightAnalyzer {
	'  state airborne { }
	' }
	'
	'void main() {
	' FlightAnalyzer f;
	' f.init();
	'}
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	return passed;
}

public test bool test_setState() {
    str testCaseName = "test_setState";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' exported statemachine FlightAnalyzer {
	'  state airborne { }
	' }
	'
	'void main() {
	' FlightAnalyzer f;
	' f.init();
	' f.setState( f.airborne );
	'}
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	return passed;
}

public test bool test_isInState() {
    str testCaseName = "test_isInState";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' exported statemachine FlightAnalyzer {
	'  state airborne { }
	' }
	'
	'void main() {
	' FlightAnalyzer f;
	' f.init();
	' f.isInState( f.airborne );
	'}
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	return passed;
}

public test bool test_trigger() {
    str testCaseName = "test_trigger";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' exported statemachine FlightAnalyzer {
	'   in event next( int32 x )
	'   state airborne { }
	' }
	'
	'void main() {
	' FlightAnalyzer f;
	' f.init();
	' f.next( 30 );
	'}
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugar_statemachine( ast );
		printC( ast );
	}
	return passed;
}

public test bool test_compile_statemachines() {
    str testCaseName = "test_compile_statemachines";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	' statemachine FlightAnalyzer initial = beforeFlight {
	'  in event next( int32 x )
	'
	'  var int8 points = 0
	'  state beforeFlight {
	'   on next [ x == 0 ] -\> airborne { points = 0; }
	'  }
	'  state airborne {
	'   on next [ ] -\> beforeFlight
	'  }
	' }
	";
	ast = createAST( input );
	
	stateMachines = [];
	visit( ast ) {
		case Decl d:stateMachine(_,_,_,_) : {
			stateMachines += compile_statemachine( d );
		}
	}

	if( DEBUG ) {
		iprintln( delAnnotationsRec( stateMachines ) );
	}
	
	return size(stateMachines) == 1;
}