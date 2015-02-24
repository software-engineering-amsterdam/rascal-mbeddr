module typing::Evaluator

import List;
import Node;
import IO;
import Message;

import util::Util;
import lang::mbeddr::AST;
import typing::IndexTable;
import typing::TypeTree;

data Type = empty();

anno Type Expr @ \type;

Module evaluator( m:\module( name, imports, decls ) ) = evaluator( m, (), () );

Module evaluator( &T <: node n, SymbolTable table, TypeTable types ) {
	
	n = top-down visit( n ) {
		case node n : {
			annos = getAnnotations( n );

			if( "symboltable" in annos ) {
				table = n@symboltable;
			} else {
				n = n[@symboltable = table];
			}
			
			if( "typetable" in annos ) {
				types = n@typetable;
			} else {
				n = n[@typetable = types];
			}
			
			insert n;
		}
	}
	
	
	n = visit( n ) {

		case Expr e => evaluate( e )
		
		case Decl d => evaluate( d )
				
	}

	return n;	
}

Type getType( &T <: node n ) {
	if( "type" in getAnnotations( n ) ) {
		return n@\type;
	} else {
		return empty();
	}
}

// EVALUATOR HELPERS

private Expr evaluateField( Expr e, Type \type, str name ) {
	if( struct( id( structName ) ) := \type ) {
		typetable = e@typetable;
		
		if( struct(list[Field] fields) := typetable[ < structName, struct() > ].\type ) {
			return evaluatePtrField( e, \type, fields, name );
		}
			
	} elseif( union( id( unionName ) ) := \type ) {
	
		if( union(list[Field] fields) := typetable[ < structName, struct() > ].\type ) {
			return evaluatePtrField( e, \type, fields, name );
		}
	
	} else {
		return e@\message = error( "member reference base type \'<typeToString(\type)>\' is not a structure or union", e@location );
	}
}

private Expr evaluatePtrField( Expr e, Type record_type, list[Field] fields, str name ) {
	for( field( Type fieldType, id( fieldName ) ) <- fields ) {
		if( fieldName == name ) {
			return e@\type = fieldType;
		}
	}
	
	return e@message = error( "no member named \'<name>\' in \'<typeToString(record_type)>\'", e@location );
}

private Expr evaluateUnaryExpression( Expr e, Expr arg, TypeTree typeTree, Type category = number(), bool pointerArithmetic = false ) {
	arg_type = getType( arg );
	
	if( empty() := arg_type ) { return e; }

	if( arg_type in typeTree[ category ] ) {
		return e@\type = arg_type;
	} elseif( pointerArithmetic && pointer( \type ) := arg_type ) {
		return e@\type = arg_type;
	} else {
		return e@message = error( "invalid argument type \'<typeToString(arg_type)>\' to unary expression", e@location );
	}
}


private Decl evaluateStruct( Decl d, Expr init, str structName ) {
	init_type = getType( init );
	
	if( empty() := init_type ) { return d; }
	
	if( struct( list[Field] initFields ) := init_type && 
		struct( list[Field] fields ) := d@typetable[ <structName,struct()> ].\type
	) {
	
		for( i <- [0..size(fields)] ) {
			if( field(Type fieldType,_) := fields[i] && 
				field(Type initFieldType,_) := initFields[i] 
			) {
				if( !(initFieldType in CTypeTree[ fieldType ]) ) {
					return d@message = error(  "\'<typeToString(initFieldType)>\' not a subtype of \'<typeToString(fieldType)>\'", d@location );
				} 
			}
		}
		
		
	} else {
		return d@message = error(  "initializing \'<typeToString(\type)>\' with an expression of incompatible type \'<typeToString(init@\type)>\'", d@location );
	}
}


