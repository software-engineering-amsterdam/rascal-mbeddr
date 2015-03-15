module statemachine::\test::Helper

import Message;
import ParseTree;
import Node;
import IO;

import statemachine::Syntax;
import statemachine::AST;
import statemachine::Desugar;

import statemachine::typing::Indexer;
import statemachine::typing::Constraints;
import statemachine::typing::Resolver;
import statemachine::typing::IndexTable;
import statemachine::typing::Scope;

Module createAST( loc l ) = implode( #Module, parse( #start[Module], l ) );
Module createAST( str i ) = implode( #Module, parse( #start[Module], i ) );

list[Message] indexer( str i ) = findErrors( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) );
list[Message] constraints( str i ) = findErrors( constraints( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) ) );
list[Message] resolver( str i ) = findErrors( resolver( createIndexTable( implode( #Module, parse( #start[Module], i ) ) ) ) );

Module desugarModule( Module m ) {
	solve( m ) {
		m = top-down visit( m ) {
			case &T <: node n => desugar( n )
		}
	}
	
	return m;
}

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
Module resolver( m:\module( name, imports, decls ) ) = resolver( m, (), () );
Module resolver( &T <: node n, SymbolTable symbols, TypeTable types ) {
	n = copyDownIndexTables( n, symbols, types );

	n = visit( n ) {
		case Expr e => resolve( e )
		case Decl d => resolve( d )
		case Stat s => resolve( s )
		case StateMachineStat s => resolve( s )
		case StateStat s => resolve( s ) 
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
