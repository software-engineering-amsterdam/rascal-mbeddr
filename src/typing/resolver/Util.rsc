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
