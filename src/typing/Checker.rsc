module typing::Checker

import Node;
import IO;

import lang::mbeddr::AST;

data DeclType 
	= enum() 
	| typedef() 
	| struct()
	| union()
	;
data Scope 
	= global( )
	| function( Scope scope )
	| block( Scope scope )
	;

public alias SymbolTableRow = tuple[Type \type,Scope scope,bool initialized];
public alias SymbolTable = map[ str, SymbolTableRow ];

public alias TypeTableRow = tuple[Type \type, Scope scope, bool initialized ];
public alias TypeTable = map[ tuple[str,DeclType], TypeTableRow ];

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
	
	return table;
	 
}

SymbolTableRow lookup( SymbolTable table, str name ) {
	if( name in table ) {
		return table[ name ];
	}
}

TypeTable store( TypeTable table, tuple[str,DeclType] key, TypeTableRow row, node astNode ) {
	if( key in table && 
		table[key].scope == row.scope && 
		table[key].initialized
		) {
		handleTypeError( "redefinition of \'<key>\'", astNode );
	} else {
		return table[key] = row;
	}
	
	return table;
}

bool doesTypeExist( TypeTable types, str name ) {
	return <name,typedef()> in types;
}

bool doesStructExist( TypeTable types, str name ) {
	return <name,struct()> in types;
}

bool doesEnumExist( TypeTable types, str name ) {
	return <name,enum()> in types;
}

anno SymbolTable node @ symboltable;
anno TypeTable node @ typetable;

void createSymbolTable( m:\module( name, imports, decls ) ) { visitor( (), (), global(), decls ); }

list[&T <: node] visitor( SymbolTable table, TypeTable types, Scope scope, list[&T <: node] nodeList ) {
	return for( n <- nodeList ) {
		result = visitor( table, types, scope, n );
		table = result.table;
		types = result.types;
		append result.n;
	}
}

tuple[&T <: node n, SymbolTable table, TypeTable types] visitor( SymbolTable table, TypeTable types, Scope scope, &T <: node n ) {
	switch( n ) {
		// BLOCK STATEMENTS
		
		case b:block(list[Stat] stats) : {
			n = block( visitor( table, types, block( scope ), stats ) );
		}
		
		case ifThen(Expr cond, Stat body) : {
			n = ifThen( cond, visitor( table, types, block( scope ), body ).n );	
		}
  		
  		case ifThenElse(Expr cond, Stat body, Stat els) : {
  			n = ifThenElse( cond, visitor( table, types, block( scope ), body ).n, visitor( table, types, block( scope ).n, els ) );
  		}
  		
  		case \for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body) : {
  			n = \for(init, conds, update, visitor( table, types, block( scope ), body ).n );
  		}
  		
  		case decl( d ) : {
  			result = visitor( table, types, scope, d );
  			table = result.table;
  			n = decl( result.n );
  		}
		
		// DECLARATIONS
		
		case f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats) : {
			if( ! (global() := scope) ) {
				handleTypeError( "function definition is not allowed here", n );
			} else {
				table = store( table, types, name, < \function( \type, parameterTypes( params ) ), scope, true >, f );
				
				paramSymbolTable = createParamSymbolTable( table, types, function( scope ), params );
				stats = visitor( paramSymbolTable, types, function( scope ), stats );
				n = function( mods, \type, id( name ), params, stats );
			}
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
  			n = struct( mods, id( name ), visitor( table, types, block( scope ), fields ) );
  		
  			types = store( types, <name,struct()>, < struct( fields ), scope, true >, s );
  		}
  		
  		case e:enum(list[Modifier] mods, id( name ) ) : {
  			types = store( types, <name,enum()>, < enum( [] ), scope, false >, e );
  		}
  		 
  		case e:enum(list[Modifier] mods, id( name ), list[Enum] enums) : {
  			n = enum( mods, id( name ), visitor( table, types, block( scope ), enums ) );
  			
  			types = store( types, <name,enum()>, < enum( enums ), scope, false >, e );
  		}
  		
  		case u:union(list[Modifier] mods, id( name ) ) : {
  			types = store( types, <name,union()>, < union( [] ), scope, false >, u );
  		}
  		 
  		case u:union(list[Modifier] mods, id( name ), list[Field] fields) : {
  			n = union( mods, id( name ), visitor( table, types, block( scope ), fields ) );
  			
  			types = store( types, <name,union()>, < union( fields ), scope, true >, u );
  		}
  		
  		// Fields
  		
  		case f:field( Type \type, id( name ) ) : {
  			table = store( table, types, name, < \type, scope, true >, f );
  		}
  		
  		case c:const( id( name ) ) : {
  			table = store( table, types, name, < \void(), scope, true >, c );
  		}
  		
  		case c:const( id( name ), _ ) : {
  			table = store( table, types, name, < \void(), scope, true >, c );
  		}
	}
	
	n@symboltable = table;
	n@typetable = types;
	
	return <n,table,types>;
}

SymbolTable createParamSymbolTable( SymbolTable table, TypeTable types, Scope scope, list[Param] params ) {
	for( p:param(list[Modifier] mods, Type \type, id( name ) ) <- params ) {
		table = store( table, types, name, < \type, scope, true>, p );
	}
	
	return table;
}

list[Type] parameterTypes( list[Param] params ) = [ paramType | param( _, paramType, _ ) <- params ];

void handleTypeError( str msg, &T <: node astNode ) {
	println("error: <msg>, @location: <getAnnotations( astNode )["location"]>");
}
