module extensions::unittest::\test::Helper

import extensions::unittest::Syntax;
import extensions::unittest::AST;
import extensions::unittest::Desugar;

import extensions::unittest::typing::Indexer;
import extensions::unittest::typing::Constraints;
import extensions::unittest::typing::Resolver;
import extensions::unittest::typing::Scope;

extend \test::Helper;
extend core::desugar::Runner;
extend typechecker::resolver::Runner;
extend typechecker::indexer::Runner;
extend typechecker::constraints::Runner;

Module desugarModule( Module ast ) {
	ast = desugarUnitTest( ast );
	ast = runDesugar( ast );
	
	return ast;
}