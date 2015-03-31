module core::typing::indexer::Base

import IO;
import util::ext::List;
import util::ext::Node;
import ParseTree;

import core::typing::IndexTable;
import core::typing::Scope;
import core::typing::TypeMessage;
import core::typing::resolver::concepts::Expression;
import lang::mbeddr::AST;

list[&T <: node] indexer( list[&T <: node] nodeList, IndexTable table, Scope scope ) {
	return for( n <- nodeList ) {
		n = indexWrapper( n, table, scope );
		table = n@indextable;
		append n;
	}
}

&T <: node indexWrapper( &T <: node oldNode, IndexTable table, Scope scope ) {
	result = indexer( oldNode, table, scope );
	newNode = result.astNode;
	
	newNode@indextable = result.table;
	
	if( result.errorMsg != "" ) {
		newNode@message = error( indexError(), result.errorMsg, newNode@location );
	}
	
	return newNode; 
}

// DEFAULT

default
tuple[ &T <: node astNode, IndexTable table, str errorMsg ]
indexer( &T <: node n,
	   	 IndexTable table, 
	   	 Scope scope
	   ) {		 
	return < n, table, "" >;
}


