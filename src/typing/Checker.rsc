module typing::Checker

import Node;
import IO;

import lang::mbeddr::AST;

data DeclType = enum() | typedef() | struct();
data Scope 
	= global( )
	| function( Scope scope )
	| block( Scope scope )
	;

alias SymbolTableRow = tuple[Type \type,Scope scope,bool initialized];
alias SymbolTable = map[ str, SymbolTableRow ];

alias TypeTableRow = tuple[Type \type, Scope scope, bool initialized ];
alias TypeTable = map[ tuple[str,DeclType], TypeTableRow ];

data RuntimeException = TypeCheckerError( str message, node astNode );

SymbolTable store( SymbolTable table, 
				   TypeTable types, 
				   str name, 
				   SymbolTableRow row, 
				   node astNode ) {
	
	if( name in table && table[ name ].scope == row.scope ) {
		item = table[ name ];
		
		if( item.initialized ) {
			handleTypeError( "redefinition of \'<name>\'", astNode );
		} else if( item.\type != row.\type ) {
			handleTypeError("redefinition of \'<name>\' with a different type \'<delAnnotationsRec( row.\type )>\' vs \'<delAnnotationsRec( table[name].\type )>\'", astNode );
		} else if( row.initialized ) {
			return table[ name ].initialized = true;
		}
		
	} else if( name in table && function(_,_) := row.\type && function(_,_) := table[ name ].\type && row.\type != table[ name ].\type ) {
		
		handleTypeError( "confliciting types for \'<name>\'", astNode );
	
	} else {
		
		// Custom type
		if( id( id( typeName ) ) := row.\type && !doesTypeExist( types, typeName ) ) {
			handleTypeError("unknown type name \'<typeName>\'", astNode );
		} 
		
		// Struct type
		if( struct( id( structName ) ) := row.\type && !doesStructExist( types, structName ) ) {
			handleTypeError("unkown struct \'<structName>\'", astNode );
		}
		
		// Enum type
		if( enum( id( enumName ) ) := row.\type && !doesEnumExist( types, enumName ) ) {
			handleTypeError("unkown enum \'<enumName>\'", astNode );
		}
		
		return table[ name ] = row;
	
	}
	 
}

SymbolTableRow lookup( SymbolTable table, str name ) {
	if( name in table ) {
		return table[ name ];
	}
}

TypeTable store( TypeTable table, tuple[str,DeclType] key, TypeTableRow row, node astNode ) {
	if( key in table && 
		table[key].scope == row.scope 
		) {
		handleTypeError( "redefinition of \'<key>\'", astNode );
	} else {
		return table[key] = row;
	}
}

bool doesTypeExist( TypeTable types, str name ) {
	return <name,typedef()> in types;
}

bool doesStructExist( TypeTable types, str name ) {
	return <name,struct()> in types;
}

anno SymbolTable node @ symboltable;
anno TypeTable node @ typetable;

Module createSymbolTable( m:\module( name, imports, decls ) ) = \module( name, imports, createTopLevelSymbolTable( (), (), global(), decls ) );
list[Decl] createTopLevelSymbolTable( SymbolTable table, TypeTable types, Scope scope, list[Decl] decls ) {
	return for( Decl decl <- decls ) {
		result = visitor( table, types, scope, decl );
		table = result.table;
		types = result.types;
		append result.n;	
	}
	//decls = for( Decl decl <- decls ) {
	//	
	//	// Scope unique symbol table entries
	//	switch( decl ) {
	//		case f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats) : {
	//			table = store( table, types, name, < \function( \type, parameterTypes( params ) ), scope, true >, f );
	//			
	//			stats = createBlockSymbolTable( createParamSymbolTable( table, types, "function", params ), types, "function", stats );
	//			decl = function( mods, \type, id( name ), params, stats ); 
	//		}
	//	}
	//	
	//	// Scope independent symbol table entries
	//	table = createScopeIndependentSymbolTable( table, types, decl, scope ); 
	//	types = createScopeIndependentTypeTable( types, decl, scope );
	//	
	//	decl@symboltable = table;
	//	decl@typetable = types;
	//	
	//	append decl;
	//}
	//
	//return decls;
}

