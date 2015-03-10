module unittest::\test::Helper

import Message;
import ParseTree;
import Node;

import unittest::Syntax;
import unittest::AST;

import unittest::typing::Indexer;
import unittest::typing::Constraints;
import unittest::typing::Resolver;
import unittest::typing::Scope;
import typing::IndexTable; 

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

// INDEXER //
Module createIndexTable( m:\module( name, imports, decls ) ) {
	return m.decls = indexer( decls, <(), ()>, global() );
}


// EVALUATOR //
Module resolver( Module m ) = resolver( m, (), () );
Module resolver( &T <: node n, SymbolTable symbols, TypeTable types ) {
	n = copyDownIndexTables( n, symbols, types );

	n = visit( n ) {
		case Expr e => resolve( e )
		case Decl d => resolve( d )
		case Stat s => resolve( s )
	}

	return n;	
}

Module copyDownIndexTables( Module m, SymbolTable symbols, TypeTable types ) {
	return top-down visit( m ) {
		case node n : {
			annos = getAnnotations( n );

			if( "symboltable" in annos ) {
				symbols = n@symboltable;
			} else {
				n = n[@symboltable = symbols];
			}
			
			if( "typetable" in annos ) {
				types = n@typetable;
			} else {
				n = n[@typetable = types];
			}
			
			insert n;
		}
	}
}

// CONSTRAINTS
Module constraints( Module m ) {
	return visit( m ) {
		case &T <: node n => constraint( n )
	}
}