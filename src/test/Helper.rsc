module \test::Helper

import ParseTree;
import ext::Node;

import lang::mbeddr::MBeddrC;
import lang::mbeddr::AST;
import typing::TypeMessage;

Module createAST( loc l ) = implode( #Module, parse( #start[Module], l ) );
Module createAST( str i ) = implode( #Module, parse( #start[Module], i ) );

list[Message] indexer( str i ) = findErrors( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) );
list[Message] constraints( str i ) = findErrors( constraints( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) ) );
list[Message] resolver( str i ) = findErrors( resolver( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) ) );

list[Message] findErrors( Module m ) {
	msgs = [];
	visit( m ) {
		case &T <: node n : {
			if( "message" in getAnnotations(n) ) {
				msgs += n@message;
			}
		}
	}
	
	return msgs;
}
