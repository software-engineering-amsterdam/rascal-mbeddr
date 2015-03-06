module statemachine::\test::Evaluator

import IO;
import List;

import statemachine::\test::Helper;

public test bool test_order_independent_state() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
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
	' state beforeFlight {
	'	on next [] -\> airborne
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "uknown event \'airborne\'", _ ) := msgs[0];
}

public test bool test_on_condition() {
	str input = 
	"module Test;
	'statemachine FlightAnalyzer {
	' state beforeFlight {
	'	on next [ 1 ] -\> beforeFlight
	' }
	'}";
	msgs = evaluator( input );
	
	return size(msgs) == 1 &&
		   error( "expression expected to be of \'boolean\' type", _ ) := msgs[0];
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