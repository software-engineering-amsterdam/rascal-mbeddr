module typing::\test::Constraints
extend \test::TestBase;

import typing::\test::Helper;

public test bool test_case_constraint_1() {
	str input = "module Test;
				'void main() {
				'	case \"test\" : return;
				'}";
	msgs = constraints( input );
	
	return size(msgs) == 1 &&
		   error( "case statement is constrained to switch bodies", _ ) := msgs[0];
}

public test bool test_case_constraint_2() {
	str input = "module Test;
				'void main() {
				'	switch( true ) {	
				'		case \"test\" : return;
				'   }
				'}";
	msgs = constraints( input );
	
	return size(msgs) == 0;
}

public test bool test_default_constraint() {
	str input = "module Test;
				'void main() {
				'	default: return;
				'}";
	msgs = constraints( input );
	
	return size(msgs) == 1 &&
		   error( "default statement is constrained to switch bodies", _ ) := msgs[0];
}

public test bool test_default_constraint_2() {
	str input = "module Test;
				'void main() {
				'	switch( true ) {	
				'		default : return;
				'   }
				'}";
	msgs = constraints( input );
	
	return size(msgs) == 0;
}

public test bool test_function_constraint() {
	str input = "module Test;
				'void main() {
				'	void add() {};
				'}";
	msgs = constraints( input );
	
	return size(msgs) == 1 &&
		   error( "function declaration is constrained to global scope", _ ) := msgs[0];
}

public test bool test_addrOf_constraint() {
	str input = "module Test;
				'int8* x = &1;";
	msgs = constraints( input );
	
	return size(msgs) == 1 &&
		   error( "cannot take the address of an rvalue of type \'int\'", _ ) := msgs[0];
}