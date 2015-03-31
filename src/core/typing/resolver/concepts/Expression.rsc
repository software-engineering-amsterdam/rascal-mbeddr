module core::typing::resolver::concepts::Expression
extend core::typing::resolver::Base;

import String;

import core::typing::Util;

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
		
		if( isEmpty(\type) ) { e@message = error( unknownTypeError(), "unkown type \'<name>\'", e@location ); }
		
		e@link = lookup( table, symbolKey( name ) ).at;	
		return e@\type = \type;
	} else {
		return e@message = error( referenceError(), "use of undeclared variable \'<name>\'", e@location );
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
	arrayType = getType( array );
	subType = getType( sub );
	
	if( isEmpty(arrayType ) || isEmpty(subType ) ) return e;
	
	return resolveSubScript( e, arrayType, subType );
}

Expr resolve( Expr e:call( v:var( id( func ) ), list[Expr] args ) ) {
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
	recordType = getType( record );
	
	if( isEmpty(recordType ) ) return e;
	return resolveField( e, recordType, name );
}

Expr resolve( Expr e:ptrField( Expr record, id( name ) ) ) {
	recordType = getType( record );
	
	if( isEmpty(recordType) ) return e;
	
	if( pointer( Type \type ) := recordType ) {
		return resolveField( e, \type, name );
	} else {
		return e@message = error( referenceMismatchError(),  "member reference type \'<typeToString(recordType)>\' is not a pointer", e@location );
	}
}

Expr resolve( Expr e:postIncr( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:postDecr( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:preIncr( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:preDecr( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr resolve( Expr e:addrOf( Expr arg ) ) { return e@\type = pointer( getType( arg ) ); }

Expr resolve( Expr e:refOf( Expr arg ) ) {
	argType = getType( arg );
	
	if( isEmpty(argType ) ) return e;
	
	if( pointer( \type ) := argType ) {
		e@\type = \type;
	} else {
		e@message = error( referenceMismatchError(),  "indirection requires pointer operand (\'<typeToString(argType)>\' invalid)", e@location );
	}
	
	return e;
}

Expr resolve( Expr e:pos( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree );

Expr resolve( Expr e:neg( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree );

Expr resolve( Expr e:bitNot( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree );

Expr resolve( Expr e:not( Expr arg ) ) = resolveUnaryExpression( e, arg, CTypeTree, category=boolean() );

Expr resolve( Expr e:sizeOfExpr( Expr arg ) ) { return e@\type = int8(); }

Expr resolve( Expr e:cast( Type \type, Expr arg ) ) { return e[@\type=\type]; }

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
	condType = getType( cond );
	
	if( isEmpty( condType ) ) return e;
	
	if( condType != \boolean() ) {
		return e@message = error( conditionalMisuseError(),  "\'<typeToString(condType)>\' is not a subtype of \'boolean\'", e@location ); 
	}
	
	thenType = getType( then );
	elsType = getType( els );
	
	if( isEmpty(thenType ) || isEmpty(elsType ) ) return e;
	
	if( thenType != elsType ) {
		return e@message = error( conditionalMismatchError(),  "<typeToString(thenType)>/<typeToString(elsType)> type mismatch in conditional expression (\'<typeToString(thenType)>\' and \'<typeToString(elsType)>\')", e@location );
	} 
	
	return e@\type = thenType;
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