module typing::resolver::Expression
extend typing::resolver::Base;

import String;

import typing::Util;

default Expr resolve( Expr e ) {
	return e@message = warning( "unkown expression to typechecker <delAnnotationsRec(e)>", e@location );
} 

// VARIABLES

default Type resolve( Type t ) = t;
Type resolve( Type t:id( id( name ) ) ) {
	return t[@\type = resolveTypeDefs( t@indextable, t )];
}

Expr resolve( Expr e:var( id( name ) ) ) {
	table = e@indextable;
	
	if( contains( table, symbolKey( name ) ) ) {
		\type = lookup( table, symbolKey( name ) ).\type;
		
		\type = resolveTypeDefs( table, \type );
		
		if( isEmpty(\type) ) { e@message = error( "unkown type \'<name>\'", e@location ); }
		
		return e@\type = \type;
	} else {
		return e@message = error( "use of undeclared variable \'<name>\'", e@location );
	}
}

// LITERALS

Expr resolve( Expr e:neg( lit( \int( v ) ) ) ) {
	valueInt = - toInt( v );
	intSize = detectLiteralBitSize( valueInt );
	
    return e@\type = signedIntegerType( intSize );
}

Expr resolve( Expr e:lit( \int( v ) ) ) {
	valueInt = toInt( v );
	intSize = detectLiteralBitSize( valueInt );
	
    return e@\type = unsignedIntegerType( intSize );
}

Expr resolve( Expr e:lit( char( v ) ) ) { return e@\type = char(); }

Expr resolve( Expr e:lit( float( v ) ) ) { return e@\type = float(); }

Expr resolve( Expr e:lit( hex( v ) ) ) { return e@\type = int8(); }

Expr resolve( Expr e:lit( string( v ) ) ) { return e@\type = pointer( char() ); }

Expr resolve( Expr e:lit( boolean( v ) ) ) { return e@\type = boolean(); }

// EXPRESSIONS

Expr resolve( Expr e:subscript( Expr array, Expr sub )  ) {
	array_type = getType( array );
	sub_type = getType( sub );
	
	if( isEmpty(array_type ) || isEmpty(sub_type ) ) return e;
	
	return resolveSubScript( e, array_type, sub_type );
}

Expr resolve( Expr e:call( v:var( id( func ) ), list[Expr] args ) ) {
	// Remove error messages from the var id subnode
	v = delAnnotation( v, "message" );
	e.func = v;
	e.args = args;
	
	return resolveCall( e, e@indextable );
}

Expr resolve( Expr e:sizeof( Type \type ) ) { return e@\type = uint8(); }

Expr resolve( Expr e:struct( list[Expr] records ) ) {
	// TODO: support C99 syntax for struct initialization ({.id=expr})
	return e@\type = struct([ field( getType( record ), id("") ) | record <- records ]);
}

Expr resolve( Expr e:dotField( Expr record, id( name ) ) ) {
	record_type = getType( record );
	
	if( isEmpty(record_type ) ) return e;
	return resolveField( e, record_type, name );
}

Expr resolve( Expr e:ptrField( Expr record, id( name ) ) ) {
	record_type = getType( record );
	
	if( isEmpty(record_type) ) return e;
	
	if( pointer( Type \type ) := record_type ) {
		return resolveField( e, \type, name );
	} else {
		return e@message = error(  "member reference type \'<typeToString(record_type)>\' is not a pointer", e@location );
	}
}

Expr resolve( Expr e:postIncr( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:postDecr( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:preIncr( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:preDecr( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:addrOf( Expr arg ) ) { return e@\type = pointer( getType( arg ) ); }

Expr resolve( Expr e:refOf( Expr arg ) ) {
	arg_type = getType( arg );
	
	if( isEmpty(arg_type ) ) return e;
	
	if( pointer( \type ) := arg_type ) {
		e@\type = \type;
	} else {
		e@message = error(  "indirection requires pointer operand (\'<typeToString(arg_type)>\' invalid)", e@location );
	}
	
	return e;
}

Expr resolve( Expr e:pos( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree );

Expr resolve( Expr e:neg( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree );

Expr resolve( Expr e:bitNot( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree );

Expr resolve( Expr e:not( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=boolean() );

Expr resolve( Expr e:sizeOfExpr( Expr arg ) ) { return e@\type = int8(); }

Expr resolve( Expr e:cast( Type \type, Expr arg ) ) { return e@\type; }

Expr resolve( Expr e:mul( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CTypeTree );

Expr resolve( Expr e:div( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CTypeTree );

Expr resolve( Expr e:\mod( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr resolve( Expr e:add( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:sub( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true ); 

Expr resolve( Expr e:shl( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr resolve( Expr e:shr( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr resolve( Expr e:lt( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number(), override=\boolean() );	

Expr resolve( Expr e:gt( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number(), override=\boolean() );

Expr resolve( Expr e:leq( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number(), override=\boolean() );

Expr resolve( Expr e:geq( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number(), override=\boolean() );

Expr resolve( Expr e:eq( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CEqualityTypeTree, category=\number(), override=\boolean() );

Expr resolve( Expr e:neq( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CEqualityTypeTree, category=\number(), override=\boolean() );

Expr resolve( Expr e:bitAnd( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr resolve( Expr e:bitXor( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr resolve( Expr e:bitOr( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr resolve( Expr e:and( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=boolean() );

Expr resolve( Expr e:or( Expr lhs, Expr rhs ) ) = resolveBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=boolean() );

Expr resolve( Expr e:cond( Expr cond, Expr then, Expr els ) ) {
	cond_type = getType( cond );
	
	if( isEmpty( cond_type ) ) return e;
	
	if( cond_type != \boolean() ) {
		return e@message = error(  "\'<typeToString(cond_type)>\' is not a subtype of \'boolean\'", e@location ); 
	}
	
	then_type = getType( then );
	els_type = getType( els );
	
	if( isEmpty(then_type ) || isEmpty(els_type ) ) return e;
	
	if( then_type != els_type ) {
		return e@message = error(  "<typeToString(then_type)>/<typeToString(els_type)> type mismatch in conditional expression (\'<typeToString(then_type)>\' and \'<typeToString(els_type)>\')", e@location );
	} 
	
	return e@\type = then_type;
}

Expr resolve( Expr e:assign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CTypeTree );

Expr resolve( Expr e:mulAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CTypeTree, category=number() );

Expr resolve( Expr e:divAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CTypeTree, category=number() );

Expr resolve( Expr e:modAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr resolve( Expr e:addAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:subAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:shlAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr resolve( Expr e:shrAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr resolve( Expr e:bitAndAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr resolve( Expr e:bitXorAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr resolve( Expr e:bitOrAssign( Expr lhs, Expr rhs ) ) = resolveAssignment( e, lhs, rhs, CIntegerTypeTree );