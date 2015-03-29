module typing::resolver::Base

import ext::List;
import ext::Node;
import IO;
import typing::TypeMessage;

import lang::mbeddr::AST;

import typing::IndexTable;
import typing::TypeTree;
import typing::Scope;

anno Type Expr @ \type;
anno Type Type @ \type;

data Type = empty();

bool isNotEligbleForResolvment( Expr e ) = isEmpty( getType( e ) ); 

bool isEmpty( Type t ) {
	e = empty();
	return e := t;
}

default Type getType( &T <: node n ) = ( "type" in getAnnotations( n ) ) ? n@\type : empty();
Type getType( Type n )  = ( "type" in getAnnotations( n ) ) ? n@\type : n; 

&T <: node resolve( &T <: node n ) = n;

public default bool isStructType( _ ) = false;
public bool isStructType( Type _:struct( id( _ ) ) ) = true;

public default bool isUnionType( _ ) = false;
public bool isUnionType( Type _:union( id( _ ) ) ) = true;

public default bool isPointerType( _ ) = false;
public bool isPointerType( Type _:pointer( _ ) ) = true;

public default Type extractFieldType( _ ) = \void();
public Type extractFieldType( field( Type t, _ ) ) = t;

public default bool isExpression( _ ) = false;
public bool isExpression( Expr e ) = true;

public bool fittingTypes( list[Type] possiblities, list[Type] types ) {
	result = true;
	
	for( \type <- types ) {
		result = result && \type in possiblities;
	}
	
	return result; 
}

public bool arePointerArithmeticTypes( Type lhs, Type rhs, list[Type] integerTypes ) {
	return isPointerType( lhs ) && rhs in integerTypes || isPointerType( rhs ) && lhs in integerTypes;
}

public Expr resolvePointerArithmetic( Expr e, Type t1, Type t2, list[Type] integerTypes ) {
	if(isPointerType( t1 ) && t2 in integerTypes) { e@\type = t1; }
	if(isPointerType( t2 ) && t1 in integerTypes) { e@\type = t2; }
	return e;
}

public Expr resolveAssignmentPointerArithmetic( Expr e, Type lhsType, Type rhsType, list[Type] integerTypes ) {
	if( isPointerType( lhsType ) && rhsType in integerTypes ) { e@\type = lhsType; }
	return e;
}

public Expr resolveStructField( Expr e, Type \type, str name ) {
	table = e@indextable;
		
	if( struct(list[Field] fields) := lookup( table, typeKey( \type.name.name, struct() ) ).\type ) {
		e = resolvePtrField( e, \type, fields, name );
	}
	
	return e;
}

public Expr resolveUnionField( Expr e, Type \type, str name ) {
	table = e@indextable;
	
	if( union(list[Field] fields) := lookup( table, typeKey( \type.name.name, union() ).\type ) ) {
		e = resolvePtrField( e, \type, fields, name );
	}
	
	return e;
}

public default Expr resolveField( Expr e, Type \type, str name ) {
	if( isStructType( \type ) ) { return resolveStructField( e, \type, name ); }
	if( isUnionType( \type ) ) { return resolveUnionField( e, \type, name ); }
	return e@\message = error( fieldReferenceError(), "member reference base type \'<typeToString(\type)>\' is not a structure or union", e@location );
}

public default Expr resolvePtrField( Expr e, Type recordType, list[Field] fields, str name ) {
	for( field( Type fieldType, id( fieldName ) ) <- fields, fieldName == name ) {
        return e@\type = fieldType;
	}
	
	return e@message = error( fieldReferenceError(), "no member named \'<name>\' in \'<typeToString(recordType)>\'", e@location );
}

public Expr resolveUnaryExpression( Expr e, Expr arg, TypeTree typeTree, Type category = number(), bool pointerArithmetic = false ) {
	if( isNotEligbleForResolvment( e ) ) { return e; }
	argType = getType( arg );

	if( argType in typeTree[ category ] ) { return e@\type = argType; } 
	if( pointerArithmetic && isPointerType( argType ) ) { return e@\type = argType; } 
	return e@message = error( unaryArgumentError(), "invalid argument type \'<typeToString(argType)>\' to unary expression", e@location );
}

