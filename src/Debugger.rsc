module Debugger

import Parser;
import Plugin;
import TypeChecker;
import Desugar;

import util::ext::List;

public loc unittest = |project://rascal-mbeddr/input/tests.mbdr|;
public loc helloworld = |project://rascal-mbeddr/input/helloworld.mbdr|;
public loc baseextensions = |project://rascal-mbeddr/input/baseextensions.mbdr|;
public loc typechecker = |project://rascal-mbeddr/input/typechecker.mbdr|;
public loc statemachine = |project://rascal-mbeddr/input/statemachine.mbdr|;

Module run( loc l = statemachine ) = runTypeChecker( createAST( l ) );

node testfun( node ast ) {
	return visit( ast ) {
		case list[int] lst : {
			offset = 0;
			toInsert = [];
						
			for( elm <- lst, elm == 4 ) {
				listToInsert = [1,2,3];
				toInsert += < indexOf( lst, elm ) + offset, listToInsert >;
				offset += size(listToInsert);
			}
			
			for( < position, listToInsert > <- toInsert ) {
				lst = insertListFor( lst, position, listToInsert );	
			}
			
			insert lst;
		}
	}
}