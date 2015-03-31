module extensions::baseextensions::\test::Helper

import extensions::baseextensions::Syntax;
import extensions::baseextensions::AST;
import extensions::baseextensions::Desugar;

import extensions::baseextensions::typing::Indexer;
import extensions::baseextensions::typing::Constraints;
import extensions::baseextensions::typing::Resolver;
import extensions::baseextensions::typing::Scope;

extend \test::Helper;
extend core::desugar::Runner;
extend typechecker::resolver::Runner;
extend typechecker::indexer::Runner;
extend typechecker::constraints::Runner;

Module desugarModule( Module ast ) {
	ast = desugarBaseExtensions( ast );
	ast = runDesugar( ast );
	
	return ast;
}