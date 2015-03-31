module extensions::statemachine::\test::Desugar
extend \test::Base;

import util::ext::Node;

import extensions::statemachine::AST;
import extensions::statemachine::Desugar;
import extensions::statemachine::\test::Helper;

public test bool testDesugaringStatemachineWithState() {
	str testCaseName = "testDesugaringStatemachineWithState";
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
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}

public test bool testDesugarInComingEvent() {
    str testCaseName = "testDesugarInComingEvent";
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
		ast = desugarModule( ast );
		printC( ast );
	}
	
	return passed;
}

public test bool testDesugarStatemachineWithInitialState() {
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
		ast = desugarModule( ast );
		printC( ast );
	}
	
	return passed;
}

public test bool testDesugarStatemachineWithVarInStateCondition() {
    str testCaseName = "testDesugarStatemachineWithVarInStateCondition";
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
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}

public test bool testDesugarStatemachineWithEntryExitState() {
    str testCaseName = "testDesugarStatemachineWithEntryExitState";
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
		ast = desugarModule( ast );
		printC( ast );
	}
	
	return passed;
}

public test bool testDesugarStatemachineInitialization() {
    str testCaseName = "testDesugarStatemachineInitialization";
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
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}

public test bool testDesugarStatemachineInitializationWithSetState() {
    str testCaseName = "testDesugarStatemachineInitializationWithSetState";
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
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}

public test bool testDesugarStatemachineInitializationIsInState() {
    str testCaseName = "testDesugarStatemachineInitializationIsInState";
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
		ast = desugarModule( ast );
		
		printC( ast );
	}
	return passed;
}

public test bool testDesugarStatemachineInitializationTrigger() {
    str testCaseName = "testDesugarStatemachineInitializationTrigger";
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
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}

public test bool testDesugarStatemachineWithOutEvent() {
    str testCaseName = "testDesugarStatemachineWithOutEvent";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	" module Test;
	  void raiseAlarm() { }
	
	' exported statemachine FlightAnalyzer {
	'   out event crashNotification() =\> raiseAlarm
	'   state crashed {
			entry { send crashNotification(); }
		}
	' }
	";
	ast = resolver( createIndexTable( createAST( input ) ) );
	passed = checkForTypeErrors( ast, testCaseName );
	
	if( passed ) {
		ast = desugarModule( ast );
		printC( ast );
	}
	return passed;
}

public test bool testCompilingStatemachine() {
    str testCaseName = "testDesugarStatemachineWithOutEvent";
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
			stateMachines += compileStateMachine( d );
		}
	}

	if( DEBUG ) {
		iprintln( delAnnotationsRec( stateMachines ) );
	}
	
	return size(stateMachines) == 1;
}