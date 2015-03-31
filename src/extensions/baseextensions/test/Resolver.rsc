module extensions::baseextensions::\test::Resolver
extend \test::Base;

import core::typing::TypeMessage;
import util::ext::Node;

import extensions::baseextensions::\test::Helper;

public test bool testResolveMultipleLambdasWithoutErrors() {
	str testCaseName = "testResolveMultipleLambdas";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module MultipleLambda;
	'
	'int8(int8,int8) add = [ int8 x, int8 y | 
	'	int32 r = [ | x + y ]();
	'	
	'	int32() f = [ | return x; ];
	'	
	'	return x + y;
	'];";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool lambdaReturnsAreNotMatchedAsFunctionReturn() {
	str testCaseName = "lambdaReturnsAreNotMatchedAsFunctionReturn";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module MultipleLambda;
	'
	'void main() {
		int8() lambda = [ | return 10; ];
		return;
	'}
	'";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testResolveNestedLambdasWithoutErrors() {
	str testCaseName = "testResolveNestedLambdasWithoutErrors";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module NestedReturns; 
	'
	'int8(int8,int8) add = [ int8 x, int8 y | 
	'	int32(int8) f = [ int8 z | return z; ];
	'	
	'	return x + y;
	'];
	'
	'int8 adder(int8 x, int8 y ) {
	'	int32(int8) f = [ int8 z | return z; ];
	'	
	'	return x + y; 
	'}";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testConstantsAreImmutable() {
	str testCaseName = "testConstantsAreImmutable";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module NestedReturns; 
	
	#constant x = 10;
	
	void main() {
		x = 20;
	}
	";
	msgs = resolver( input );
	
	expectedMsgs = [< constantAssignmentError(), "can not modify constants" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testArrayComprehensionsDefineCorrectType() {
	str testCaseName = "testArrayComprehensionsDefineCorrectType";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module Test;
	
	int8 notList;
	
	int8[10] main() {
		return [ y | int8 y \<- notList, y \>= 10 ]; 
	}
	";
	msgs = resolver( input );
	
	expectedMsgs = [< typeMismatchError(), "Array comprehensions can only retrieve items from arrays" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testWrongGetTypeInArrayComprehension() {
	str testCaseName = "testWrongGetTypeInArrayComprehension";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module Test;
	
	int8[10] list;
	
	int8[10] main() {
		return [ y | float y \<- list ]; 
	}
	";
	msgs = resolver( input );
	
	expectedMsgs = [< nonFittingTypesError(), "Expected array with items of type \'float\' but got array with items of type \'int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowNonBooleanConditionInArrayComprehension() {
	str testCaseName = "testDisallowNonBooleanConditionInArrayComprehension";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module Test;
	
	int8[10] list;
	
	int8[10] main() {
		return [ y | int8 y \<- list, y + 1 ]; 
	}
	";
	msgs = resolver( input );
	
	expectedMsgs = [< conditionalMismatchError(), "Expected something of boolean type, but got something of \'uint8 || int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowArraysWithoutDimensionInArrayComprehensions() {
	str testCaseName = "testDisallowArraysWithoutDimensionInArrayComprehensions";
	outputStart( testCaseName );
	passed = true;
	str input =
	"module Test;
	
	int8[] list;
	
	int8[] main() {
		return [ y | int8 y \<- list ]; 
	}
	";
	msgs = resolver( input );
	
	expectedMsgs = [< typeMismatchError(), "Array comprehensions can only retrieve items from arrays with dimensions" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}