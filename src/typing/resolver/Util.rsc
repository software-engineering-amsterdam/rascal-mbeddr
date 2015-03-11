module typing::resolver::Util
extend typing::resolver::ResolverBase;

public Expr resolveField( Expr e, Type \type, str name ) {
	if( struct( id( structName ) ) := \type ) {
		typetable = e@typetable;
		
		if( struct(list[Field] fields) := typetable[ < structName, struct() > ].\type ) {
			return resolvePtrField( e, \type, fields, name );
		}
			
	} elseif( union( id( unionName ) ) := \type ) {
	
		if( union(list[Field] fields) := typetable[ < structName, struct() > ].\type ) {
			return resolvePtrField( e, \type, fields, name );
		}
	
	} else {
		return e@\message = error( "member reference base type \'<typeToString(\type)>\' is not a structure or union", e@location );
	}
}

public Expr resolvePtrField( Expr e, Type record_type, list[Field] fields, str name ) {
	for( field( Type fieldType, id( fieldName ) ) <- fields ) {
		if( fieldName == name ) {
			return e@\type = fieldType;
		}
	}
	
	return e@message = error( "no member named \'<name>\' in \'<typeToString(record_type)>\'", e@location );
}

public Expr resolveUnaryExpression( Expr e, Expr arg, TypeTree typeTree, Type category = number(), bool pointerArithmetic = false ) {
	arg_type = getType( arg );
	
	if( isEmpty(arg_type ) ) { return e; }

	if( arg_type in typeTree[ category ] ) {
		return e@\type = arg_type;
	} elseif( pointerArithmetic && pointer( \type ) := arg_type ) {
		return e@\type = arg_type;
	} else {
		return e@message = error( "invalid argument type \'<typeToString(arg_type)>\' to unary expression", e@location );
	}
}


public Decl resolveStruct( Decl d, Expr init, str structName ) {
	init_type = getType( init );
	
	if( isEmpty(init_type ) ) { return d; }
	
	if( struct( list[Field] initFields ) := init_type && 
		struct( list[Field] fields ) := d@typetable[ <structName,struct()> ].\type
	) {
		for( i <- [0..size(fields)] ) {
			if( field(Type fieldType,_) := fields[i] && 
				field(Type initFieldType,_) := initFields[i] 
			) {
				if( !(fieldType in CTypeTree[ initFieldType ]) ) {
					return d@message = error(  "\'<typeToString(initFieldType)>\' not a subtype of \'<typeToString(fieldType)>\'", d@location );
				} 
			}
		}
		
		
	} else {
		return d@message = error(  "initializing \'<typeToString(\type)>\' with an expression of incompatible type \'<typeToString(init@\type)>\'", d@location );
	}
	
	return d;
}