private Expr evaluateBinaryExpression( Expr e, Expr lhs, Expr rhs, TypeTree typeTree, Type category = number(), bool pointerArithmetic = false ) {
	lhs_type = getType( lhs );
	rhs_type = getType( rhs );
	
	if( empty() := lhs_type || empty() := rhs_type ) return e; 

	if( pointerArithmetic && pointer( \type ) := lhs_type && rhs_type in typeTree[ int8() ] || pointer( \type ) := rhs_type && lhs_type in typeTree[ int8() ] ) {
		e@\type = pointer( \type );
	} elseif( !( lhs_type in typeTree[ category ] || rhs_type in typeTree[ category ] ) ) {
		e@message = error(  "operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
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
	
	return e;
}

Expr evaluateAssignment(  Expr e, Expr lhs, Expr rhs, TypeTree typeTree, Type category = int8(), bool pointerArithmetic = false ) {
	if( var( id( name ) ) := lhs ) {
		
		if( !( name in e@symboltable ) ) {
			return e@message = error(  "use of undeclared identifier \'<name>\'", e );
		}
		
		lhs_type = e@symboltable[ name ].\type;
		rhs_type = getType( rhs );	
		
		if( empty() := rhs_type ) { return e; }
		
		if( pointerArithmetic && pointer( \type ) := lhs_type && rhs_type in typeTree[ int8() ] ) { 
			return e@\type = lhs_type;
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

// DECLARATION EVALUATORS

default Decl evaluate( Decl d ) = d;

Decl evaluate( Decl f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats) ) {
	int returns = 0;
	
	top-down-break visit( stats ) {
		case returnExpr(Expr expr) : {
			returns += 1;
			
			if( !( \type in CTypeTree[ expr@\type ] ) ) {
				return f@message = error(  "return type \'<typeToString(expr@\type)>\' not a subtype of expected type \'<typeToString(\type)>\'", \type@location );	
			}
		}
	}
	
	if( returns == 0 && \type != \void() ) {
		return f@message = error(  "control reaches end of non-void function", f@location );
	}
	
	return f;	
}

Decl evaluate( Decl v:variable(list[Modifier] mods, Type \type, id( name ), Expr init) ) {
	
	if( id( id( typeName ) ) := \type ) {
		\type = v@typetable[ <typeName,typedef()> ].\type;
	}
	
	if( struct( id( structName ) ) := \type ) {
		evaluateStruct( v, init, structName );
	} elseif( !( \type in CTypeTree[ init@\type ] ) ) {
		return v@message = error(  "\'<typeToString(init@\type)>\' not a subtype of \'<typeToString(\type)>\'", v@location );
	} 
	
	return v;
}

// EXPRESSION EVALUATORS

default Expr evaluate( Expr e ) {
	return e@message = warning( "unkown expression to typechecker", e@location );
} 

// VARIABLES

Expr evaluate( Expr e:var( id( name ) ) ) {
	table = e@symboltable;
	typetable = e@typetable;
	
	if( name in table ) {
		\type = table[ name ].\type;
		
		// Resolve typedefs
		if( id( id( typeDefName ) ) := \type ) {
			\type = typetable[ <typeDefName,typedef()> ].\type;
		}
		
		return e@\type = \type;
	} else {
		return e@message = error( "use of undeclared variable \'<name>\'", e@location );
	}
}

// LITERALS

Expr evaluate( Expr e:lit( \int( v ) ) ) { return e@\type = int8(); }

Expr evaluate( Expr e:lit( char( v ) ) ) { return e@\type = char(); }

Expr evaluate( Expr e:lit( float( v ) ) ) { return e@\type = float(); }

Expr evaluate( Expr e:lit( hex( v ) ) ) { return e@\type = int8(); }

Expr evaluate( Expr e:lit( string( v ) ) ) { return e@\type = pointer( char() ); }

// EXPRESSIONS

Expr evaluate( Expr e:subscript( Expr array, Expr sub )  ) {
	array_type = getType( array );
	sub_type = getType( sub );
	
	if( empty() := array_type || empty() := sub_type ) return e;
	
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

Expr evaluate( Expr e:call( var( id( func ) ), list[Expr] args ) ) {
	table = e@symboltable;
	
	if( func in table && function(Type returnType, list[Type] argsTypes) := table[ func ].\type ) {
		
		if( size( argsTypes ) != size( args ) ) {
			e@message = error(  "too many arguments to function call, expected <size(argsTypes)>, have <size(args)>", e@location );
		} 
		
		for( int i <- [0..size(args)] ) {
			if( ! ( argsTypes[i] in CTypeTree[ evaluate( args[ i ] ) ] ) ) {
				e@message = error(  "wrong argument type(s)", e@location );
			}
		}
		
		e@\type = returnType;
		
	} else {
		e@message = error(  "calling undefined function \'<func>\'", e@location );
	}
	
	return e;
}

Expr evaluate( Expr e:sizeof( Type \type ) ) { return e@\type = int8(); }

Expr evaluate( Expr e:struct( list[Expr] records ) ) {
	// TODO: support C99 syntax for struct initialization ({.id=expr})
	return e@\type = struct([ field( getType( record ), id("") ) | record <- records ]);
}

Expr evaluate( Expr e:dotField( Expr record, id( name ) ) ) {
	record_type = getType( record );
	
	if( empty() := record_type ) return e;
	
	return evaluateField( e, record_type, name );
}

Expr evaluate( Expr e:ptrField( Expr record, id( name ) ) ) {
	record_type = getType( record );
	
	if( empty() := record_type ) return e;
	
	if( pointer( Type \type ) := record_type ) {
		return evaluateField( e, \type, name );
	} else {
		return e@message = error(  "member reference type \'<typeToString(record_type)>\' is not a pointer", e@location );
	}
}

Expr evaluate( Expr e:postIncr( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr evaluate( Expr e:postDecr( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr evaluate( Expr e:preIncr( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr evaluate( Expr e:preDecr( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Expr evaluate( Expr e:addrOf( Expr arg ) ) { return e@\type = pointer( getType( arg ) ); }

Expr evaluate( Expr e:refOf( Expr arg ) ) {
	arg_type = getType( arg );
	
	if( empty() := arg_type ) return e;
	
	if( pointer( \type ) := arg_type ) {
		e@\type = \type;
	} else {
		e@message = error(  "indirection requires pointer operand (\'<typeToString(arg_type)>\' invalid)", e@location );
	}
	
	return e;
}

Expr evaluate( Expr e:pos( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree );

Expr evaluate( Expr e:neg( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree );

Expr evaluate( Expr e:bitNot( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree );

Expr evaluate( Expr e:not( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=boolean() );

Expr evaluate( Expr e:sizeOfExpr( Expr arg ) ) { return e@\type = int8(); }

Expr evaluate( Expr e:cast( Type \type, Expr arg ) ) { return e@\type; }

Expr evaluate( Expr e:mul( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CTypeTree );

Expr evaluate( Expr e:div( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CTypeTree );

Expr evaluate( Expr e:\mod( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr evaluate( Expr e:add( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Expr evaluate( Expr e:sub( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true ); 

Expr evaluate( Expr e:shl( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr evaluate( Expr e:shr( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr evaluate( Expr e:lt( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number(), override=\boolean() );	

Expr evaluate( Expr e:gt( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number(), override=\boolean() );

Expr evaluate( Expr e:leq( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number(), override=\boolean() );

Expr evaluate( Expr e:geq( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number(), override=\boolean() );

Expr evaluate( Expr e:eq( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CEqualityTypeTree, category=\number(), override=\boolean() );

Expr evaluate( Expr e:neq( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CEqualityTypeTree, category=\number(), override=\boolean() );

Expr evaluate( Expr e:bitAnd( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr evaluate( Expr e:bitXor( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr evaluate( Expr e:bitOr( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Expr evaluate( Expr e:and( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=boolean() );

Expr evaluate( Expr e:or( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=boolean() );

Expr evaluate( Expr e:cond( Expr cond, Expr then, Expr els ) ) {
	cond_type = getType( cond );
	
	if( empty() := cond_type ) return e;
	
	if( cond_type != \boolean() ) {
		return e@message = error(  "\'<typeToString(cond_type)>\' is not a subtype of \'boolean\'", e@location ); 
	}
	
	then_type = getType( then );
	els_type = getType( els );
	
	if( empty() := then_type || empty() := els_type ) return e;
	
	if( then_type != els_type ) {
		return e@message = error(  "<typeToString(then_type)>/<typeToString(els_type)> type mismatch in conditional expression (\'<typeToString(then_type)>\' and \'<typeToString(els_type)>\')", e@location );
	} 
	
	return e@\type = then_type;
}

Expr evaluate( Expr e:assign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree );

Expr evaluate( Expr e:mulAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree, category=number() );

Expr evaluate( Expr e:divAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree, category=number() );

Expr evaluate( Expr e:modAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr evaluate( Expr e:addAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Expr evaluate( Expr e:subAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Expr evaluate( Expr e:shlAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr evaluate( Expr e:shrAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr evaluate( Expr e:bitAndAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr evaluate( Expr e:bitXorAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Expr evaluate( Expr e:bitOrAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );
