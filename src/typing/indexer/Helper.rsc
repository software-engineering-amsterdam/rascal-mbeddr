module typing::indexer::Helper

import lang::mbeddr::AST;

Module createIndexTable( m:\module( name, imports, decls ) ) {
	m.decls = indexer( decls, <(), ()>, global() );
	return m;
}