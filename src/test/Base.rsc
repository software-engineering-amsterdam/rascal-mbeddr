module \test::Base

import IO;
import util::ext::List;
import util::ext::Node;
import core::typing::TypeMessage;

import lang::mbeddr::AST;
import lang::mbeddr::ToC;

import core::typing::IndexTable;

private bool PRINT = true;
private bool DEBUG = true;

private tuple[Module,Module] splitAst( Module ast ) = < retrieveHeader( ast ), retrieveC( ast ) >;
private Module retrieveHeader( Module ast ) = ast[decls=retrieveHeaderDecls( ast )];
private Module retrieveC( Module ast ) = ast[decls= ast.decls - retrieveHeaderDecls( ast )];

private list[Decl] retrieveHeaderDecls( Module ast ) {
	headerDecls = [];
	
	visit( ast ) {
		case Decl d : {
			if( "header" in getAnnotations(d) && d@header ) { 
				headerDecls += d; 
			}
		}
	}
	
	return headerDecls;
}

private bool equalMessages( list[Message] msgs, list[tuple[ErrorType error,str msg]] expectedMsgs ) {
	result = size(msgs) == size(expectedMsgs);
	
	for( i <- [0..size(expectedMsgs)], i < size(msgs) ) {
        result = result && msgs[i].error == expectedMsgs[i].error; 
        
        if( PRINT && result && msgs[i].msg != expectedMsgs[i].msg ) {
        	println("WARNING: found error with correct error type but different message");
        	println("	 expected message: \'<expectedMsgs[i].msg>\'");
        	println("	 actual message: \'<msgs[i].msg>\'");
        } 
	}
	
	return result;
}

private bool equalMessages( list[Message] msgs, list[str] expectedMsgs ) {
	result = size(msgs) == size(expectedMsgs);
	
	for( i <- [0..size(expectedMsgs)], i < size(msgs) ) {
        result = result && msgs[i].msg == expectedMsgs[i];
	}
	
	return result;
}

private void outputStart( str testCaseName ) {
	if( PRINT ) { println("RUNNING: <testCaseName>"); }
}

private void outputResult( str testCaseName, bool passed ) {
	if( PRINT ) {
		if( passed ) { println( "         PASSED" ); }
		else { println( "         FAILED" ); }
	}
}

private void outputTest( str testCaseName, bool passed, list[tuple[ErrorType error, str msg]] expectedMsgs, list[Message] msgs ) {
	outputResult( testCaseName, passed );
	if( ! passed && PRINT ) {
        println("ERROR: <testCaseName> failed");
        println("expected errors: <[ msg.error | msg <- expectedMsgs]>");
        println("detected errors: <[ msg.error | msg <- msgs ]>");
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

private bool validateDesugarOutput( bool valid, str pattern, str file = "c file" ) {
	if( ! valid && PRINT ) { println( "ERROR: expected to find node \'<pattern>\' in desugared AST of <file>" ); }
	return valid; 
}