public Decl resolveStruct( Decl d, list[Field] initFields, list[Field] fields ) {
	for( i <- [0..size(fields)] ) {
		fieldType = extractFieldType( fields[i] );
		initFieldType = extractFieldType( initFields[i] );
		
		if( !(fieldType in CTypeTree[ initFieldType ]) ) {
			return d@message = error( structAssignmentError(), "\'<typeToString(initFieldType)>\' not a subtype of \'<typeToString(fieldType)>\'", d@location );
		}
	}
	
	return d;
}

public Decl resolveStruct( Decl d, Expr init, str structName ) {
	if( isNotEligbleForResolvment( init ) ) { return d; }
	initType = getType( init );
	
	if( struct( list[Field] initFields ) := initType && struct( list[Field] fields ) := lookup( d@indextable, typeKey( structName,struct() ) ).\type ) {
		return resolveStruct( d, initFields, fields );
	}
	return d@message = error( structAssignmentError(), "initializing \'<typeToString(\type)>\' with an expression of incompatible type \'<typeToString(init@\type)>\'", d@location );
}

public Expr resolveBinaryExpression( Expr e, Type lhsType, Type rhsType, TypeTree typeTree ) {
	if( lhsType == rhsType ) { e@\type = lhsType; } 
	elseif( rhsType in typeTree[ lhsType ] ) { e@\type = lhsType; } 
	elseif( lhsType in typeTree[ rhsType ] ) { e@\type = rhsType; } 
	else { e@message = error( binaryArgumentError(), "operator can not be applied to \'<typeToString(lhsType)>\' and \'<typeToString(rhsType)>\'", e@location ); }
	return e;
}

public Expr resolveBinaryExpression( Expr e, Expr lhs, Expr rhs, TypeTree typeTree, Type category = number(), Type override=empty(), bool pointerArithmetic = false ) {
	if( isNotEligbleForResolvment( lhs ) || isNotEligbleForResolvment( rhs ) ) { return e; }
	lhsType = getType( lhs );
	rhsType = getType( rhs );
	
	if( pointerArithmetic && arePointerArithmeticTypes( lhsType, rhsType, typeTree[ usint8() ] ) ) { 
		return resolvePointerArithmetic( e, lhsType, rhsType, typeTree[ usint8() ] );
	} 
	
	if( ! fittingTypes( typeTree[ category ], [lhsType, rhsType] ) ) {
		return e@message = error( nonFittingTypesError(), "operator can not be applied to \'<typeToString(lhsType)>\' and \'<typeToString(rhsType)>\'", e@location );
	}
		
	e = resolveBinaryExpression( e, lhsType, rhsType, typeTree );
	
	if( !isEmpty( override ) ) { e@\type = override; }
	
	return e;
}

default &T <: node resolvePointerAssignment( &T <: node n, lhsType, rhsType, Type \type ) {
	if( lhsType in CTypeTree[ rhsType ] ) {
		if( isExpression( n ) ) { n@\type = \type; }
	} else {
		n@message = error( pointerAssignmentError(), "type \'<typeToString(rhsType)>\' is not a subtype of type \'<typeToString(lhsType)>\'", n@location );
	}
	return n;
} 
&T <: node resolvePointerAssignment( &T <: node n, pointer( lhsType ), pointer( rhsType ), Type \type ) = resolvePointerAssignment( n, lhsType, rhsType, \type );

default Expr resolveAssignment( Expr e, _, _, _, _, _ ) = e[@message = error( "expression <delAnnotationsRec(lhs)> is not assignable", e@location )];
Expr resolveAssignment(  Expr e, Expr lhs:var( id( name ) ), Expr rhs, TypeTree typeTree, Type category = usint8(), bool pointerArithmetic = false ) {
	if( ! contains( e@indextable, symbolKey(name) ) ) { return e; }
	if( isNotEligbleForResolvment( rhs ) || isNotEligbleForResolvment( lhs ) ) { return e; }

	lhsType = lookup( e@indextable, symbolKey(name) ).\type;
	lhsType = resolveTypeDefs( e@indextable, lhsType );
	rhsType = getType( rhs );	

	if( pointerArithmetic && arePointerArithmeticTypes( lhsType, rhsType, typeTree[ usint8() ] ) ) { 
		return resolveAssignmentPointerArithmetic( e, lhsType, rhsType, typeTree[ usint8() ] ); 	
	}
	
	if( isPointerType( lhsType ) && isPointerType( rhsType ) ) { 
		return resolvePointerAssignment( e, lhsType, rhsType, lhsType );
	}
	
	if( ! fittingTypes( typeTree[ category ], [ lhsType, rhsType ] ) ) {
		return e@message = error( nonFittingTypesError(), "assigment operator can not be applied to \'<typeToString(lhsType)>\' and \'<typeToString(rhsType)>\'", e@location );
	}
	
	if( lhsType in typeTree[ rhsType ] ) {
		return e@\type = lhsType;
	} else {
		return e@message = error( incompatibleTypesError(),"type \'<typeToString(rhsType)>\' is not a subtype of type \'<typeToString(lhsType)>\'", e@location);
	}
	
	return e;
}

