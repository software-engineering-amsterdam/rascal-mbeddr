module statemachine::\test::Evaluator

import IO;
import List;

import statemachine::\test::Helper;

public test bool test_order_independent_state() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' state beforeFlight {
	'	on next [] -\> airborne
	' }
	' state airborne {}
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 0;
}

public test bool test_state_reference() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' state beforeFlight {
	'	on next [] -\> airborne
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "unknown event \'airborne\'", _ ) := msgs[0];
}

public test bool test_on_condition_1() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' state beforeFlight {
	'	on next [ 1 ] -\> beforeFlight
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "expression expected to be of \'boolean\' type", _ ) := msgs[0];
}

public test bool test_on_condition_2() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next( int32 x )
	' state beforeFlight {
	'	on next [ x == 0 ] -\> beforeFlight
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 0;
}

public test bool test_on_condition_3() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event next()
	' var int16 points = 0
	' state beforeFlight {
	'	on next [ points == 0 ] -\> beforeFlight
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 0;
}

public test bool test_on_event_1() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state beforeFlight {
	'	on next [ ] -\> beforeFlight
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "unkown in event \'next\'", _ ) := msgs[0];
}

public test bool test_on_event_2() {
	str input = 
	"module Test;
	'void callNext();
	'statemachine FlightAnalyzer {
	' out event next() =\> callNext
	' state beforeFlight {
	'	on next [ ] -\> beforeFlight
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "\'next\' is not an in event, but \'out event\'", _ ) := msgs[0];
}

public test bool test_initial_state_1() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer initial = airborne {
	' state beforeFlight {
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "undefined initial state \'airborne\'", _ ) := msgs[0];
}

public test bool test_initial_state_2() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer initial = airborne {
	' var int8 airborne = 0
	' state beforeFlight {
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "initial state \'airborne\' is not of the type \'state\'", _ ) := msgs[0];
}

public test bool test_initial_state_3() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer initial = airborne {
	' state airborne {
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 0;
}

public test bool test_var_declaration() {
	str input = 
	"module Test;
	' int32 x = 10;
	'statemachine FlightAnalyzer {
	' var int8 y = x
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "\'int32\' not a subtype of \'int8\'", _ ) := msgs[0];
}

public test bool test_outevent_call_1() {
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
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "too many arguments to out event call, expected 1, have 0", _ ) := msgs[0];
}

public test bool test_outevent_call_2() {
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
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "wrong argument type(s)", _ ) := msgs[0];
}

public test bool test_outevent_call_3() {
	str input = 
	"module Test;
	'void raiseAlarm();
	'statemachine FlightAnalyzer {
	'
	' state crashed {
	'  entry { send crashNotification( ); }
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "unkown out event \'crashNotification\'", _ ) := msgs[0];
}

public test bool test_outevent_call_4() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' in event crashNotification()
	' state crashed {
	'  entry { send crashNotification( ); }
	' }
	'}";
	msgs = evaluator( input );
	
	iprintln(msgs);
	return size(msgs) == 1 &&
		   error( "\'crashNotification\' is not an out event, but \'inevent\'", _ ) := msgs[0];
}

public test bool test_outevent_ref_1() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "unkown function \'raiseAlarm\'", _ ) := msgs[0];
}

public test bool test_outevent_ref_2() {
	str input = 
	"module Test;
	'void raiseAlarm( int32 points ) {
	' 
	'}
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "wrong argument type(s)", _ ) := msgs[0];
}

public test bool test_outevent_ref_3() {
	str input = 
	"module Test;
	'int32 raiseAlarm;
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "\'raiseAlarm\' is not a function, but \'int32\'", _ ) := msgs[0];
}

public test bool test_outevent_ref_4() {
	str input = 
	"module Test;
	'void raiseAlarm();
	'statemachine FlightAnalyzer {
	' out event crashNotification() =\> raiseAlarm
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 0;
}