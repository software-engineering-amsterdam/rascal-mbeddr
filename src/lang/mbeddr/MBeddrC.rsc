@license{
  Copyright (c) 2009-2015 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Arnold Lankamp - Arnold.Lankamp@cwi.nl}
@contributor{Tijs van der Storm - storm@cwi.nl}
module lang::mbeddr::MBeddrC

import ParseTree;

start syntax Module  
   = \module: "module" QId ";" Import* Decl*;
   
syntax Import
  = \import: "import" QId ";";
  
syntax QId
  = qid: {Id "."}+;

syntax Decl 
    = function: Modifier* Type Id "(" {Param ","}* ")" "{" Stat* "}" 
    | function: Modifier* Type Id "(" {Param ","}* ")" ";"
    | typeDef: Modifier* "typedef" Type "as" Id ";"
    | struct: Modifier* "struct" Id ";" 
    | struct: Modifier* "struct" Id "{" Field* "}" ";"
    | union: Modifier* "union" Id ";" 
    | union: Modifier* "union" Id "{" Field* "}" ";"
    | enum: Modifier* "enum" Id ";" 
    | enum: Modifier* "enum" Id "{" {Enum ","}+ "}" ";"
    | variable: Modifier* Type Id ";"
    | variable: Modifier* Type Id "=" Expr ";"
    ;

syntax Param
   = param: Modifier* Type Id
   ;

syntax Stat 
    = block: "{" Stat* "}"
    | decl: Decl // c99 
    | labeled: Id ":" Stat 
    | \case: "case" Expr ":" Stat 
    | \default: "default" ":" Stat 
    | semi: ";" 
    | expr: Expr ";" 
    | ifThen: "if" "(" Expr ")" Stat 
    | ifThenElse: "if" "(" Expr ")" Stat "else" Stat 
    | \switch: "switch" "(" Expr ")" Stat 
    | \while: "while" "(" Expr ")" Stat 
    | doWhile: "do" Stat "while" "(" Expr ")" ";" 
    | \for: "for" "(" Expr? ";" Expr? ";" Expr? ")" Stat 
    | goto: "goto" Id ";" 
    | \continue: "continue" ";" 
    | \break: "break" ";" 
    | \return: "return" ";" 
    | returnExpr: "return" Expr ";"
    ;

syntax Literal
  = hex: HexadecimalConstant 
  | \int: IntegerConstant 
  | char: CharacterConstant 
  | float: FloatingPointConstant 
  | string: StringConstant
  ;

syntax Expr 
    = var: Id 
    | @category="Constant" lit: Literal 
    | subscript: Expr "[" Expr "]" 
    | call: Expr "(" {Expr ","}* ")" 
    | sizeOf: "sizeof" "(" Type ")" 
    | bracket "(" Expr ")"
    | structInit: "{" {Expr ","}* "}"
    | structInitNamed: "{" {("." Id "=" Expr) ","}* "}"  
    | dotField: Expr "." Id 
    | ptrField: Expr "-\>" Id 
    | postIncr: Expr "++" 
    | postDecr: Expr "--" 
    > preIncr: [+] !<< "++" Expr 
    | preDecr: [\-] !<< "--" Expr 
    | addrOf: "&" Expr 
    | refOf: "*" Expr 
    | pos: "+" Expr 
    | neg: "-" Expr 
    | bitNot: "~" Expr 
    | not: "!" Expr 
    | sizeOfExpr: "sizeof" Expr exp // May be ambiguous with "sizeof(TypeName)".
    | cast: "(" Type ")" Expr 
    > left ( mul: Expr lexp "*" Expr rexp // May be ambiguous with "TypeName *Declarator".
           | div: Expr "/" Expr 
           | \mod: Expr "%" Expr
           ) 
    > left ( add: Expr "+" Expr 
           | sub: Expr "-" Expr
           )
    > left ( shl: Expr "\<\<" Expr 
           | shr: Expr "\>\>" Expr
           )
    > left ( lt: Expr "\<" Expr 
           | gt: Expr "\>" Expr 
           | leq: Expr "\<=" Expr 
           | geq: Expr "\>=" Expr
           )
    > left ( eq: Expr "==" Expr 
           | neq: Expr "!=" Expr
           )
    > left bitAnd: Expr "&" Expr 
    > left bitXor: Expr "^" Expr 
    > left bitOr: Expr "|" Expr 
    > left and: Expr "&&" Expr 
    > left or: Expr "||" Expr 
    > right cond: Expr "?" Expr ":" Expr 
    > right ( assign: Expr "=" Expr 
            | mulAssign: Expr "*=" Expr 
            | divAssign: Expr "/=" Expr 
            | modAssign: Expr "%=" Expr 
            | addAssign: Expr "+=" Expr 
            | subAssign: Expr "-=" Expr 
            | shlAssign: Expr "\<\<=" Expr 
            | shrAssign: Expr "\>\>=" Expr 
            | bitAndAssign: Expr "&=" Expr 
            | bitXorAssign: Expr "^=" Expr 
            | bitOrAssign: Expr "|=" Expr
            )
    ;


