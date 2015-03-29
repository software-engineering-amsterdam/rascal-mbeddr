module typing::\test::Resolver
extend \test::Base;

import typing::\test::Helper;

public test bool testDisallowNonVoidFunctionToReturnVoid() {
	str testCaseName = "testDisallowNonVoidFunctionToReturnVoid";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// No return value for non-void function
				'int32 add( int32 x, int32 y ) {
				'	return;
				'}";
	msgs = resolver( input );

	expectedMsgs = [< returnMismatchError(), "control reaches end of non-void function" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowImplicitConversionOfCharToInt() {
	str testCaseName = "testAllowImplicitConversionOfCharToInt";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Char converts to int8
				'int8 add( char x, char y ) {
				'	return x + y;
				'}";
	msgs = resolver( input );

	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowBiggerIntegerTypeConversionToSmallerIntegerType() {
	str testCaseName = "testDisallowBiggerIntegerTypeConversionToSmallerIntegerType";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Bigger ints do not convert to smaller ints
				'int8 fun( int16 x ) {
				'	return x;
				'}";
	msgs = resolver( input );

	expectedMsgs = [< returnMismatchError(), "return type \'int16\' not a subtype of expected type \'int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowConversionFromDoubleToFloat() {
	str testCaseName = "testDisallowConversionFromDoubleToFloat";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// doubles do not convert to floats
				'float fun( double x ) {
				'	return x;
				'}";
	msgs = resolver( input );

	expectedMsgs = [< returnMismatchError(), "return type \'double\' not a subtype of expected type \'float\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowWrongTypesInStructInitialization() {
	str testCaseName = "testDisallowWrongTypesInStructInitialization";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Struct initialization is type checked
				'struct point {
				'	int32 x;
				'	int32 y;
				'};
				'
				'int64 x = 1;
				'struct point p = { x, 1 };";
	msgs = resolver( input );

	expectedMsgs = [< structAssignmentError(), "\'int64\' not a subtype of \'int32\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowDisallowedTypeConversionFromFieldSelection() {
	str testCaseName = "testDisallowDisallowedTypeConversionFromFieldSelection";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Struct field selection is type checked
				'struct point {
				'	int32 x;
				'	int32 y;
				'};
				'
				'struct point p = { 1, 1 };
				'int8 x = p.x;";
	msgs = resolver( input );

	expectedMsgs = [< incompatibleTypesError(), "\'int32\' not a subtype of \'int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowSelectionOfUnkownStructField() {
	str testCaseName = "testDisallowSelectionOfUnkownStructField";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Struct field selection is type checked
				'struct point {
				'	int32 x;
				'	int32 y;
				'};
				'
				'struct point p = { 1, 1 };
				'int32 z = p.z;";
	msgs = resolver( input );

	expectedMsgs = [< fieldReferenceError(), "no member named \'z\' in \'struct point\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowFunctionCallWithTooManyArguments() {
	str testCaseName = "testDisallowFunctionCallWithTooManyArguments";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'
				'int32 add( int8 x, int8 y ) {
				' if( true ) {
				'  return x + y;
				' }
				'}
				'
				'int32 r = add( 1, 2, 3);";
	msgs = resolver( input );

	expectedMsgs = [< argumentsMismatchError(), "too many arguments to function call, expected 2, have 3" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowCallOfUndefinedFunction() {
	str testCaseName = "testDisallowCallOfUndefinedFunction";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'
				'int32 r = add( 1, 2, 3);";
	msgs = resolver( input );

	expectedMsgs = [< referenceError(), "calling undefined function \'add\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowCallWithWrongArgumentTypes() {
	str testCaseName = "testDisallowCallWithWrongArgumentTypes";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'
				'int32 add( int8 x, int8 y ) {
				' return x + y;
				'}
				'
				'int16 x = 10;
				'int32 r = add( x, 2 );";
	msgs = resolver( input );

	expectedMsgs = [< argumentsMismatchError(), "wrong argument type(s)" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowNonBooleanTypeInIfCondition() {
	str testCaseName = "testDisallowNonBooleanTypeInIfCondition";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// If condition should be a boolean
				'void switchBool() {
				'	if( \"str\" ) {
				'		return;
				'	}
				'}";				
	msgs = resolver( input );

	expectedMsgs = [< conditionalAbuseError(), "if condition should be a \'boolean\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowNonBooleanTypeInWhileCondition() {
	str testCaseName = "testDisallowNonBooleanTypeInWhileCondition";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// While condition should be a boolean
				'void switchBool() {
				'	while( \"str\" ) {
				'		return;
				'	}
				'}";				
	msgs = resolver( input );

	expectedMsgs = [< loopAbuseError(), "while condition should be a \'boolean\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowNonBooleanTypeInWhileDoCondition() {
	str testCaseName = "testDisallowNonBooleanTypeInWhileDoCondition";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// While condition should be a boolean
				'void switchBool() {
				'	do {
				'		return;
				'	} while( \"str\" );
				'}";				
	msgs = resolver( input );

	expectedMsgs = [< loopAbuseError(), "do while condition should be a \'boolean\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfStringToInteger() {
	str testCaseName = "testDisallowAssignmentOfStringToInteger";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'int32 x = \"str\";";
	msgs = resolver( input );
	
	expectedMsgs = [< incompatibleTypesError(), "\'pointer char\' not a subtype of \'int32\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfBooleanToInteger() {
	str testCaseName = "testDisallowAssignmentOfBooleanToInteger";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Cannot assign boolean to integer
				'int8 z = true;";
	msgs = resolver( input );

	expectedMsgs = [< incompatibleTypesError(), "\'boolean\' not a subtype of \'int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfIntegerToArray() {
	str testCaseName = "testDisallowAssignmentOfIntegerToArray";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Cannot assign integer to array of integers
				'int8[10] xs = 1;";
	msgs = resolver( input );

	expectedMsgs = [< incompatibleTypesError(), "\'uint8 || int8\' not a subtype of \'array[10] int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfInt16LiteralToInt8() {
	str testCaseName = "testDisallowAssignmentOfInt16LiteralToInt8";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Can not assign uint16 or int16 to int8 (inferred type from literal)
				'int8 y = 256;";
	msgs = resolver( input );
	
	expectedMsgs = [< incompatibleTypesError(), "\'uint16 || int16\' not a subtype of \'int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfSignedLiteralToUnsignedInt() {
	str testCaseName = "testDisallowAssignmentOfSignedLiteralToUnsignedInt";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'// Can not assign uint16 or int16 to int8 (inferred type from literal)
				'uint8 y = -10;";
	msgs = resolver( input );
	
	expectedMsgs = [< incompatibleTypesError(), "\'int8\' not a subtype of \'uint8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfPointerToPointerPointer() {
	str testCaseName = "testDisallowAssignmentOfPointerToPointerPointer";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'int8** i = &8;";
	msgs = resolver( input );
	
	expectedMsgs = [< pointerAssignmentError(), "type \'uint8 || int8\' is not a subtype of type \'pointer int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfPointerToPointerPointerInFunctionBody() {
	str testCaseName = "testDisallowAssignmentOfPointerToPointerPointerInFunctionBody";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'int8** i;
				'
				'void main() {
				'	i = &8;
				'}
				"; 
	msgs = resolver( input );
	
	expectedMsgs = [< pointerAssignmentError(), "type \'uint8 || int8\' is not a subtype of type \'pointer int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowPlusMinusOperatorWithPointerAndInteger() {
	str testCaseName = "testAllowPlusMinusOperatorWithPointerAndInteger";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'char* i = &\'c\';
				'char* j = i + 1;
				'char* k = i - 1;";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowPluMinusAssignmentOperatorWithPointerAndInteger() {
	str testCaseName = "testAllowPluMinusAssignmentOperatorWithPointerAndInteger";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'void fun() {
					'char* i = &\'c\';
					'i += 1;
					'i -= 1;
				'}";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfIntegerToPointerOfInteger() {
	str testCaseName = "testDisallowAssignmentOfIntegerToPointerOfInteger";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'void fun() {
				' int8* x = 10;
				'}";
	msgs = resolver( input );
	
	expectedMsgs = [< incompatibleTypesError(), "\'uint8 || int8\' not a subtype of \'pointer int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}
public test bool testDisallowPlusOperatorWithPointerAndPointer() {
	str testCaseName = "testDisallowPlusOperatorWithPointerAndPointer";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'void fun() {
				' int8* x = &10;
				' int8* y = &10;
				' int8* z = x + y;
				'}";
	msgs = resolver( input );
	
	expectedMsgs = [< nonFittingTypesError(), "operator can not be applied to \'pointer int8\' and \'pointer int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowDeclarationWithTypeDef() {
	str testCaseName = "testAllowDeclarationWithTypeDef";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'typedef int8 as test_type;
				'test_type x;
				";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowDeclartionWithTypeDefOfWithInitialization() {
	str testCaseName = "testAllowDeclartionWithTypeDefOfWithInitialization";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'typedef uint8 as test_type;
				'test_type x = 10;
				";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testCorrectlyResolveTypeDefFunctionReturnType() {
	str testCaseName = "testCorrectlyResolveTypeDefFunctionReturnType";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		typedef int32 as blaat;
	
		blaat x = 10;
		
		blaat main() {
			return x;
		}
	";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testCorrectlyResolveTypeDefVariableAssignment() {
	str testCaseName = "testCorrectlyResolveTypeDefVariableAssignment";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		typedef int32 as blaat;
		blaat x;
		
		void main() {
			x = 10;
		}
	";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testDisallowAssignmentOfUninitializedVariable() {
	str testCaseName = "testDisallowAssignmentOfUninitializedVariable";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'void main() {
				'	x = 10;
				'}
				";
	msgs = resolver( input );
	
	expectedMsgs = [< referenceError(), "use of undeclared variable \'x\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowComparisonInIfCondition() {
	str testCaseName = "testAllowComparisonInIfCondition";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
				'int32 main(int32 x) {
				'	if( x == 10 ) {
				'		return x;
				'	}
				'}
				";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testAllowReferenceOfKnownStructField() {
	str testCaseName = "testAllowReferenceOfKnownStructField";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
	module Test;
	
	typedef struct TrackPoint as TrackPoint;
	struct TrackPoint {
		int32 alt;
		int32 speed;
	};
	
	int32 main( TrackPoint* tp ) {
		return tp-\>alt;
	}
	";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}
	
public test bool testAllowInitializationOfConstant() {
	str testCaseName = "testAllowInitializationOfConstant";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
	'#constant TAKEOFF = 100 + 1;
	'#constant HIGH_SPEED = true;
	";
	msgs = resolver( input );
	
	expectedMsgs = [];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}

public test bool testPlusOperatorDoesntResolveToBoolean() {
	str testCaseName = "testPlusOperatorDoesntResolveToBoolean";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "module Test;
	int8 x = 10;
	
	void main() {
		if( (x == 10) + 1 ) {
			return;
		}
	}
	";
	msgs = resolver( input );
	
	expectedMsgs = [< nonFittingTypesError(), "operator can not be applied to \'boolean\' and \'uint8 || int8\'" >];
	passed = equalMessages( msgs, expectedMsgs );
	outputTest( testCaseName, passed, expectedMsgs, msgs );
	
	return passed;
}