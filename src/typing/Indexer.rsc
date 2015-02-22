module typing::Indexer

import List;

import typing::IndexTable;
import lang::mbeddr::AST;

Module createIndexTable( m:\module( name, imports, decls ) ) = \module( name, imports, visitor( (), (), global(), decls ) );

list[&T <: node] visitor( SymbolTable table, TypeTable types, Scope scope, list[&T <: node] nodeList ) {
	return for( n <- nodeList ) {
		n = visitor( table, types, scope, n );
		table = n@symboltable;
		types = n@typetable;
		append n;
	}
}

// Write all switch cases as functions with pattern matching, make this module extendable by Mbeddr features to extend the typechecker
&T <: node visitor( SymbolTable table, TypeTable types, Scope scope, &T <: node n ) {
	switch( n ) {
		// BLOCK STATEMENTS
		
		case b:block(list[Stat] stats) : {
			n = block( visitor( table, types, block( scope ), stats ) );
		}
		
		case ifThen(Expr cond, Stat body) : {
			n = ifThen( cond, visitor( table, types, block( scope ), body ) );	
		}
  		
  		case ifThenElse(Expr cond, Stat body, Stat els) : {
  			n = ifThenElse( cond, visitor( table, types, block( scope ), body ), visitor( table, types, block( scope ), els ) );
  		}
  		
  		case \for(list[Expr] init, list[Expr] conds, list[Expr] update, Stat body) : {
  			n = \for(init, conds, update, visitor( table, types, block( scope ), body ) );
  		}
  		
  		case decl( d ) : {
  			result = visitor( table, types, scope, d );
  			table = result@symboltable;
  			n = decl( result );
  		}
		
		// DECLARATIONS
		
		case f:function(list[Modifier] mods, Type \type, id( name ), list[Param] params, list[Stat] stats) : {
			if( ! (global() := scope) ) {
				handleTypeError( "function definition is not allowed here", n );
			} else {
				table = store( table, types, name, < \function( \type, parameterTypes( params ) ), scope, true >, f );
				
				params = visitor( table, types, function( scope ), params );
				
				table = size( params ) > 0 ? params[-1]@symboltable : table;
				types = size( params ) > 0 ? params[-1]@typetable : types;
				
				stats = visitor( table, types, function( scope ), stats );
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
  		
  		case p:param(list[Modifier] mods, Type \type, id( name ) ) : {
  			table = store( table, types, name, < \type, scope, true >, p );
  		}
	}
	
	n@symboltable = table;
	n@typetable = types;
	
	return n;
}

list[Type] parameterTypes( list[Param] params ) = [ paramType | param( _, paramType, _ ) <- params ];
