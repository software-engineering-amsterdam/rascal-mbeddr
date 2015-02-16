module Util

public str joinList( list[&T] l, str c ) = ( "" | it + e + c | e <- l )[0..-1];