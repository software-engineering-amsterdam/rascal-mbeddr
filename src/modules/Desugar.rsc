module Modules::Desugar

import IO;
import Util;

import lang::mbeddr::AST;

public list[node] desugar( \Module m ) {
	if( \module( qid( [id( moduleName )] ), imports, decls ) := m ) {
		ast = ["#include"( moduleName + ".h" )];
		ast += createIncludes( imports );
		
		ast += visit( decls ) {
			case id( name ) => id( moduleName + "_" + name )
			
			case function(list[Modifier] mods, Type \type, Id name, list[Param] params, list[Decl] decls, list[Stat] stats) => \function( desugarMods( mods ), \type, name, params, decls, stats)
		    case function(list[Modifier] mods, Type \type, Id name, list[Param] params) => \function( desugarMods( mods ), \type, name, params )
		    case typeDef(list[Modifier] mods, Type \type, Id name) => typeDef( desugarMods( mods ), \type, name)
		    case struct(list[Modifier] mods, Id name) => struct( desugarMods( mods ), name) 
		    case struct(list[Modifier] mods, Id name, list[Field] structDecls) => struct( desugarMods( mods ), name, structDecls) 
		    case union(list[Modifier] mods, Id name) => union( desugarMods( mods ), name) 
		    case union(list[Modifier] mods, Id name, list[Field] structDecls) => union( desugarMods( mods ), name, structDecls) 
		    case enum(list[Modifier] mods, Id name) => enum( desugarMods( mods ), name) 
		    case enum(list[Modifier] mods, Id name, list[Enum] enums) => enum( desugarMods( mods ), name, enums)
		    case variable(list[Modifier] mods, Type \type, Id name) => variable( desugarMods( mods ), \type, name)
		    case variable(list[Modifier] mods, Type \type, Id name, Expr init) => variable( desugarMods( mods ), \type, name, init)
		}
		
		return ast;
	}
}

private Decl desugarMods( list[Modifier] mods ) {
	if( ! exported() in mods ) {
		mods += static();
		mods -= exported();
	}
	
	return mods;
}

private list[node] createIncludes( imports ) {
	return for( \import( qid( name ) ) <- imports ) {
		append "#include"( joinList( [ id | id( id ) <- name ], "/" ) + ".h" );	
	}
}
