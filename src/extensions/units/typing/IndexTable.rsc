module extensions::units::typing::IndexTable
extend core::typing::IndexTable;

import extensions::units::AST;

data SymbolTableKey 
	= conversionKey( str fromUnit, str toUnit, Type \type )
	| unitKey( str unit )
	;
	
data SymbolTableRow
	= conversionRow( Expr conversion )
	| unitRow( Spec specification, str description )
	;

// STORE CONVERSION
StoreResult store( IndexTables tables, k:conversionKey(_,_,_), row:conversionRow( _ ) ) {
	errorMsg = "";
	
	if( k in tables.symbols ) {
		errorMsg = "The specifiers type is already covered";
	} else {
		tables.symbols[ k ] = row;
	}
	
	return < tables, errorMsg >;
}

// STORE UNIT
StoreResult store( IndexTables tables, k:unitKey(_), row:unitRow(_,_) ) {
	errorMsg = "";
	
	if( k in tables.symbols ) {
		errorMsg = "duplicate name";
	} else {
		tables.symbols[ k ] = row;
	}
	
	return < tables, errorMsg >;
}

SymbolTable update( SymbolTable symbols, k:conversionKey(_,_,_), row:conversionRow( _ ) ) {
	if( k in symbols ) {
		symbols[ k ] = row;
	}
	
	return symbols;
}
