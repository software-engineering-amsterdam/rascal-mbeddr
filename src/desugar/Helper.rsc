module desugar::Helper

import util::ext::List;
import util::ext::Node;

import lang::mbeddr::AST;

Module runDesugar( Module ast ) {
	ast = desugarSolve( ast );
	ast = desugarWithoutSolve( ast );
	ast = desugarList( ast );
	
	return ast;
}

Module desugarSolve( Module m ) {
	solve ( m ) {
	  m = visit( m ) {
		case &T <: node n => desugar( n )
	  }
	}
	
	return m;
}

Module desugarWithoutSolve( Module m ) {
	return visit( m ) {
		case &T <: node n => desugarSingle( n )
	}
}


Module desugarList( Module m ) {
    return visit( m ) {
		case list[&T <: node] lst => desugarList( lst )	
	}
}

list[&T <: node] desugarList( list[&T <: node] lst ) {
    offset = 0;
    toInsert = findInsertions( lst );
               
    for( < position, listToInsert > <- toInsert ) {
        lst = insertListFor( lst, position, listToInsert );	
    }
    
    return lst;
}

list[tuple[int,list[&T <: node]]] findInsertions( list[&T <: node] lst ) {
 	offset = 0;
 	result = [];
 	
 	for( elm <- lst ) {
        listToInsert = desugarToList( elm );
        
        if( listToInsert != [] ) {
            result += < indexOf( lst, elm ) + offset, listToInsert >;
            offset += size(listToInsert) - 1;
        }
    }
    
    return result;
}
	