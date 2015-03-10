module baseextensions::\test::Evaluator

import Message;
import Node;

import baseextensions::\test::Helper;

public test bool test_multiple_lambdas() {
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
	msgs = evaluator( input );
	
	return msgs == [];
}

public test bool test_multiple_lambdas() {
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
	msgs = evaluator( input );
	
	return msgs == [];
}