module \test::TestBase

import IO;
import ext::List;
import Message;

import lang::mbeddr::ToC;

import typing::IndexTable;

private bool PRINT = true;
private bool DEBUG = false;

private bool equalMessages( list[Message] msgs, list[str] expectedMsgs ) {
	result = size(msgs) == size(expectedMsgs);
	
	for( i <- [0..size(expectedMsgs)], i < size(msgs) ) {
        result = result && msgs[i].msg == expectedMsgs[i];
	}
	
	return result;
}

private void outputTest( str testCaseName, bool passed, list[str] expectedMsgs, list[Message] msgs ) {
	if( ! passed && PRINT ) {
        println("ERROR: <testCaseName> failed");
        println("expected errors: <expectedMsgs>");
        println("detected errors: <[ msg.msg | msg <- msgs ]>");
        println("");
	}
}

private void printC( ast ) {
	if( DEBUG ) {
		h = module2h( ast );
		c = module2c( ast );
		println( h );
		println("===============================");
		println( c );
	}
}

private bool checkForTypeErrors( ast, str testCase ) {
	result = true;
	msgs = findErrors( ast );
	
	if( size( msgs ) > 0 ) {
		if( PRINT ) {
			println("ERROR: <testCase> failed");
			println("failed because typechecker detected errors (check test input)");
			println("typechecker: <msgs>");
			println("");
		}
		
		result = false;
	}
	
	return result;
}