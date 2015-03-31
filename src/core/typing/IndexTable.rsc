module core::typing::IndexTable

import IO;
import util::ext::Node;
import core::typing::TypeMessage;

import lang::mbeddr::AST;
import core::typing::Util;
import core::typing::Scope;

data DeclType 
	= enum() 
	| typedef() 
	| struct()
	| union()
	;

data IndexTableKey
	= symbolKey( str symbolName )
	| typeKey( str typeName, DeclType declType )
	;

data IndexTableRow 
	= symbolRow( Type \type, Scope scope, bool initialized, loc at, bool constant )
	| typeRow( Type \type, Scope scope, bool initialized )
	;

alias IndexTable = map[ IndexTableKey, IndexTableRow ];
alias StoreResult = tuple[ IndexTable table, str errorMsg ]; 

anno IndexTable node @ indextable;

anno Scope Module@scope;
anno Scope Import@scope;
anno Scope QId@scope;
anno Scope Id@scope;
anno Scope Decl@scope;
anno Scope Stat@scope;
anno Scope Expr@scope;
anno Scope Param@scope;
anno Scope Literal@scope;
anno Scope Type@scope;
anno Scope Modifier@scope;
anno Scope Field@scope;
anno Scope Enum@scope;

StoreResult store( IndexTable table, key:symbolKey(_), Type \type, Scope scope, bool initialized, loc at, bool constant = false )  {
	str errorMsg = "";
	row = symbolRow( \type, scope, initialized, at, constant );
	
	if( contains( table, key ) && lookup( table, key ).scope == row.scope ) {
		item = lookup( table, key );
		
		if( item.initialized ) {
			errorMsg = "redefinition of \'<key.symbolName>\'";
		} else if( item.\type != row.\type ) {
			errorMsg = "redefinition of \'<key.symbolName>\' with a different type \'<typeToString( row.\type )>\' vs \'<typeToString( item.\type )>\'";
		} else if( row.initialized ) {
			table[ key ].initialized = true;
		}
		
	} else if( contains( table, key ) && function(_,_) := row.\type && function(_,_) := lookup( table, key ).\type && row.\type != lookup( table, key ).\type ) {
		
		errorMsg = "confliciting types for \'<key.symbolName>\'";
	
	} else {
		
		// Custom type
		if( id( id( typeName ) ) := row.\type && !doesTypeExist( table, typeName ) ) {
			errorMsg = "unknown type name \'<typeName>\'";
		} 
		
		// Struct type
		if( struct( id( structName ) ) := row.\type && !doesStructExist( table, structName ) ) {
			errorMsg = "unkown struct \'<structName>\'";
		}
		
		// Enum type
		if( enum( id( enumName ) ) := row.\type && !doesEnumExist( table, enumName ) ) {
			errorMsg = "unkown enum \'<enumName>\'";
		}
		
		table[ key ] = row;
	}
	
	return < table, errorMsg >;
	 
}

IndexTable update( IndexTable table, key:symbolKey(_), IndexTableRow row )  {
	assert "symbolRow" == getName( row ) : "Can only store symbolRow under symbolKey";
	if( contains( table, key ) ) {
		table[ key ] = row;
	}
	
	return table;
} 

IndexTableRow lookup( IndexTable table, key:symbolKey(_) ) {
	row = table[ key ];
	assert "symbolRow" == getName( row ) : "Can only store symbolRow under symbolKey";
	return row;
}

bool contains( IndexTable symbols, key:symbolKey(_) ) {
	return key in symbols;
}

// TYPETABLE

StoreResult
store( IndexTable table, 
       key:typeKey(_,_), 
       row:typeRow(_,_,_)
      ) {
    errorMsg = "";  
     
	if( contains( table, key ) && 
		lookup( table, key ).scope == row.scope && 
		lookup( table, key ).initialized
		) {
		errorMsg = "redefinition of \'<key.typeName>\'";
	} else {
		table[ key ] = row;
	}
	
	return < table, errorMsg >;
}

IndexTable update( IndexTable table, key:typeKey(_,_), row:typeRow(_,_,_) ) {
	if( contains( table, key ) ) {
		table[ key ] = row;
	}
	return table;
}

IndexTableRow lookup( IndexTable table, key:typeKey(_,_) ) {
	row = table[ key ];
	assert "typeRow" == getName( row ) : "Can only store TypeTableRow under TypeTableKey";
	
	return row;
}

bool contains( IndexTable table, key:typeKey(_,_) ) {
	if( key in table ) {
		lookup( table, key );
		return true;
	}
	
	return false;
}

private bool doesTypeExist( IndexTable table, str name ) = contains( table, typeKey( name,typedef() ) );
private bool doesStructExist( IndexTable table, str name ) = contains( table, typeKey( name,struct() ) );
private bool doesEnumExist( IndexTable table, str name ) = contains( table, typeKey( name,enum() ) );