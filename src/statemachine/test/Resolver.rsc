module statemachine::\test::Resolver
extend \test::TestBase;

import Message;

import statemachine::\test::Helper;


public test bool test_order_independent_state() {
	str testCaseName = "test_order_independent_state";
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

public test bool test_state_reference() {
	str testCaseName = "test_state_reference";
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
	
	expectedMsgs = ["unknown event \'airborne\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_on_condition_1() {
	str testCaseName = "test_on_condition_1";
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

	expectedMsgs = ["expression expected to be of \'boolean\' type"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_on_condition_2() {
	str testCaseName = "test_on_condition_2";
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

public test bool test_on_condition_3() {
	str testCaseName = "test_on_condition_3";
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

public test bool test_on_event_1() {
	str testCaseName = "test_on_event_1";
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

	expectedMsgs = ["unkown in event \'next\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_on_event_2() {
	str testCaseName = "test_on_event_2";
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

	expectedMsgs = ["\'next\' is not an in event, but \'outEvent\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_initial_state_1() {
	str testCaseName = "test_initial_state_1";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer initial = airborne {
	' state beforeFlight {
	' }
	'}";
	msgs = resolver( input );

	expectedMsgs = ["undefined initial state \'airborne\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_initial_state_2() {
	str testCaseName = "test_initial_state_2";
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

	expectedMsgs = ["initial state \'airborne\' is not of the type \'state\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_initial_state_3() {
	str testCaseName = "test_initial_state_3";
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

public test bool test_var_declaration() {
	str testCaseName = "test_var_declaration";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	' int32 x = 10;
	'statemachine FlightAnalyzer {
	' var int8 y = x
	'}";
	msgs = resolver( input );

	expectedMsgs = ["\'int32\' not a subtype of \'int8\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_call_1() {
	str testCaseName = "test_outevent_call_1";
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

	expectedMsgs = ["too many arguments to out event call, expected 1, have 0"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_call_2() {
	str testCaseName = "test_outevent_call_2";
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

	expectedMsgs = ["wrong argument type(s)"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_call_3() {
	str testCaseName = "test_outevent_call_3";
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

	expectedMsgs = ["unkown out event \'crashNotification\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_call_4() {
	str testCaseName = "test_outevent_call_4";
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

	expectedMsgs = ["\'crashNotification\' is not an out event, but \'inEvent\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_ref_1() {
	str testCaseName = "test_outevent_ref_1";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = resolver( input );

	expectedMsgs = ["unkown function \'raiseAlarm\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_ref_2() {
	str testCaseName = "test_outevent_ref_2";
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

	expectedMsgs = ["wrong argument type(s)"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_ref_3() {
	str testCaseName = "test_outevent_ref_3";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = 
	"module Test;
	'int32 raiseAlarm;
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = resolver( input );

	expectedMsgs = ["\'raiseAlarm\' is not a function, but \'int32\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_outevent_ref_4() {
	str testCaseName = "test_outevent_ref_4";
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

public test bool test_on_body() {
	str testCaseName = "test_on_body";
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

	expectedMsgs = ["use of undeclared variable \'points\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_statemachine_typedef() {
	str testCaseName = "test_statemachine_typedef";
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

	expectedMsgs = ["redefinition of \'FlightAnalyzer\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool test_statemachine_init() {
	str testCaseName = "test_statemachine_init";
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

public test bool test_statemachine_state_access() {
	str testCaseName = "test_statemachine_state_access";
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

public test bool test_trigger_event_1() {
	str testCaseName = "test_trigger_event_1";
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

public test bool test_trigger_event_2() {
	str testCaseName = "test_trigger_event_2";
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
	
	expectedMsgs = ["calling undefined function \'next\'"];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}