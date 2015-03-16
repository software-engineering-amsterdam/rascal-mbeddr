module typing::resolver::Helper

import IO;
import ext::Node;

import typing::IndexTable;
import lang::mbeddr::AST;

default Module resolver( m:\module( name, imports, decls ) ) = resolver( m, (), () );
default Module resolver( &T <: node n, SymbolTable symbols, TypeTable types ) {
	n = copyDownIndexTables( n, symbols, types );
	
	n = visit( n ) {
		case Stat s => resolve( s ) 
		case Expr e => resolve( e )
		case Decl d => resolve( d )
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