module typing::resolver::Statement
extend typing::resolver::Base;

// STATEMENT EVALUATORS

default Stat resolve( Stat s ) = s;

Stat resolve( Stat s:ifThen(Expr cond, Stat body) ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) { return s; }
	
	if( !( boolean() := cond_type ) ) {
		return s@message = error( conditionalAbuseError(), "if condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:ifThenElse(Expr cond, Stat body, Stat els) ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) { return s; }
	
	if( !( boolean() := cond_type ) ) {
		return s@message = error( conditionalAbuseError(), "if condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:\while(Expr cond, Stat body) ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) { return s; }
	
	if( !( boolean() := cond_type ) ) {
		return s@message = error( loopAbuseError(), "while condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:doWhile(Stat body, Expr cond)  ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) { return s; }
	
	if( !( boolean() := cond_type ) ) {
		return s@message = error( loopAbuseError(), "do while condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}


