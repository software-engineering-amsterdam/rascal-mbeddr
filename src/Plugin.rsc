module Plugin

import IO;
import Message;
import Node;
import Map;
import ParseTree;
import util::IDE;
import util::Editors;

import lang::mbeddr::ToC;

import typing::IndexTable;

import baseextensions::Syntax;

import baseextensions::AST;

import baseextensions::TypeChecker;
import baseextensions::Desugar;

private str LANG = "MBeddr";
private str EXT = "mbdr";

void main() {
  registerLanguage(LANG, EXT, start[Module](str src, loc l) {
    return parse(#start[Module], src, l);
  });
  
  registerContributions(LANG, {
     popup(
       menu("MBeddr", [
        action("Show C", convert2C)]
        )
      )
  });
  
  registerAnnotator(LANG, typeCheckerAnnotator); 
}

void printErrors( start[Module] m ) {
	visit( m ) {
		case Tree t : {
			if( "message" in getAnnotations(t) ) {
				println( t@message );
			}
		}
	}
}

void convert2C(Tree tree, loc selection) {
    println("Showing C...");
    if (start[Module] m := tree) {
      ast = implode(#lang::mbeddr::AST::Module, m);
      ast = evaluator( createIndexTable( ast ) );
      ast = removeTypeCheckerAnnotations( transform( ast ) );
      
      src = module2c(ast);
      out = m@\loc[extension="c"];
      
      println( src );
      
      writeFile(out, src);
      edit(out, []);
    }        
}

start[Module] typeCheckerAnnotator( start[Module] m) {
	ast = implode(#lang::mbeddr::AST::Module, m);
	
	ast = evaluator( createIndexTable( ast ) );
	
	msgs = collectMessages( ast );
	
	return visit( m ) {
		case Tree t : { 
			if( msgs[t@\loc]? ) {
				msg = msgs[t@\loc];
				msgs = delete( msgs, t@\loc );
				insert t[@message=msg];
			}
		} 
	}
}

private map[loc,Message] collectMessages( Module m ) {
	result = ();
	
	visit( m ) {
		case &T <: node n : {
			if( "message" in getAnnotations( n ) ) {
				result[n@location] = n@message;
			}
		}
	}
	
	return result;
}