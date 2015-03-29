module typing::resolver::Statement
extend typing::resolver::Base;

// STATEMENT EVALUATORS

default Stat resolve( Stat s ) = s;

Stat resolve( Stat s:ifThen(Expr cond, Stat body) ) {
	condType = getType( cond );
	
	if( isEmpty( condType ) ) { return s; }
	
	if( !( boolean() := condType ) ) {
		return s@message = error( conditionalAbuseError(), "if condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:ifThenElse(Expr cond, Stat body, Stat els) ) {
	condType = getType( cond );
	
	if( isEmpty( condType ) ) { return s; }
	
	if( !( boolean() := condType ) ) {
		return s@message = error( conditionalAbuseError(), "if condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:\while(Expr cond, Stat body) ) {
	condType = getType( cond );
	
	if( isEmpty( condType ) ) { return s; }
	
	if( !( boolean() := condType ) ) {
		return s@message = error( loopAbuseError(), "while condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}

Stat resolve( Stat s:doWhile(Stat body, Expr cond)  ) {
	condType = getType( cond );
	
	if( isEmpty( condType ) ) { return s; }
	
	if( !( boolean() := condType ) ) {
		return s@message = error( loopAbuseError(), "do while condition should be a \'boolean\'", s@location );
	} else {
		return s;
	}
}


