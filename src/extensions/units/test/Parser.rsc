module extensions::units::\test::Parser
extend \test::Base;

import extensions::units::\test::Helper;

public test bool test_parse_unit() {
	str testCaseName = "test_parser";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		int8/m/ meters = 10 m;
	";
	
	ast = createAST( input );
	
	if( DEBUG ) { iprintln(delAnnotationsRec( ast )); }
	
	return passed;
}

public test bool test_parse_unit_declaration() {
	str testCaseName = "test_parse_unit_declaration";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		exported unit s for seconds
	";
	
	ast = createAST( input );
	
	if( DEBUG ) { iprintln(delAnnotationsRec( ast )); }

	return passed;
}

public test bool test_parse_unit_conversion() {
	str testCaseName = "test_parse_unit_conversion";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		exported conversion mps -\> kmh {
			val -\> val / 3.6
			val as double -\> val / 3.6
		}	
	";
	
	ast = createAST( input );
	
	if( DEBUG ) { iprintln(delAnnotationsRec( ast )); }
	
	return passed;
}

public test bool test_parse_convert_unit() {
	str testCaseName = "test_parse_unit_conversion";
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
	passed = true;
	str input = "
		module Test;
		
		int8/mps/ meterPerSecond = convert( x -\> mps );	
	";
	
	ast = createAST( input );
	
	if( DEBUG ) { iprintln(delAnnotationsRec( ast )); }
	
	return passed;
}
