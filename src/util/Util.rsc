module util::Util

import Node;

import lang::mbeddr::AST;

public str joinList( list[&T] l, str c ) = ( "" | it + e + c | e <- l )[0..-1];

public list[Type] parameterTypes( list[Param] params ) = [ paramType | param( _, paramType, _ ) <- params ];

public &T <: node copyAnnotations( &T <: node n, &T <: node m ) {
	return setAnnotations( n, getAnnotations( n ) + getAnnotations( m ) );
}

&T <: node delAnnotationRec( &T <: node root, list[str] annoKeys ) {
	for( annoKey <- annoKeys ) {
		root = delAnnotationRec( root, annoKey );
	}
	
	return root;
}

&T <: node delAnnotationRec( &T <: node root, str annoKey ) {
	return visit( root ) {
		case node n => delAnnotation( n, annoKey )
	}
}

map[ &Y, list[&T] ] putInMap( map[ &Y, list[&T] ] m, &Y key, &T val ) {
	if( key in m ) {
		m[ key ] += val;
	} else {
		m[ key ] = [val];
	}
	
	return m;
} 