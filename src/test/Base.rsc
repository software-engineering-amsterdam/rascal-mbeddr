module \test::Base

import IO;
import ext::List;
import ext::Node;
import Message;

import lang::mbeddr::AST;
import lang::mbeddr::ToC;

import typing::IndexTable;

private bool PRINT = true;
private bool DEBUG = true;

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

private list[&T <: node] detect( str testCaseName, bool inHeader, &T <: node n, list[&T <: node] lst ) {
    header = false;
    if( "header" in getAnnotations(n) ) { header = n@header; }
    
    if( n in lst ) {
	    if( header == inHeader ) {
	        lst -= [n];
	    } elseif( PRINT ) {
	    	if( header ) {
	    		println("ERROR in <testCaseName>: expecting node in header file but found in c file: <n>");
	    	} else {
	    		println("ERROR in <testCaseName>: expecting node in c file but found in header file: <n>");
	    	}
	    }
	}
	
	return lst;
}

private bool validateDesugarOutput( str testCaseName, Module ast, list[&T <: node] headerOutput, list[&T <: node] cOutput ) {
	visit( ast ) {
		case &T <: node n : {
			headerOutput = detect( testCaseName, true, n, headerOutput );
			cOutput = detect( testCaseName, false, n, cOutput );
		}	
	}
	
	if( size( headerOutput ) != 0 && PRINT ) {
		println("ERROR: did not find all nodes in header ast, following nodes where not found:");
		iprintln( headerOutput );
	}
	
	if( size( cOutput ) != 0 && PRINT ) {
		println("ERROR: did not find all nodes in c ast, following nodes where not found:");
		iprintln( cOutput );
	}

	return size(headerOutput) == 0 && size(cOutput) == 0;	
}