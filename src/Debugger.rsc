module Debugger

import Parser;
import Plugin;
import TypeChecker;
import Desugar;

public loc unittest = |project://rascal-mbeddr/input/tests.mbdr|;
public loc helloworld = |project://rascal-mbeddr/input/helloworld.mbdr|;
public loc baseextensions = |project://rascal-mbeddr/input/baseextensions.mbdr|;
public loc typechecker = |project://rascal-mbeddr/input/typechecker.mbdr|;
public loc statemachine = |project://rascal-mbeddr/input/statemachine.mbdr|;

Module run( loc l = statemachine ) = runTypeChecker( createAST( l ) );

