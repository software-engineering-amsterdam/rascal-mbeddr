module util::ext::Node
extend Node;

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
