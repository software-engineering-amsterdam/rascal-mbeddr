module typing::resolver::Helper

import IO;
import util::ext::Node;

import typing::IndexTable;
import lang::mbeddr::AST;

default Module resolver( m:\module( name, imports, decls ) ) = resolver( m, () );
default Module resolver( &T <: node n, IndexTable table ) {
	n = copyDownIndexTables( n, table );
	
	n = visit( n ) {
		case Stat s => resolve( s ) 
		case Expr e => resolve( e )
		case Decl d => resolve( d )
		case Type t => resolve( t )
	}

	return n;	
}

Module copyDownIndexTables( Module m, IndexTable table ) {
	return top-down visit( m ) {
		case node n : {
			annos = getAnnotations( n );

			if( "indextable" in annos ) {
				table = n@indextable;
			} else {
				n = n[@indextable = table];
			}
			
			insert n;
		}
	}
}