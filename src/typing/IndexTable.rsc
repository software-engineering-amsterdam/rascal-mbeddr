module typing::IndexTable

import IO;
import Node;

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

alias SymbolTableRow = tuple[ Type \type, Scope scope, bool initialized ];
alias SymbolTable = map[ str, SymbolTableRow ];

alias TypeTableRow = tuple[Type \type, Scope scope, bool initialized ];
alias TypeTable = map[ tuple[str,DeclType], TypeTableRow ];

data RuntimeException = TypeCheckerError( str message, loc location );

anno SymbolTable node @ symboltable;
anno TypeTable node @ typetable;

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

void handleTypeError( str msg, &T <: node astNode ) {
	println("error: <msg>, @location: <getAnnotations( astNode )["location"]>");
}


