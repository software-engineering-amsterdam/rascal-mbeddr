module extensions::baseextensions::\test::Resolver
extend \test::Base;

import Message;
import ext::Node;

import extensions::baseextensions::\test::Helper;

public test bool test_multiple_lambdas() {
	str testCaseName = "test_multiple_lambdas";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
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
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
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

public test bool test_multiple_lambdas() {
	str testCaseName = "test_multiple_lambdas";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
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