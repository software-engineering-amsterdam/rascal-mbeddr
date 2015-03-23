module typing::resolver::Base

import ext::List;
import ext::Node;
import IO;
import Message;

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

public Expr resolveAssignmentPointerArithmetic( Expr e, Type lhs_type, Type rhs_type, list[Type] integerTypes ) {
	if( isPointerType( lhs_type ) && rhs_type in integerTypes ) { e@\type = lhs_type; }
	return e;
}

public Expr resolveStructField( Expr e, Type \type, str name ) {
	typetable = e@typetable;
		
	if( struct(list[Field] fields) := typetable[ < \type.name.name, struct() > ].\type ) {
		e = resolvePtrField( e, \type, fields, name );
	}
	
	return e;
}

public Expr resolveUnionField( Expr e, Type \type, str name ) {
	typetable = e@typetable;
	
	if( union(list[Field] fields) := typetable[ < \type.name.name, union() > ].\type ) {
		e = resolvePtrField( e, \type, fields, name );
	}
	
	return e;
}

public default Expr resolveField( Expr e, Type \type, str name ) {
	if( isStructType( \type ) ) { return resolveStructField( e, \type, name ); }
	if( isUnionType( \type ) ) { return resolveUnionField( e, \type, name ); }
	return e@\message = error( "member reference base type \'<typeToString(\type)>\' is not a structure or union", e@location );
}

public default Expr resolvePtrField( Expr e, Type record_type, list[Field] fields, str name ) {
	for( field( Type fieldType, id( fieldName ) ) <- fields, fieldName == name ) {
        return e@\type = fieldType;
	}
	
	return e@message = error( "no member named \'<name>\' in \'<typeToString(record_type)>\'", e@location );
}

public Expr resolveUnaryExpression( Expr e, Expr arg, TypeTree typeTree, Type category = number(), bool pointerArithmetic = false ) {
	if( isNotEligbleForResolvment( e ) ) { return e; }
	arg_type = getType( arg );

	if( arg_type in typeTree[ category ] ) { return e@\type = arg_type; } 
	if( pointerArithmetic && isPointerType( arg_type ) ) { return e@\type = arg_type; } 
	return e@message = error( "invalid argument type \'<typeToString(arg_type)>\' to unary expression", e@location );
}

public Decl resolveStruct( Decl d, list[Field] initFields, list[Field] fields ) {
	for( i <- [0..size(fields)] ) {
		fieldType = extractFieldType( fields[i] );
		initFieldType = extractFieldType( initFields[i] );
		
		if( !(fieldType in CTypeTree[ initFieldType ]) ) {
			return d@message = error(  "\'<typeToString(initFieldType)>\' not a subtype of \'<typeToString(fieldType)>\'", d@location );
		}
	}
	
	return d;
}

public Decl resolveStruct( Decl d, Expr init, str structName ) {
	if( isNotEligbleForResolvment( init ) ) { return d; }
	init_type = getType( init );
	
	if( struct( list[Field] initFields ) := init_type && struct( list[Field] fields ) := d@typetable[ <structName,struct()> ].\type ) {
		return resolveStruct( d, initFields, fields );
	}
	return d@message = error(  "initializing \'<typeToString(\type)>\' with an expression of incompatible type \'<typeToString(init@\type)>\'", d@location );
}

