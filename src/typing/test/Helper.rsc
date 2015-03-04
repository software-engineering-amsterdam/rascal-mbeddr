module typing::\test::Helper

import Node;
import ParseTree;

import lang::mbeddr::AST;
import lang::mbeddr::MBeddrC;

import typing::Scope;
import typing::IndexTable;
import typing::Indexer;
import typing::Evaluator;
import typing::Constraints;

list[Message] indexer( str i ) = findErrors( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) );
list[Message] constraints( str i ) = findErrors( constraints( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) ) );
list[Message] evaluator( str i ) = findErrors( evaluator( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) ) );

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
Module evaluator( m:\module( name, imports, decls ) ) = evaluator( m, (), () );
Module evaluator( &T <: node n, SymbolTable symbols, TypeTable types ) {
	n = copyDownIndexTables( n, symbols, types );

	n = visit( n ) {
		case Expr e => evaluate( e )
		case Decl d => evaluate( d )
		case Stat s => evaluate( s )
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