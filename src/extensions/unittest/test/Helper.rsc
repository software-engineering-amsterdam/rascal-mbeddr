module extensions::unittest::\test::Helper

import extensions::unittest::Syntax;
import extensions::unittest::AST;
import extensions::unittest::Desugar;

import extensions::unittest::typing::Indexer;
import extensions::unittest::typing::Constraints;
import extensions::unittest::typing::Resolver;
import extensions::unittest::typing::Scope;

extend \test::Helper;
extend desugar::Helper;
extend typing::resolver::Helper;
extend typing::indexer::Helper;
extend typing::constraints::Helper;

Module desugarModule( Module ast ) {
	ast = desugarUnitTest( ast );
	ast = runDesugar( ast );
	
	return ast;
}