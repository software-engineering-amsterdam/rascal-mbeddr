module extensions::statemachine::\test::Resolver
extend \test::Base;

import core::typing::TypeMessage;

import extensions::statemachine::\test::Helper;

public test bool testAllowStateReferenceIndependentOfOrder() {
	str testCaseName = "testAllowStateReferenceIndependentOfOrder";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' state beforeFlight {
	'	on next [] -\> airborne
	' }
	' state airborne {}
	'}";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowReferenceOfUndefinedEvent() {
	str testCaseName = "testDisallowReferenceOfUndefinedEvent";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' state beforeFlight {
	'	on next [] -\> airborne
	' }
	'}";
	msgs = resolver( input );
	
	expectedMsgs = [< referenceError(), "unknown event \'airborne\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowNonBooleanConditionTypeForOnEvent() {
	str testCaseName = "testDisallowNonBooleanConditionTypeForOnEvent";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' state beforeFlight {
	'	on next [ 1 ] -\> beforeFlight
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< conditionalAbuseError(), "expression expected to be of \'boolean\' type" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowArgumentReferenceInEventConditional() {
	str testCaseName = "testAllowArgumentReferenceInEventConditional";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next( int32 x )
	' state beforeFlight {
	'	on next [ x == 0 ] -\> beforeFlight
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowVarReferenceInEventConditional() {
	str testCaseName = "testAllowVarReferenceInEventConditional";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' var int16 points = 0
	' state beforeFlight {
	'	on next [ points == 0 ] -\> beforeFlight
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowOnEventForUnknownEvent() {
	str testCaseName = "testDisallowOnEventForUnknownEvent";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state beforeFlight {
	'	on next [ ] -\> beforeFlight
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< referenceError(), "unkown in event \'next\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowOnEventForOutEvent() {
	str testCaseName = "testDisallowOnEventForOutEvent";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'void callNext();
	'statemachine FlightAnalyzer {
	' out event next() =\> callNext
	' state beforeFlight {
	'	on next [ ] -\> beforeFlight
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< typeMismatchError(), "\'next\' is not an in event, but \'outEvent\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowUseOfUndefinedStateAsInitialState() {
	str testCaseName = "testDisallowUseOfUndefinedStateAsInitialState";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer initial = airborne {
	' state beforeFlight {
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< referenceError(), "undefined initial state \'airborne\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowUseOfInitialStateThatIsNotOfTypeState() {
	str testCaseName = "testDisallowUseOfInitialStateThatIsNotOfTypeState";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer initial = airborne {
	' var int8 airborne = 0
	' state beforeFlight {
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< typeMismatchError(), "initial state \'airborne\' is not of the type \'state\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowUseOfInitialState() {
	str testCaseName = "testAllowUseOfInitialState";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer initial = airborne {
	' state airborne {
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowUncompatibleTypesOnVarDeclarationsInsideStateMachine() {
	str testCaseName = "testDisallowUncompatibleTypesOnVarDeclarationsInsideStateMachine";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	' int32 x = 10;
	'statemachine FlightAnalyzer {
	' var int8 y = x
	'}";
	msgs = resolver( input );

	expectedMsgs = [< incompatibleTypesError(), "\'int32\' not a subtype of \'int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowWrongAmountOfArgumentsOnSend() {
	str testCaseName = "testDisallowWrongAmountOfArgumentsOnSend";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'void raiseAlarm( int32 points );
	'statemachine FlightAnalyzer {
	' out event crashNotification( int32 points ) =\> raiseAlarm
	'
	' state crashed {
	'  entry { send crashNotification(); }
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< argumentsMismatchError(), "too many arguments to out event call, expected 1, have 0" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowWrongArgumentTypesOnSend() {
	str testCaseName = "testDisallowWrongArgumentTypesOnSend";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'int32 x = 100;
	'void raiseAlarm( int8 points );
	'statemachine FlightAnalyzer {
	' out event crashNotification( int8 points ) =\> raiseAlarm
	'
	' state crashed {
	'  entry { send crashNotification( x ); }
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< argumentsMismatchError(), "wrong argument type(s)" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowReferenceOfUnknownOutEventInSend() {
	str testCaseName = "testDisallowReferenceOfUnknownOutEventInSend";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'void raiseAlarm();
	'statemachine FlightAnalyzer {
	'
	' state crashed {
	'  entry { send crashNotification( ); }
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< referenceError(), "unkown out event \'crashNotification\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowReferenceOfOutEventOfWrongType() {
	str testCaseName = "testDisallowReferenceOfOutEventOfWrongType";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event crashNotification()
	' state crashed {
	'  entry { send crashNotification( ); }
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< typeMismatchError(), "\'crashNotification\' is not an out event, but \'inEvent\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowOutEventWithUnknownFunction() {
	str testCaseName = "testDisallowOutEventWithUnknownFunction";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = resolver( input );

	expectedMsgs = [< referenceError(), "unkown function \'raiseAlarm\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowOutEventDeclarationWithWrongArgumentTypes() {
	str testCaseName = "testDisallowOutEventDeclarationWithWrongArgumentTypes";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'void raiseAlarm( int32 points ) {
	' 
	'}
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = resolver( input );

	expectedMsgs = [< argumentsMismatchError(), "wrong argument type(s)" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowOutEventDeclarationWithNonFunction() {
	str testCaseName = "testDisallowOutEventDeclarationWithNonFunction";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'int32 raiseAlarm;
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = resolver( input );

	expectedMsgs = [< functionReferenceError(), "\'raiseAlarm\' is not a function, but \'int32\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowCorrectDeclarationOfOutEvent() {
	str testCaseName = "testAllowCorrectDeclarationOfOutEvent";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'void raiseAlarm();
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = resolver( input );

	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowUseOfUndeclaredVariableInsideStateSwitchBody() {
	str testCaseName = "testDisallowUseOfUndeclaredVariableInsideStateSwitchBody";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'void raiseAlarm();
	'statemachine FlightAnalyzer {
	' in event next(int8 x)
	' state beforeFlight {
	'  on next [] -\> airborne { points = x; }
	' }
	' state airborne { }
	'}";
	msgs = resolver( input );

	expectedMsgs = [< referenceError(), "use of undeclared variable \'points\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowRedefinitionOfInitializedStateMachine() {
	str testCaseName = "testDisallowRedefinitionOfInitializedStateMachine";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'typedef int8 as FlightAnalyzer;
	'statemachine FlightAnalyzer {
	' state airborne {}
	'}
	'
	'void main() {
	' FlightAnalyzer f;
	'}
	";
	msgs = resolver( input );

	expectedMsgs = [< indexError(), "redefinition of \'FlightAnalyzer\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowInitializationOfStateMachine() {
	str testCaseName = "testAllowInitializationOfStateMachine";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state airborne {}
	'}
	'
	'void main() {
	' FlightAnalyzer f;
	' f.init();
	'}
	";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
} 

public test bool testAllowStateReferenceFromInitializedStateMachine() {
	str testCaseName = "testAllowStateReferenceFromInitializedStateMachine";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state airborne {}
	'}
	'
	'void main() {
	' FlightAnalyzer f;
	' f.airborne;
	'}
	";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowTriggerEventFromInitializedStateMachine() {
	str testCaseName = "testAllowTriggerEventFromInitializedStateMachine";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next( int32 x )
	' state airborne {}
	'}
	'
	'void main() {
	' FlightAnalyzer f;
	' f.next(10);
	'}
	";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowCallingUndefinedFunctionOnInitializedStateMachine() {
	str testCaseName = "testDisallowCallingUndefinedFunctionOnInitializedStateMachine";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state airborne {}
	'}
	'
	'void main() {
	' FlightAnalyzer f;
	' f.next(10);
	'}
	";
	msgs = resolver( input );
	
	expectedMsgs = [< referenceError(), "calling undefined function \'next\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}