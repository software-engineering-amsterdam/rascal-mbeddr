module util::ext::Map
extend Map;

map[ &Y, list[&T] ] putInMap( map[ &Y, list[&T] ] m, &Y key, &T val ) {
	if( key in m ) {
		m[ key ] += val;
	} else {
		m[ key ] = [val];
	}
	
	return m;
} 