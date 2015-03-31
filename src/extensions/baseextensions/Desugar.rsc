module extensions::baseextensions::Desugar
extend core::desugar::Base;

// LIBRARY IMPORTS
import util::ext::List;
import util::ext::Node;
import IO;

// LOCAL IMPORTS
import core::typing::IndexTable;
import core::typing::Scope;
import core::typing::resolver::Base;
import extensions::baseextensions::AST;

Module desugarBaseExtensions( Module m:\module( name, imports, decls ) ) {
	m = desugarLambdas( m );
	m = desugarComprehensions( m );
	
	return m;
}

private Module desugarComprehensions( Module m ) {
	int i = 0;
	list[Decl] comprehensionFunctions = [];
	IndexTable liftedComprehensions = ();
	
	solve( m ) {
		m = visit( m ) {
			case Expr e:arrayComprehension(Expr put, Type getType, Id get, Expr from, list[Expr] conds) : {
				i += 1;
				str liftedComprehensionName = "comprehension_function_$<i>";
				
				liftedVariables = findLiftedParams( put, [], e@indextable );
				
				comprehensionFunctions += function( [], e@\type, id( liftedComprehensionName ), liftedVariables, comprehensionBody( e ) );
				liftedComprehensions = store( liftedComprehensions, symbolKey( liftedComprehensionName ), function( e@\type, parameterTypes( liftedVariables ) ), global(), true, e@location ).table;
				
				insert call( var( id( liftedComprehensionName ) ), [] ); 
			}
		}
	}
	
	m.decls = comprehensionFunctions + m.decls;
	return m;
}

private list[Stat] comprehensionBody( Expr e:arrayComprehension(_,_,_,_,_) ) {
	Type itemType;
	int dimension;
	
	if( array( Type t, int dim ) := e@\type ) { 
		itemType = t;
		dimension = dim;
	}
	
	list[Stat] body = [];
	
	body += decl( variable( [], e@\type, id("result"), call( var( id( "malloc" ) ), [lit( \int( "10" ) )] ) ) );
	body += decl( variable( [], \int32(), id("i"), lit( \int( "0" ) ) ) );
	body += decl( variable( [], \int32(), id("j"), lit( \int( "0" ) ) ) );
	
	body += \for( [], [ lt( var( id( "i" ) ), lit( \int( "<dimension>" ) ) ) ], [ postIncr( var( id( "i" ) ) ) ], comprehensionForBody( e ) );
	body += returnExpr( var( id( "result" ) ) );
	
	return body;
}

private Stat comprehensionForBody( Expr e:arrayComprehension(_,_,_,_,_) ) {
	list[Stat] body = [];
	
	body += decl( variable( [], getType( e.from ).\type, e.get, subscript( var( id( "input" ) ), var( id( "i" ) ) ) ) );
	
	body += comprehensionConditions( e );
	
	return block( body );
}

private Stat comprehensionConditions( Expr e:arrayComprehension(_,_,_,_,_) ) {
	return ifThen( createConditions( e.conds ), block( comprehensionConditionBody( e ) ) );
}

private list[Stat] comprehensionConditionBody( Expr e ) = [
	expr( assign( subscript( var( id( "result" ) ), var( id( "j" ) ) ), e.put ) ),
	expr( postIncr( var( id( "j" ) ) ) )
];

private Expr createConditions( [] ) = lit( boolean( "true" ) );
private Expr createConditions( [Expr e] ) = e;
private Expr createConditions( [Expr l, Expr r] ) = and( l, r ); 
private default Expr createConditions( [Expr l, Expr r, *Expr rest] ) = and( and( l, r ), createConditions( rest ) ); 

