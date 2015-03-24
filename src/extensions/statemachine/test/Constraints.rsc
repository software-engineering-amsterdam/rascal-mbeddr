module extensions::statemachine::\test::Constraints
extend \test::Base;

import extensions::statemachine::\test::Helper;

public test bool test_send_constraint_1() {
	str input = 
	" module Test;
	' 
	' void main() {
	'  send crashed();
	' }
	";
	msgs = constraints( input );
	
	return size(msgs) > 0 &&
		   error( "send statement is constrained to entry or exit bodies", _ ) := msgs[0];
}

public test bool test_send_constraint_2() {
	str input = 
	" module Test;
	' 
	'statemachine FlightAnalyzer {
	' state airborne {
	'  entry { send crashed(); }
	' }
	'}
	";
	msgs = constraints( input );
	
	return size( msgs ) == 0;
}