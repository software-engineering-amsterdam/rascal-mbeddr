module typing::Evaluator

import List;
import Node;
import IO;

import util::Util;
import lang::mbeddr::AST;
import typing::IndexTable;
import typing::TypeTree;

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
	
	
	n = top-down-break visit( n ) {

		case Expr e : {
			try {
				e@\type = evaluate( e );
				insert e;
			} catch TypeCheckerError( msg, l ) : {
				println("error: <msg>, location: <l>");
			}
		}
				
	}
	
	top-down visit( n ) {
		
		case Decl d : {
			try {
				evaluate( d );
			} catch TypeCheckerError( msg, l ) : {
				println("error: <msg>, location: <l>");
			}
		}
		
	}
	
	return n;
	
}

// EVALUATOR HELPERS

private Type evaluateField( Expr e, Type \type, str name ) {
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
		throw TypeCheckerError( "member reference base type \'<typeToString(\type)>\' is not a structure or union", e@location );
	}
}

private Type evaluatePtrField( Expr e, Type record_type, list[Field] fields, str name ) {
	for( field( Type fieldType, id( fieldName ) ) <- fields ) {
		if( fieldName == name ) {
			return fieldType;
		}
	}
	
	throw TypeCheckerError("no member named \'<name>\' in \'<typeToString(record_type)>\'", e@location );
}

Type evaluateUnaryExpression( Expr e, Expr arg, TypeTree typeTree, Type category = number(), bool pointerArithmetic = false ) {
	arg_type = evaluate( arg );

	if( arg_type in typeTree[ category ] ) {
		return arg_type;
	} elseif( pointerArithmetic && pointer( \type ) := arg_type ) {
		return arg_type;
	} else {
		throw TypeCheckerError("invalid argument type \'<typeToString(arg_type)>\' to unary expression", e@location );
	}
}


void evaluateStructInit( Decl v, Expr init, str structName ) {
	if( struct( list[Field] initFields ) := init@\type && 
		struct( list[Field] fields ) := v@typetable[ <structName,struct()> ].\type
	) {
	
		for( i <- [0..size(fields)] ) {
			if( field(Type fieldType,_) := fields[i] && 
				field(Type initFieldType,_) := initFields[i] 
			) {
				if( !(initFieldType in CTypeTree[ fieldType ]) ) {
					throw TypeCheckerError( "\'<typeToString(initFieldType)>\' not a subtype of \'<typeToString(fieldType)>\'", v@location );
				} 
			}
		}
		
		
	} else {
		throw TypeCheckerError( "initializing \'<typeToString(\type)>\' with an expression of incompatible type \'<typeToString(init@\type)>\'", v@location );
	}
}


