module baseextensions::\test::Helper

import baseextensions::Syntax;
import baseextensions::AST;
import baseextensions::Desugar;

import baseextensions::typing::Indexer;
import baseextensions::typing::Constraints;
import baseextensions::typing::Resolver;

extend \test::Helper;
extend desugar::Helper;
extend typing::resolver::Helper;
extend typing::indexer::Helper;
extend typing::constraints::Helper;

Module desugarModule( Module ast ) {
	ast = desugar_baseextensions( ast );
	ast = runDesugar( ast );
	
	return ast;
}