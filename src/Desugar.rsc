module Desugar

import IO;
import Node;
import ParseTree;

import unittest::Syntax;
import baseextensions::Syntax;

import unittest::AST;
import baseextensions::AST;

import typing::Indexer;
import typing::Evaluator;

public loc unittests = |project://rascal-mbeddr/input/tests.mbdr|;
public loc helloworld = |project://rascal-mbeddr/input/helloworld.mbdr|;
public loc baseextensions = |project://rascal-mbeddr/input/baseextensions.mbdr|;
public loc typechecker = |project://rascal-mbeddr/input/typechecker.mbdr|;

Module runTypeChecker( Module m ) = evaluator( createIndexTable( m ) );

Module createAST( loc location ) {
	return implode( #Module, parse( location ) );
}

Tree parse( loc location ) {
	return parse( #start[Module], location );
}