lexical Id = id: ([a-zA-Z_] [a-zA-Z0-9_]* !>> [a-zA-Z0-9_]) \ Keyword;


keyword Keyword 
    = "module"
    | "import"
    | "auto" 
    | "break" 
    | "case" 
    | "char" 
    | "const" 
    | "continue" 
    | "default" 
    | "do" 
    | "double" 
    | "else" 
    | "enum" 
    | "extern" 
    | "float" 
    | "for" 
    | "goto" 
    | "if" 
    | "int8" 
    | "int16" 
    | "int32" 
    | "int64" 
    | "uint8" 
    | "uint16" 
    | "uint32" 
    | "uint64" 
    | "long" 
    | "register" 
    | "return" 
    //| "short" 
    //| "signed" 
    | "sizeof" 
    | "static" 
    | "struct" 
    | "switch" 
    | "typedef" 
    | "union" 
    //| "unsigned" 
    | "void" 
    | "volatile" 
    | "while"
    ;



syntax Type 
    = id: Id 
    | \void: "void" 
    | int8: "int8"
    | int16: "int16"
    | int32: "int32"
    | int64: "int64"
    | uint8: "uint8"
    | uint16: "uint16"
    | uint32: "uint32"
    | uint64: "uint64"
    | char: "char"
    | \boolean: "boolean"
    | \float: "float" 
    | \double: "double" 
    | struct: "struct" Id 
    | struct: "struct" Id "{" Field* "}" 
    | struct: "struct" "{" Field* "}" 
    | union: "union" Id 
    | union: "union" Id "{" Field* "}" 
    | union: "union" "{" Field* "}" 
    | enum: "enum" Id 
    | enum: "enum" Id "{" {Enum ","}+ "}" 
    | enum: "enum" "{" {Enum ","}+ "}"
    | array: Type "[" "]"
    | array: Type "[" IntegerConstant "]"
    | pointer: Type "*"
    | function: Type "(" {Type ","}* ")"
    ;

syntax Modifier
  = const: "const" 
  | volatile: "volatile"
  | extern: "extern" 
  | static: "static" 
  | auto: "auto" 
  | register: "register"
  | exported: "exported"
  | static: "static"
  ;

syntax Field 
    = field: Type Id ";"
    ;

syntax Enum 
    = const: Id 
    | const: Id "=" Expr
    ;

lexical IntegerConstant = [0-9]+ [uUlL]* !>> [0-9];

lexical HexadecimalConstant = [0] [xX] [a-fA-F0-9]+ [uUlL]* !>> [a-fA-F0-9];

lexical FloatingPointConstant 
    = [0-9]+ Exponent [fFlL]? 
    | [0-9]* [.] [0-9]+ !>> [0-9] Exponent? [fFlL]? 
    | [0-9]+ [.] Exponent? [fFlL]?
    ;

lexical Exponent = [Ee] [+\-]? [0-9]+ !>> [0-9];

lexical CharacterConstant = [L]? [\'] CharacterConstantContent+ [\'];

lexical CharacterConstantContent 
    = [\\] ![] 
    | ![\\\']
    ;

lexical StringConstant = [L]? [\"] StringConstantContent* [\"];

lexical StringConstantContent 
    = [\\] ![] 
    | ![\\\"]
    ;


lexical Comment 
    = [/][*] MultiLineCommentBodyToken* [*][/] 
    | "//" ![\n]* [\n]
    ;

lexical MultiLineCommentBodyToken 
    = ![*] 
    | Asterisk
    ;

lexical Asterisk = [*] !>> [/];

layout LAYOUTLIST = LAYOUT* !>> [\ \t\n\r] !>> "/*" !>> "//";

lexical LAYOUT 
    = whitespace: [\ \t\n\r] 
    | @category="Comment" comment: Comment
    ;
