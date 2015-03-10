module typing::resolver::Statement
extend typing::resolver::ResolverBase;

import typing::resolver::Util;

// STATEMENT EVALUATORS

default Stat resolve( Stat s ) = s;

Stat resolve( Stat s:ifThen(Expr cond, Stat body) ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) { return s; }
	
	if( !( boolean() := cond_type ) ) {
		return s@message = error( "if condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:ifThenElse(Expr cond, Stat body, Stat els) ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) { return s; }
	
	if( !( boolean() := cond_type ) ) {
		return s@message = error( "if condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:\while(Expr cond, Stat body) ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) { return s; }
	
	if( !( boolean() := cond_type ) ) {
		return s@message = error( "while condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:doWhile(Stat body, Expr cond)  ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) { return s; }
	
	if( !( boolean() := cond_type ) ) {
		return s@message = error( "do while condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}


