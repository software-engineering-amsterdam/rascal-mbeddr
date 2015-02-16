module Desugar

import IO;
import ParseTree;

import UnitTest::Syntax;
import BaseExtensions::Syntax;

import UnitTest::AST;
import BaseExtensions::AST;

public loc unittests = |project://rascal-mbeddr/input/tests.mbdr|;
public loc helloworld = |project://rascal-mbeddr/input/helloworld.mbdr|;
public loc baseextensions = |project://rascal-mbeddr/input/baseextensions.mbdr|;

Module createAST( loc location ) {
	return implode( #Module, parse( location ) );
}

Tree parse( loc location ) {
	return parse( #start[Module], readFile( location ) );
}