private Module desugarLambdas( Module m:\module( name, imports, decls ) ) {
	int i = 0;
	list[Decl] liftedLambdas = [];
	IndexTable liftedLambdaGlobals = (); 

	solve( m ) {
		m = visit( m ) {
			case l:lambda( list[Param] params, body ) : { 
				i += 1;
				liftedParams = findLiftedParams( body, params, liftedLambdaGlobals );
		
				liftedLambdas += function( [], l@\type.returnType, id("lambda_function_$<i>"), params + liftedParams, liftLambdaBody( body ) );
				liftedLambdaGlobals = store( liftedLambdaGlobals, symbolKey("lambda_function_$<i>"), l@\type, global(), true, l@location ).table;
				
				n = var( id( "lambda_function_$<i>" ) );
				insert n;
			}
		}
	}
	
	m.decls = liftedLambdas + m.decls;
	return m;
}

private list[Param] findLiftedParams( lambdaBody, list[Param] lambdaParams, IndexTable globals ) {
	result = [];
	paramNames = extractParamNames( lambdaParams );

	top-down visit( lambdaBody ) {
		// Detect all variable usages outside the scope of the lambda function
		case e:var( id( varName ) ) : {
			if( ( "indextable" in getAnnotations(e) ) && ! ( varName in paramNames ) && ! ( contains( globals, symbolKey(varName) ) ) ) {
				result += param( [], lookup( e@indextable, symbolKey(varName) ).\type, id( varName ) );
			}		
		}
	}
	
	return result;
}

private list[Stat] liftLambdaBody( list[Stat] b ) = b;
private list[Stat] liftLambdaBody( Expr e ) = [returnExpr(e)];

private list[Type] extractParamTypes( list[Param] params ) = [ paramType | param(_,paramType,_) <- params ];
private list[str] extractParamNames( list[Param] params ) = [ paramName | param(_, _, id( paramName )) <- params ];

// DESUGAR DECL MODIFIERS //

Decl desugarDeclMods( Decl d ) {
	export = exported() in d.mods;
	d.mods = exportedMods( d.mods );
	
	if( export ) {
		return d[@header=true];
	}
	
	return d;
}

list[Decl] desugarToList(  Decl d:function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Stat] stats) ) {
	export = exported() in d.mods;
	d.mods = exportedMods( d.mods );

	if( export ) {
		return [ d, function(d.mods, d.\type, d.name, d.params)[@header=true] ];
	}
	
	return [ d ];
}

Decl desugarSingle( Decl d:function(list[Modifier] mods, Type \type, Id name, list[Param] params) ) {
	return desugarDeclMods( d );
}

Decl desugarSingle( Decl d:typeDef(list[Modifier] mods, Type \type, Id name) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:struct(list[Modifier] mods, Id name) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:struct(list[Modifier] mods, Id name, list[Field] fields) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:union(list[Modifier] mods, Id name) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:union(list[Modifier] mods, Id name, list[Field] fields) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:enum(list[Modifier] mods, Id name) ) = desugarDeclMods( d );
Decl desugarSingle( Decl d:enum(list[Modifier] mods, Id name, list[Enum] enums) ) = desugarDeclMods( d );

Decl desugarVariableMods( Decl d ) {
    export = exported() in d.mods;
    d.mods = exportedMods( d.mods );
	
	if( export ) {
		d.mods += [extern()];
		d@header=true;
	}

	return d;
}

Decl desugarSingle( Decl d:variable(list[Modifier] mods, Type \type, Id name) ) {
	return desugarVariableMods( d );
}

list[Decl] desugarToList( Decl d:variable(list[Modifier] mods, Type \type, Id name, Expr init) ) {
	d = desugarVariableMods( d );
	
	if( exported() in mods ) {
		return [ variable( d.mods, \type, name )[@header=true], variable( exportedMods( mods ), \type, name, init ) ];
	}
	
	return [ d ];
}

// DESUGAR //

Decl desugar( Decl c:constant( Id name, Expr init ) ) = c[@header=true]; 

Literal desugar( Literal l:boolean(str val) ) = val == "true" ? \int("1") : \int("0");