tuple[&T <: node n, SymbolTable table, TypeTable types] visitor( SymbolTable table, TypeTable types, Scope scope, &T <: node n ) {
	switch( n ) {
		// BLOCK STATEMENTS
		
		case b:block(list[Stat] stats) : {
			n = block( [ visitor(table,types,block(scope),stat).n | stat <- stats ] );
		}
		
		case ifThen(Expr cond, Stat body) : {
			n = ifThen( cond, visitor( table, types, block( scope ).n, body ) );	
		}
  		
  		case ifThenElse(Expr cond, Stat body, Stat els) : {
  			n = ifThenElse( cond, visitor( table, types, block( scope ), body ).n, visitor( table, types, block( scope ).n, els ) );
  		}
  		
  		case \for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body) : {
  			n = \for(init, conds, update, visitor( table, types, block( scope ), body ).n );
  		}
		
		// DECLARATIONS
		
		case f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats) : {
			table = store( table, types, name, < \function( \type, parameterTypes( params ) ), scope, true >, f );
			
			stats = [ visitor( createParamSymbolTable( table, types, function( scope ), params ), types, function(scope), stat).n | stat <- stats ];
			n = function( mods, \type, id( name ), params, stats );
		}
		
		case f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params) : {
			table = store( table, types, name, < \function( \type, parameterTypes( params ) ), scope, false >, f );
		}
		
		case v:variable(list[Modifier] mods, Type \type, id( name ) ) : {
			table = store( table, types, name, < \type, scope, false >, v );
		}
		
		case v:variable(list[Modifier] mods, Type \type, id( name ), Expr init) : {
			table = store( table, types, name, < \type, scope, true >, v );
		}
		
		// TYPE DEFINITIONS
		
		case t:typeDef(list[Modifier] mods, Type \type, id( name ) ) : {
			types = store( types, <name,typedef()>, < \type, scope, true >, t );
		}
		
		case s:struct(list[Modifier] mods, id( name ) ) : {
			types = store( types, <name,struct()>, < struct( [] ), scope, false >, s );
		} 
  		
  		case s:struct(list[Modifier] mods, id( name ), list[Field] fields) : {
  			//typeCheckStruct( types, fields );
  		
  			types = store( types, <name,struct()>, < struct( fields ), scope, true >, s );
  		}
  		
  		case e:enum(list[Modifier] mods, id( name ) ) : {
  			types = store( types, <name,enum()>, < enum(), scope, false >, e );
  		} 
  		case e:enum(list[Modifier] mods, id( name ), list[Enum] enums) : {
  			//typeCheckEnum( enums );
  			
  			types = store( types, <name,enum()>, < enum( enums ), scope, false >, e );
  		}
  		
  		// FORBIDDEN
  		
  		case d:decl( function(_, _, _, _, _) ) : {
  			if( function( global() ) := scope ) {
				throw TypeCheckerError( "function definition is not allowed here", d );
			}
		}
	}
	
	n@symboltable = table;
	n@typetable = types;
	
	return <n,table,types>;
}

void handleTypeError( str msg, node astNode ) {
	println("error: <msg> location: <astNode>");
}

list[Stat] createBlockSymbolTable( SymbolTable table, TypeTable types, str scope, list[Stat] stats ) {
	return for( Stat stat <- stats ) {
		// Scope unique symbol table entries
		switch( stat ) {
			case b:block(list[Stat] stats) : {
				stat = block( createBlockSymbolTable( table, types, scope + "-block", stats ) );
			}
			
			case ifThen(Expr cond, Stat body) : {
				stat = ifThen( cond, createBlockSymbolTable( table, types, scope + "-block", body ) );	
			}
	  		
	  		case ifThenElse(Expr cond, Stat body) : {
	  			stat = ifThenElse( cond, createBlockSymbolTable( table, types, scope + "-block", body ) );
	  		}
	  		
	  		case \for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body) : {
				
	  		
	  			stat = \for(init, conds, update, createBlockSymbolTable( table, types, scope + "-block", body ) );
	  		}
			
			case d:decl( function(_, _, _, _, _) ) : {
				throw TypeCheckerError( "function definition is not allowed here", d );
			}
		}
		
		// Scope independent symbol table entries
		if( decl( d ) := stat ) {
			table = createScopeIndependentSymbolTable( table, types, d, scope );
			types = createScopeIndependentTypeTable( types, d, scope );
		} else {
			table = createScopeIndependentSymbolTable( table, types,  stat, scope );
			types = createScopeIndependentTypeTable( types, stat, scope );
		}
		
		stat@symboltable = table;
		stat@typetable = types;
		
		append stat;
	}
}

SymbolTable createScopeIndependentSymbolTable( SymbolTable table, TypeTable types, node n, str scope ) {
	switch( n ) {
		case f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params) : {
			table = store( table, types, name, < \function( \type, parameterTypes( params ) ), scope, false >, f );
		}
		
		case v:variable(list[Modifier] mods, Type \type, id( name ) ) : {
			table = store( table, types, name, < \type, scope, false >, v );
		}
		
		case v:variable(list[Modifier] mods, Type \type, id( name ), Expr init) : {
			table = store( table, types, name, < \type, scope, true >, v );
		}
	}
	
	return table;
}

TypeTable createScopeIndependentTypeTable( TypeTable table, node n, str scope ) {
	switch( n ) {
		case t:typeDef(list[Modifier] mods, Type \type, id( name ) ) : {
			table = store( table, <name,typedef()>, < \type, scope, true >, t );
		}
		
		case s:struct(list[Modifier] mods, id( name ) ) : {
			table = store( table, <name,struct()>, < struct( [] ), scope, false >, s );
		} 
  		
  		case s:struct(list[Modifier] mods, id( name ), list[Field] fields) : {
  			table = store( table, <name,struct()>, < struct( fields ), scope, true >, s );
  		}
  		
  		case e:enum(list[Modifier] mods, id( name ) ) : {
  			table = store( table, <name,enum()>, < enum(), scope, false >, e );
  		} 
  		case e:enum(list[Modifier] mods, id( name ), list[Enum] enums) : {
  			table = store( table, <name,enum()>, < enum( enums ), scope, false >, e );
  		}
	}
	
	return table;
}

SymbolTable createParamSymbolTable( SymbolTable table, TypeTable types, Scope scope, list[Param] params ) {
	for( p:param(list[Modifier] mods, Type \type, id( name ) ) <- params ) {
		table = store( table, types, name, < \type, scope, true>, p );
	}
	
	return table;
}

list[Type] parameterTypes( list[Param] params ) = [ paramType | param( _, paramType, _ ) <- params ];