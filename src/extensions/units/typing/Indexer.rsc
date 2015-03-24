module extensions::units::typing::Indexer
extend typing::indexer::Indexer;

import extensions::units::AST;
import extensions::units::typing::IndexTable;

StoreResult indexConversion( conversion( Type \type, Expr conv ), IndexTables tables, str fromUnit, str toUnit, Scope scope ) {
	return store( tables, fromUnit, toUnit, \type, conversionRow( conv ) );
}
 
StoreResult indexConversion( conversion( Expr conv ), IndexTables tables, str fromUnit, str toUnit, Scope scope ) {
	return store( tables, fromUnit, toUnit, \void(), conversionRow( conv ) );
} 

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:unitConversion( list[Modifier] mods, id( fromUnit ), id( toUnit ), list[ConversionDecl] body ),
		 IndexTables tables, 
		 Scope scope ) {
		 	 	
	d.body = [ indexConversionDecl( c ) | ConversionDecl c <- body ]; 
	
	return < d[@scope=scope], tables, "" >;
}

Decl indexConversionDecl( ConversionDecl c ) {
	storeResult = indexConversion( c, tables, fromUnit, toUnit, scope );
	tables = storeResult.tables;
	
	if( storeResult.errorMsg != "" ) {
		c@message = error( storeResult.errorMsg, c@location );
	}
	
	return c;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:unit( list[Modifier] mods, id( name ), Spec specification, id( description ) ),
		 IndexTables tables,
		 Scope scope ) {
	storeResult = store( tables, unitKey( name, specification ), unitRow( description ) );
	
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}

tuple[ Decl astNode, IndexTables tables, str errorMsg ]
indexer( Decl d:unit( list[Modifier] mods, id( name ), id( description ) ),
		 IndexTables tables,
		 Scope scope ) {
	storeResult = store( tables, unitKey( name, specification ), unitRow( description ) );
	
	return < d[@scope=scope], storeResult.tables, storeResult.errorMsg >;
}
