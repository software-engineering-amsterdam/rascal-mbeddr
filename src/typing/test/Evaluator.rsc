module typing::\test::Evaluator

import typing::\test::Helper;

import IO;
import List;

public test bool test_no_return() {
	str input = "module Test;
				'// No return value for non-void function
				'int32 add( int32 x, int32 y ) {
				'	return;
				'}";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "control reaches end of non-void function", _ ) := msgs[0];
}

public test bool test_implicit_type_conversion_1() {
	str input = "module Test;
				'// Char converts to int8
				'int8 add( char x, char y ) {
				'	return x + y;
				'}";
	msgs = evaluator( input );

	return size( msgs ) == 0;
}

public test bool test_implicit_type_conversion_2() {
	str input = "module Test;
				'// Bigger ints do not convert to smaller ints
				'int8 fun( int16 x ) {
				'	return x;
				'}";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "return type \'int16\' not a subtype of expected type \'int8\'", _ ) := msgs[0];
}

public test bool test_implicit_type_conversion_3() {
	str input = "module Test;
				'// doubles do not convert to floats
				'float fun( double x ) {
				'	return x;
				'}";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "return type \'double\' not a subtype of expected type \'float\'", _ ) := msgs[0];
}

public test bool test_struct_initialization() {
	str input = "module Test;
				'// Struct initialization is type checked
				'struct point {
				'	int32 x;
				'	int32 y;
				'};
				'
				'int64 x = 1;
				'struct point p = { x, 1 };";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "\'int64\' not a subtype of \'int32\'", _ ) := msgs[0];
}

public test bool test_struct_field_selection_1() {
	str input = "module Test;
				'// Struct field selection is type checked
				'struct point {
				'	int32 x;
				'	int32 y;
				'};
				'
				'struct point p = { 1, 1 };
				'int8 x = p.x;";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "\'int32\' not a subtype of \'int8\'", _ ) := msgs[0];
}

public test bool test_struct_field_selection_2() {
	str input = "module Test;
				'// Struct field selection is type checked
				'struct point {
				'	int32 x;
				'	int32 y;
				'};
				'
				'struct point p = { 1, 1 };
				'int32 z = p.z;";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "no member named \'z\' in \'struct point\'", _ ) := msgs[0];
}

public test bool test_function_call_1() {
	str input = "module Test;
				'
				'int32 add( int8 x, int8 y ) {
				' return x + y;
				'}
				'
				'int32 r = add( 1, 2, 3);";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "too many arguments to function call, expected 2, have 3", _ ) := msgs[0];
}

public test bool test_function_call_2() {
	str input = "module Test;
				'
				'int32 r = add( 1, 2, 3);";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "calling undefined function \'add\'", _ ) := msgs[0];
}

public test bool test_function_call_3() {
	str input = "module Test;
				'
				'int32 add( int8 x, int8 y ) {
				' return x + y;
				'}
				'
				'int16 x = 10;
				'int32 r = add( x, 2 );";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "wrong argument type(s)", _ ) := msgs[0];
}

public test bool test_switch_condition() {
	str input = "module Test;
				'// Switch condition should be a boolean
				'void switchBool() {
				'	switch( \"str\" ) {
				'		case \"default\" : return;
				'	}
				'}";				
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( str msg, _ ) := msgs[0];
}

public test bool test_wrong_assignment_1() {
	str input = "module Test;
				'int32 x = \"str\";";
	msgs = evaluator( input );
	
	return size( msgs ) == 1 &&
		   error( "\'pointer char\' not a subtype of \'int32\'", _ ) := msgs[0];
}

public test bool test_wrong_assignment_2() {
	str input = "module Test;
				'// Cannot assign boolean to integer
				'int8 z = true;";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "\'boolean\' not a subtype of \'int8\'", _ ) := msgs[0];
}

public test bool test_wrong_assignment_3() {
	str input = "module Test;
				'// Cannot assign integer to array of integers
				'int8[10] xs = 1;";
	msgs = evaluator( input );

	return size( msgs ) == 1 &&
		   error( "\'int8\' not a subtype of \'array[10] int8\'", _ ) := msgs[0];
}

public test bool test_wrong_implicit_assignment_1() {
	str input = "module Test;
				'// Can not assign uint16 or int16 to int8 (inferred type from literal)
				'int8 y = 256;";
	msgs = evaluator( input );
	
	return size( msgs ) == 1 &&
		   error( str s, _ ) := msgs[0];
}

public test bool test_wrong_implicit_assignment_2() {
	str input = "module Test;
				'// Can not assign uint16 or int16 to int8 (inferred type from literal)
				'int8 y = -10;";
	msgs = evaluator( input );
	
	return size( msgs ) == 1 &&
		   error( str s, _ ) := msgs[0];
}

public test bool test_pointer_assignment() {
	str input = "module Test;
				'int8** i = &8;";
	msgs = evaluator( input );
	
	return size( msgs ) == 1 &&
		   error( "type \'int8\' is not a subtype of type \'pointer int8\'", _ ) := msgs[0];
}

public test bool test_pointer_arithmetic_1() {
	str input = "module Test;
				'char* i = &\'c\';
				'char* j = i + 1;
				'char* k = i - 1;";
	msgs = evaluator( input );
	
	println(msgs);
	return size( msgs ) == 0;
}

public test bool test_pointer_arithmetic_2() {
	str input = "module Test;
				'void fun() {
					'char* i = &\'c\';
					'i += 1;
					'i -= 1;
				'}";
	msgs = evaluator( input );
	
	println(msgs);
	return size( msgs ) == 0;
}