public Expr resolveBinaryExpression( Expr e, Expr lhs, Expr rhs, TypeTree typeTree, Type category = number(), Type override=empty(), bool pointerArithmetic = false ) {
	lhs_type = getType( lhs );
	rhs_type = getType( rhs );
	
	if( isEmpty(lhs_type ) || isEmpty(rhs_type ) ) return e; 

	if( pointerArithmetic &&  ( pointer( \type ) := lhs_type && rhs_type in typeTree[ int8() ] || pointer( \type ) := rhs_type && lhs_type in typeTree[ int8() ] ) ) {
		return e@\type = pointer( \type );
	} elseif( !( lhs_type in typeTree[ category ] || rhs_type in typeTree[ category ] ) ) {
		return e@message = error(  "operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
	}

	if( lhs_type == rhs_type ) {
		e@\type = lhs_type;
	} elseif( rhs_type in typeTree[ lhs_type ] ) {
		e@\type = lhs_type;
	} elseif( lhs_type in typeTree[ rhs_type ] ) {
		e@\type = rhs_type;
	} else {
		e@message = error(  "operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
	}
	
	if( !isEmpty( override ) ) {
		e@\type = override;
	}
	
	return e;
}

default &T <: node resolvePointerAssignment( &T <: node n, lhs_type, rhs_type ) {
	if( lhs_type in CTypeTree[ rhs_type ] ) {
		return n;
	} else {
		return n[@message = error( "type \'<typeToString(rhs_type)>\' is not a subtype of type \'<typeToString(lhs_type)>\'", n@location )];
	}
} 
&T <: node resolvePointerAssignment( &T <: node n, pointer( lhs_type ), pointer( rhs_type ) ) = resolvePointerAssignment( n, lhs_type, rhs_type );

Expr resolveAssignment(  Expr e, Expr lhs, Expr rhs, TypeTree typeTree, Type category = int8(), bool pointerArithmetic = false ) {
	if( var( id( name ) ) := lhs ) {
		
		if( isEmpty( getType( lhs ) ) ) { return e; }
		
		if( !( name in e@symboltable ) ) {
			return e@message = error( "use of undeclared identifier \'<name>\'", e@location );
		}
		
		lhs_type = e@symboltable[ name ].\type;
		rhs_type = getType( rhs );	
		
		if( isEmpty(rhs_type ) ) { return e; }
		
		if( pointerArithmetic && pointer( \type ) := lhs_type && rhs_type in typeTree[ int8() ] ) { 
			return e@\type = lhs_type;
		} elseif( pointer( _ ) := lhs_type && pointer( _ ) := rhs_type ) { 
			e = resolvePointerAssignment( e, lhs_type, rhs_type );
			
			if( !("message" in getAnnotations(e)) ) {
				return e@\type = lhs_type;
			} else {
				return e;
			}
			
		} elseif( !( lhs_type in typeTree[ category ] || rhs_type in typeTree[ category ] ) ) {
			return e@message = error(  "assigment operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
		}
		
		if( lhs_type in typeTree[ rhs_type ] ) {
			return e@\type = lhs_type;
		} else {
			return e@message = error( "type \'<typeToString(rhs_type)>\' is not a subtype of type \'<typeToString(lhs_type)>\'", e@location);
		}
	} else {
		return e@message = error( "expression <delAnnotationsRec(lhs)> is not assignable", e@location );
	}
	
	return e;
}


Decl resolveVariableAssignment( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init), Type init_type ) {
	if( function( Type return_type, list[Type] args ) := \type ) {
		return resolveVariableFunctionAssignment( v, init_type );
	} elseif( pointer(_) := \type && pointer(_) := init_type ) {
		return resolvePointerAssignment( v, \type, init_type );
	} elseif( !( \type in CTypeTree[ init_type ] ) ) {
		return v@message = error(  "\'<typeToString(init_type)>\' not a subtype of \'<typeToString(\type)>\'", v@location );
	}
	
	return v;
}

Decl resolveVariableFunctionAssignment( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init), Type init_type ) {
	if( function( Type init_return_type, list[Type] init_args ) := init_type ) {
		
		if( !(return_type in CTypeTree[init_return_type]) ) {
			v@message = error( "expected function with return type \'<typeToString(return_type)>\' but got \'<typeToString(init_return_type)>\'", v@location );
		} else if( args != init_args ) {
			v@message = error( "expected function with argument types \'<for( arg <- args ){><typeToString(arg)>,<}>\' but got \'<for( init_arg <- init_args ){><typeToString(init_arg)>,<}>\'", v@location );
		}
		
	} else {
		return v@message = error( "expected function but got \'<typeToString(init_type)>\'", v@location );
	}
	
	return v;
}

Expr resolveCall( Expr e:call( v:var( id( func ) ), list[Expr] args ), IndexTable symbols ) {
	if( func in symbols && function(Type returnType, list[Type] argsTypes) := symbols[ func ].\type ) {
		
		if( size( argsTypes ) != size( args ) ) {
			return e[@message = error(  "too many arguments to function call, expected <size(argsTypes)>, have <size(args)>", e@location )];
		} 
		
		for( int i <- [0..size(args)] ) {
			if( ! ( argsTypes[i] in CTypeTree[ getType( args[ i ] ) ] ) ) {
				e@message = error(  "wrong argument type(s)", e@location );
			}
		}
		
		e@\type = returnType;
		
	} else {
		e@message = error(  "calling undefined function \'<func>\'", e@location );
	}
	
	return e;
}

Expr resolveSubScript( Expr e, Type array_type, Type sub_type ) {
	if( array( \type ) := array_type || array( \type, _ ) := array_type || pointer( \type ) := array_type ) {
	
		if( sub_type in CIntegerTypeTree[ int8() ] ) {
			e@\type = \type;
		} else {
			e@message = error(  "array subscript is not an integer", sub@location );
		}
		
	} else {
		e@message = error( "subscripted value is not an array, pointer, or vector", array@location );
	}	
	
	return e;
}

