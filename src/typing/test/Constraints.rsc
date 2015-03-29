module typing::\test::Constraints
extend \test::Base;

import typing::\test::Helper;

public test bool testDisallowedCaseInFunctionBody() {
	str testCaseName = "testDisallowedCaseInFunctionBody";
	str input = "module Test;
				'void main() {
				'	case \"test\" : return;
				'}";
	msgs = constraints( input );

	expectedMsgs = [ < constraintError(), "case statement is constrained to switch bodies" > ];
	passed = equalMessages( msgs, expectedMsgs );	
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testCaseConstrainedToSwitch() {
	str testCaseName = "testCaseConstrainedToSwitch";
	str input = "module Test;
				'void main() {
				'	switch( true ) {	
				'		case \"test\" : return;
				'   }
				'}";
	msgs = constraints( input );
	
	return size(msgs) == 0;
}

public test bool testDisallowedDefaultStatementInFunctionBody() {
	str testCaseName = "testDisallowedDefaultStatementInFunctionBody";
	str input = "module Test;
				'void main() {
				'	default: return;
				'}";
	msgs = constraints( input );
	
	expectedMsgs = [ < constraintError(), "default statement is constrained to switch bodies" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDefaultConstrainedToSwitch() {
	str testCaseName = "testDefaultConstrainedToSwitch";
	str input = "module Test;
				'void main() {
				'	switch( true ) {	
				'		default : return;
				'   }
				'}";
	msgs = constraints( input );
	
	return size(msgs) == 0;
}

public test bool testDisallowedFunctionDeclInFunctionBody() {
	str testCaseName = "testDisallowedFunctionDeclInFunctionBody";
	str input = "module Test;
				'void main() {
				'	void add() {};
				'}";
	msgs = constraints( input );
	
	expectedMsgs = [ < constraintError(), "function declaration is constrained to global scope" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowedAddrOfLiteral() {
	str testCaseName = "testDisallowedAddrOfLiteral";
	str input = "module Test;
				'int8* x = &1;";
	msgs = constraints( input );
	
	expectedMsgs = [ < constraintError(), "cannot take the address of an rvalue of type \'int\'" > ];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}
