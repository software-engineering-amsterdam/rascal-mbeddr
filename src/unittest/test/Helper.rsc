module unittest::\test::Helper

import unittest::Syntax;
import unittest::AST;
import unittest::Desugar;

import unittest::typing::Indexer;
import unittest::typing::Constraints;
import unittest::typing::Resolver;

extend \test::Helper;
extend desugar::Helper;
extend typing::resolver::Helper;
extend typing::indexer::Helper;
extend typing::constraints::Helper;

Module desugarModule( Module ast ) {
	ast = desugar_unittest( ast );
	ast = runDesugar( ast );
	
	return ast;
}