Type evaluateBinaryExpression( Expr e, Expr lhs, Expr rhs, TypeTree typeTree, Type category = number(), bool pointerArithmetic = false ) {
	lhs_type = evaluate( lhs );
	rhs_type = evaluate( rhs );

	if( pointerArithmetic && pointer( \type ) := lhs_type && rhs_type in typeTree[ int8() ] || pointer( \type ) := rhs_type && lhs_type in typeTree[ int8() ] ) {
		return pointer( \type );
	} elseif( !( lhs_type in typeTree[ category ] || rhs_type in typeTree[ category ] ) ) {
		throw TypeCheckerError( "operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
	}

	if( lhs_type == rhs_type ) {
		return lhs_type;
	} elseif( rhs_type in typeTree[ lhs_type ] ) {
		return lhs_type;
	} elseif( lhs_type in typeTree[ rhs_type ] ) {
		return rhs_type;
	} else {
		throw TypeCheckerError( "operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
	}
}

// DECLARATION EVALUATORS

default void evaluate( Decl d ) {
	
	if( f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats) := d ) {
		int returns = 0;
		
		top-down-break visit( stats ) {
			case returnExpr(Expr expr) : {
				returns += 1;
				
				if( !( \type in CTypeTree[ expr@\type ] ) ) {
					throw TypeCheckerError( "return type \'<typeToString(expr@\type)>\' not a subtype of expected type \'<typeToString(\type)>\'", \type@location );	
				}
			}
		}
		
		if( returns == 0 && \type != \void() ) {
			throw TypeCheckerError( "control reaches end of non-void function", f@location );
		}
		
	}
	
	return;
}

void evaluate( v:variable(list[Modifier] mods, Type \type, id( name ), Expr init) ) {
	
	if( id( id( typeName ) ) := \type ) {
		\type = v@typetable[ <typeName,typedef()> ].\type;
	}
	
	if( struct( id( structName ) ) := \type ) {
		evaluateStructInit( v, init, structName );
	} elseif( !( \type in CTypeTree[ init@\type ] ) ) {
		throw TypeCheckerError( "\'<typeToString(init@\type)>\' not a subtype of \'<typeToString(\type)>\'", v@location );
	} 
}

// EXPRESSION EVALUATORS

default Type evaluate( Expr e ) {
	throw TypeCheckerError( "type checker does not know expression <e>", e@location );
} 

// VARIABLES

Type evaluate( e:var( id( name ) ) ) {
	table = e@symboltable;
	typetable = e@typetable;
	
	if( name in table ) {
		\type = table[ name ].\type;
		
		// Resolve typedefs
		if( id( id( typeDefName ) ) := \type ) {
			\type = typetable[ <typeDefName,typedef()> ].\type;
		}
		
		return \type;
	} else {
		throw TypeCheckerError( "use of undeclared variable \'<name>\'", e@location );
	}
}

// LITERALS

Type evaluate( e:lit( \int( v ) ) ) = int8();

Type evaluate( e:lit( char( v ) ) ) = char();

Type evaluate( e:lit( float( v ) ) ) = float();

Type evaluate( e:lit( hex( v ) ) ) = int8();

Type evaluate( e:lit( string( v ) ) ) = pointer( char() );

// EXPRESSIONS

Type evaluate( e:subscript( Expr array, Expr sub )  ) {
	array_type = evaluate( array );
	
	if( array( \type ) := array_type || array( \type, _ ) := array_type || pointer( \type ) := array_type ) {
		
		sub_type = evaluate( sub );
		
		if( sub_type in CIntegerTypeTree[ int8() ] ) {
			return \type;
		} else {
			throw TypeCheckerError( "array subscript is not an integer", sub@location );
		}
		
	} else {
		throw TypeCheckerError( "subscripted value is not an array, pointer, or vector", array@location );
	}	
}

Type evaluate( e:call( var( id( func ) ), list[Expr] args ) ) {
	table = e@symboltable;
	
	if( func in table && function(Type returnType, list[Type] argsTypes) := table[ func ].\type ) {
		
		if( size( argsTypes ) != size( args ) ) {
			throw TypeCheckerError( "too many arguments to function call, expected <size(argsTypes)>, have <size(args)>", e@location );
		} 
		
		for( int i <- [0..size(args)] ) {
			if( ! ( argsTypes[i] in CTypeTree[ evaluate( args[ i ] ) ] ) ) {
				throw TypeCheckerError( "wrong argument type(s)", e@location );
			}
		}
		
		return returnType;
		
	} else {
		throw TypeCheckerError( "calling undefined function \'<func>\'", e@location );
	}
}

Type evaluate( e:sizeof( Type \type ) ) = int8();

Type evaluate( e:structInit( list[Expr] records ) ) {
	// TODO: support C99 syntax for struct initialization ({.id=expr})
	return struct([ field( evaluate( record ), id("") ) | record <- records ]);
}

Type evaluate( e:dotField( Expr record, id( name ) ) ) {
	record_type = evaluate( record );
	
	return evaluateField( e, record_type, name );
}

Type evaluate( e:ptrField( Expr record, id( name ) ) ) {
	Type record_type = evaluate( record );
	if( pointer( Type \type ) := record_type ) {
		return evaluateField( e, \type, name );
	} else {
		throw TypeCheckerError( "member reference type \'<typeToString(record_type)>\' is not a pointer", e@location );
	}
}

Type evaluate( e:postIncr( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Type evaluate( e:postDecr( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Type evaluate( e:preIncr( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Type evaluate( e:preDecr( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=number(), pointerArithmetic=true );

Type evaluate( e:addrOf( Expr arg ) ) = pointer( evaluate( arg ) );

Type evaluate( e:refOf( Expr arg ) ) {
	arg_type = evaluate( arg );
	
	if( pointer( \type ) := arg_type ) {
		return \type;
	} else {
		throw TypeCheckerError( "indirection requires pointer operand (\'<typeToString(arg_type)>\' invalid)", e@location );
	}
}

Type evaluate( e:pos( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree );

Type evaluate( e:neg( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree );

Type evaluate( e:bitNot( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree );

Type evaluate( e:not( Expr arg ) ) = evaluateUnaryExpression( e, arg, CTypeTree, category=boolean() );

Type evaluate( e:sizeOfExpr( Expr arg ) ) = int8();

Type evaluate( e:cast( Type \type, Expr arg ) ) = \type;

Type evaluate( e:mul( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CTypeTree );

Type evaluate( e:div( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CTypeTree );

Type evaluate( e:\mod( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Type evaluate( e:add( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Type evaluate( e:sub( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true ); 

Type evaluate( e:shl( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Type evaluate( e:shr( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Type evaluate( e:lt( Expr lhs, Expr rhs ) ) { 
	evaluateBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number() );
	return \boolean();	
}

Type evaluate( e:gt( Expr lhs, Expr rhs ) ) { 
	evaluateBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number() );
	return \boolean();	
}

Type evaluate( e:leq( Expr lhs, Expr rhs ) ) { 
	evaluateBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number() );
	return \boolean();	
}

Type evaluate( e:geq( Expr lhs, Expr rhs ) ) { 
	evaluateBinaryExpression( e, lhs, rhs, COrderedTypeTree, category=\number() );
	return \boolean();	
}

Type evaluate( e:eq( Expr lhs, Expr rhs ) ) { 
	evaluateBinaryExpression( e, lhs, rhs, CEqualityTypeTree, category=\number() );
	return \boolean();	
}

Type evaluate( e:neq( Expr lhs, Expr rhs ) ) { 
	evaluateBinaryExpression( e, lhs, rhs, CEqualityTypeTree, category=\number() );
	return \boolean();	
}

Type evaluate( e:bitAnd( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Type evaluate( e:bitXor( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Type evaluate( e:bitOr( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=int8() );

Type evaluate( e:and( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=boolean() );

Type evaluate( e:or( Expr lhs, Expr rhs ) ) = evaluateBinaryExpression( e, lhs, rhs, CIntegerTypeTree, category=boolean() );

Type evaluate( e:cond( Expr cond, Expr then, Expr els ) ) {
	cond_type = evaluate( cond );
	if( cond_type != \boolean() ) {
		throw TypeCheckerError( "\'<typeToString(cond_type)>\' is not a subtype of \'boolean\'", e@location ); 
	}
	
	then_type = evaluate( then );
	els_type = evaluate( els );
	
	if( then_type != els_type ) {
		throw TypeCheckerError( "<typeToString(then_type)>/<typeToString(els_type)> type mismatch in conditional expression (\'<typeToString(then_type)>\' and \'<typeToString(els_type)>\')", e@location );
	} 
	
	return then_type;
}

Type evaluateAssignment(  Expr e, Expr lhs, Expr rhs, TypeTree typeTree, Type category = int8(), bool pointerArithmetic = false ) {
	if( var( id( name ) ) := lhs ) {
		
		if( !( name in e@symboltable ) ) {
			throw TypeCheckerError( "use of undeclared identifier \'<name>\'", e );
		}
		
		lhs_type = e@symboltable[ name ].\type;
		rhs_type = evaluate( rhs );	
		
		if( pointerArithmetic && pointer( \type ) := lhs_type && rhs_type in typeTree[ int8() ] ) { 
			return lhs_type;
		} elseif( !( lhs_type in typeTree[ category ] || rhs_type in typeTree[ category ] ) ) {
			throw TypeCheckerError( "assigment operator can not be applied to \'<typeToString(lhs_type)>\' and \'<typeToString(rhs_type)>\'", e@location );
		}
		
		if( lhs_type in typeTree[ rhs_type ] ) {
			return lhs_type;
		} else {
			throw TypeCheckerError("type \'<typeToString(rhs_type)>\' is not a subtype of type \'<typeToString(lhs_type)>\'", e@location);
		}
	} else {
		throw TypeCheckerError("expression <delAnnotationsRec(lhs)> is not assignable", e@location );
	}
}

Type evaluate( e:assign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree );

Type evaluate( e:mulAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree, category=number() );

Type evaluate( e:divAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree, category=number() );

Type evaluate( e:modAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Type evaluate( e:addAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Type evaluate( e:subAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CTypeTree, category=number(), pointerArithmetic=true );

Type evaluate( e:shlAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Type evaluate( e:shrAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Type evaluate( e:bitAndAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Type evaluate( e:bitXorAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );

Type evaluate( e:bitOrAssign( Expr lhs, Expr rhs ) ) = evaluateAssignment( e, lhs, rhs, CIntegerTypeTree );