Decl resolveVariableAssignment( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init), Type initType ) {
	if( function( Type returnType, list[Type] args ) := \type ) {
		
		return resolveVariableFunctionAssignment( v, args, returnType, initType );
		
	} elseif( isPointerType( \type ) && isPointerType( initType ) ) {
		
		return resolvePointerAssignment( v, \type, initType, \type );
		
	} elseif( !( \type in CTypeTree[ initType ] ) ) {
		
		return v@message = error( incompatibleTypesError(), "\'<typeToString(initType)>\' not a subtype of \'<typeToString(\type)>\'", v@location );
		
	}
	
	return v;
}

Decl resolveVariableFunctionAssignment( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init), args, Type returnType, Type initType ) {
	if( function( Type initReturnType, list[Type] initArgs ) := initType ) {
		v = resolveVariableFunctionAssignment( v, args, initArgs, returnType, initType, initReturnType );
	} else {
		v@message = error( functionAssignmentError(),"expected function but got \'<typeToString(initType)>\'", v@location );
	}
	
	return v;
}

Decl resolveVariableFunctionAssignment( Decl v, args, initArgs, Type returnType, Type initType, Type initReturnType ) {
	if( !(returnType in CTypeTree[initReturnType]) ) {
		v@message = error( functionAssignmentError(),"expected function with return type \'<typeToString(returnType)>\' but got \'<typeToString(initReturnType)>\'", v@location );
	} else if( args != initArgs ) {
		v@message = error( functionAssignmentError(),"expected function with argument types \'<for( arg <- args ){><typeToString(arg)>,<}>\' but got \'<for( initArgs <- initArgs ){><typeToString(initArgs)>,<}>\'", v@location );
	}
	
	return v;
}

Expr resolveCall( Expr e, Type returnType, list[Expr] args, list[Type] argsTypes ) {		
	if( size( argsTypes ) != size( args ) ) {
		return e[@message = error( argumentsMismatchError(),  "too many arguments to function call, expected <size(argsTypes)>, have <size(args)>", e@location )];
	}
	
	for( int i <- [0..size(args)] ) {
		if( ! ( argsTypes[ i ] == getType( args[ i ] ) || argsTypes[ i ] in CTypeTree[ getType( args[ i ] ) ] ) ) {
			e@message = error( argumentsMismatchError(), "wrong argument type(s)", e@location );
		}
	}
	
	e@\type = returnType;
	
	return e;
}

Expr resolveCall( Expr e:call( v:var( id( func ) ), list[Expr] args ), IndexTable table ) {
	if( contains( table, symbolKey(func) ) && function(Type returnType, list[Type] argsTypes) := lookup( table, symbolKey(func) ).\type ) {
		e = resolveCall( e, returnType, args, argsTypes );
	} else {
		e@message = error( referenceError(), "calling undefined function \'<func>\'", e@location );
	}
	
	return e;
}

Expr resolveSubScript2( Expr e, Type \type, Type subType ) {
	if( subType in CIntegerTypeTree[ int8() ] ) {
		e@\type = \type;
	} else {
		e@message = error( subscriptMisuseError(), "array subscript is not an integer", sub@location );
	}
}

Expr resolveSubScript( Expr e, Type arrayType, Type subType ) {
	if( array( \type ) := arrayType || array( \type, _ ) := arrayType || pointer( \type ) := arrayType ) {
		e = resolveSubScript2( e, \type, subType );
	} else {
		e@message = error( subscriptMismatchError(),"subscripted value is not an array, pointer, or vector", array@location );
	}	
	
	return e;
}

Type resolveTypeDefs( IndexTable table, Type \type ) {
	return visit( \type ) {
		case Type t:id( id( typeDefName ) ) : {
			if( contains( table, typeKey( typeDefName,typedef() ) ) ) {
				insert lookup( table, typeKey( typeDefName,typedef() ) ).\type;
			} else {
            	return empty();
			}
		}
	}
}
