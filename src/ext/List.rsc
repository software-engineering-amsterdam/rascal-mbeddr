module ext::List
extend List;

list[&T] insertListFor( list[&T] lst, int n, list[&T] input ) {
	lst[ n ] = input[ 0 ];
	for( i <- [1..size(input)] ) {
		lst = insertAt( lst, n + i, input[i] );
	}
	
	return lst;
}

public str joinList( list[&T] l, str c ) = ( "" | it + e + c | e <- l )[0..-1];