public Expr resolveBinaryExpression( Expr e, Type lhs_type, Type rhs_type, TypeTree typeTree ) {
	if( lhs_type == rhs_type ) { e@\type = lhs_type; } 
	elseif( rhs_type in typeTree[ lhs_type ] ) { e@\type = lhs_type; } 
	elseif( lhs_type in typeTree[ rhs_type ] ) { e@\type = rhs_type; } 
	else { e@message = error(  "operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location ); }
	return e;
}

public Expr resolveBinaryExpression( Expr e, Expr lhs, Expr rhs, TypeTree typeTree, Type category = number(), Type override=empty(), bool pointerArithmetic = false ) {
	if( isNotEligbleForResolvment( lhs ) || isNotEligbleForResolvment( rhs ) ) { return e; }
	lhs_type = getType( lhs );
	rhs_type = getType( rhs );
	
	if( pointerArithmetic && arePointerArithmeticTypes( lhs_type, rhs_type, typeTree[ usint8() ] ) ) { 
		return resolvePointerArithmetic( e, lhs_type, rhs_type, typeTree[ usint8() ] );
	} 
	
	if( ! fittingTypes( typeTree[ category ], [lhs_type, rhs_type] ) ) {
		return e@message = error(  "operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
	}
		
	e = resolveBinaryExpression( e, lhs_type, rhs_type, typeTree );
	
	if( !isEmpty( override ) ) { e@\type = override; }
	
	return e;
}

default &T <: node resolvePointerAssignment( &T <: node n, lhs_type, rhs_type, Type \type ) {
	if( lhs_type in CTypeTree[ rhs_type ] ) {
		if( isExpression( n ) ) { n@\type = \type; }
	} else {
		n@message = error( "type \'<typeToString(rhs_type)>\' is not a subtype of type \'<typeToString(lhs_type)>\'", n@location );
	}
	return n;
} 
&T <: node resolvePointerAssignment( &T <: node n, pointer( lhs_type ), pointer( rhs_type ), Type \type ) = resolvePointerAssignment( n, lhs_type, rhs_type, \type );

default Expr resolveAssignment( Expr e, _, _, _, _, _ ) = e[@message = error( "expression <delAnnotationsRec(lhs)> is not assignable", e@location )];
Expr resolveAssignment(  Expr e, Expr lhs:var( id( name ) ), Expr rhs, TypeTree typeTree, Type category = usint8(), bool pointerArithmetic = false ) {
	if( ! contains( e@symboltable, name ) ) { return e; }
	if( isNotEligbleForResolvment( rhs ) || isNotEligbleForResolvment( lhs ) ) { return e; }

	lhs_type = lookup( e@symboltable, name ).\type;
	lhs_type = resolveTypeDefs( e@typetable, lhs_type );
	rhs_type = getType( rhs );	

	if( pointerArithmetic && arePointerArithmeticTypes( lhs_type, rhs_type, typeTree[ usint8() ] ) ) { 
		return resolveAssignmentPointerArithmetic( e, lhs_type, rhs_type, typeTree[ usint8() ] ); 	
	}
	
	if( isPointerType( lhs_type ) && isPointerType( rhs_type ) ) { 
		return resolvePointerAssignment( e, lhs_type, rhs_type, lhs_type );
	}
	
	if( ! fittingTypes( typeTree[ category ], [ lhs_type, rhs_type ] ) ) {
		return e@message = error(  "assigment operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
	}
	
	if( lhs_type in typeTree[ rhs_type ] ) {
		return e@\type = lhs_type;
	} else {
		return e@message = error( "type \'<typeToString(rhs_type)>\' is not a subtype of type \'<typeToString(lhs_type)>\'", e@location);
	}
	
	return e;
}

Decl resolveVariableAssignment( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init), Type init_type ) {
	if( function( Type return_type, list[Type] args ) := \type ) {
		return resolveVariableFunctionAssignment( v, args, return_type, init_type );
	} elseif( isPointerType( \type ) && isPointerType( init_type ) ) {
		return resolvePointerAssignment( v, \type, init_type, \type );
	} elseif( !( \type in CTypeTree[ init_type ] ) ) {
		return v@message = error(  "\'<typeToString(init_type)>\' not a subtype of \'<typeToString(\type)>\'", v@location );
	}
	
	return v;
}

Decl resolveVariableFunctionAssignment( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init), args, Type return_type, Type init_type ) {
	if( function( Type init_return_type, list[Type] init_args ) := init_type ) {
		v = resolveVariableFunctionAssignment( v, args, init_args, return_type, init_type, init_return_type );
	} else {
		v@message = error( "expected function but got \'<typeToString(init_type)>\'", v@location );
	}
	
	return v;
}

Decl resolveVariableFunctionAssignment( Decl v, args, init_args, Type return_type, Type init_type, Type init_return_type ) {
	if( !(return_type in CTypeTree[init_return_type]) ) {
		v@message = error( "expected function with return type \'<typeToString(return_type)>\' but got \'<typeToString(init_return_type)>\'", v@location );
	} else if( args != init_args ) {
		v@message = error( "expected function with argument types \'<for( arg <- args ){><typeToString(arg)>,<}>\' but got \'<for( init_arg <- init_args ){><typeToString(init_arg)>,<}>\'", v@location );
	}
	
	return v;
}

Expr resolveCall( Expr e, Type returnType, list[Expr] args, list[Type] argsTypes ) {		
	if( size( argsTypes ) != size( args ) ) {
		return e[@message = error(  "too many arguments to function call, expected <size(argsTypes)>, have <size(args)>", e@location )];
	}
	
	for( int i <- [0..size(args)] ) {
		if( ! ( argsTypes[ i ] == getType( args[ i ] ) || argsTypes[ i ] in CTypeTree[ getType( args[ i ] ) ] ) ) {
			e@message = error(  "wrong argument type(s)", e@location );
		}
	}
	
	e@\type = returnType;
	
	return e;
}

Expr resolveCall( Expr e:call( v:var( id( func ) ), list[Expr] args ), SymbolTable symbols ) {
	if( contains( symbols, func ) && function(Type returnType, list[Type] argsTypes) := lookup( symbols, func ).\type ) {
		e = resolveCall( e, returnType, args, argsTypes );
	} else {
		e@message = error(  "calling undefined function \'<func>\'", e@location );
	}
	
	return e;
}

Expr resolveSubScript2( Expr e, Type \type, Type sub_type ) {
	if( sub_type in CIntegerTypeTree[ int8() ] ) {
		e@\type = \type;
	} else {
		e@message = error(  "array subscript is not an integer", sub@location );
	}
}

Expr resolveSubScript( Expr e, Type array_type, Type sub_type ) {
	if( array( \type ) := array_type || array( \type, _ ) := array_type || pointer( \type ) := array_type ) {
		e = resolveSubScript2( e, \type, sub_type );
	} else {
		e@message = error( "subscripted value is not an array, pointer, or vector", array@location );
	}	
	
	return e;
}

Type resolveTypeDefs( TypeTable typetable, Type \type ) {
	return visit( \type ) {
		case Type t:id( id( typeDefName ) ) : {
			if( <typeDefName,typedef()> in typetable ) {
				insert typetable[ <typeDefName,typedef()> ].\type;
			} else {
            	return empty();
			}
		}
	}
}
