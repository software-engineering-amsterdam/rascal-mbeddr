module Plugin

import IO;
import Message;
import Node;
import ParseTree;
import util::IDE;
import util::Editors;

import lang::mbeddr::MBeddrC;
import lang::mbeddr::AST;
import lang::mbeddr::ToC;

import typing::IndexTable;
import typing::Indexer;
import typing::Evaluator;

private str LANG = "MBeddr";
private str EXT = "mbdr";

void main() {
  registerLanguage(LANG, EXT, start[Module](str src, loc l) {
    return parse(#start[Module], src, l);
  });
  
  registerContributions(LANG, {
     popup(
       menu("MBeddr", [
        action("Show C", void (Tree tree, loc selection) {
            println("Showing C...");
            if (start[Module] m := tree) {
              ast = implode(#lang::mbeddr::AST::Module, m);
              src = module2c(ast);
              out = m@\loc[extension="c"];
              writeFile(out, src);
              edit(out, []);
            }        
        })]))
  });
  
  registerAnnotator(LANG, typeCheckerAnnotator); 
}

start[Module] typeCheckerAnnotator( start[Module] m) {
	ast = implode(#lang::mbeddr::AST::Module, m);
	
	ast = evaluator( createIndexTable( ast ) );
	
	msgs = collectMessages( ast );
	
	return visit( m ) {
		case Tree t => t[@message=msgs[t@\loc]]
			when msgs[t@\loc]?
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