@license{
  Copyright (c) 2009-2015 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Arnold Lankamp - Arnold.Lankamp@cwi.nl}
@contributor{Tijs van der Storm - storm@cwi.nl}
module lang::mbeddr::C

import ParseTree;

start syntax Module  
   = \module: "module" QIdentifier ";" Import* ToplevelDeclaration+;
   
syntax Import
  = \import: "import" QIdentifier ";";
  
syntax QIdentifier
  = qid: {Identifier "."}+;

syntax ToplevelDeclaration 
    = function: Modifier* Type Identifier "(" Parameters ")" "{" Declaration* Statement* "}" 
    | prototype: Modifier* Type Identifier "(" Parameters ")" ";"
    | typeDef: Modifier* "typedef" Type Identifier ";"
    | struct: Modifier* "struct" Identifier ";" 
    | structDecl: Modifier* "struct" Identifier "{" StructDeclaration* "}" 
    | union: Modifier* "union" Identifier ";" 
    | unionDecl: Modifier* "union" Identifier "{" StructDeclaration* "}" 
    | enum: Modifier* "enum" Identifier ";" 
    | enumDecl: Modifier* "enum" Identifier "{" {Enumerator ","}+ "}"
    | Declaration 
    ;
    
syntax Declaration 
    = variableDecl: Modifier* Type Identifier ";"
    | variableDeclInit: Modifier* Type Identifier "=" Expression ";"
    ;


syntax Param
   = param: Modifier* Type Identifier
   ;

syntax Parameters 
    = params: {Param ","}* 
    | varargs: {Param ","}+ "," "..."
    | \void: "void"
    ;

syntax Statement 
    = block: "{" Declaration* Statement* "}" 
    | labeled: Identifier ":" Statement 
    | \case: "case" Expression ":" Statement 
    | \default: "default" ":" Statement 
    | semi: ";" 
    | expr: Expression ";" 
    | ifThen: "if" "(" Expression ")" Statement 
    | ifThenElse: "if" "(" Expression ")" Statement "else" Statement 
    | \switch: "switch" "(" Expression ")" Statement 
    | \while: "while" "(" Expression ")" Statement 
    | doWhile: "do" Statement "while" "(" Expression ")" ";" 
    | \for: "for" "(" Expression? ";" Expression? ";" Expression? ")" Statement 
    | goto: "goto" Identifier ";" 
    | \continue: "continue" ";" 
    | \break: "break" ";" 
    | \return: "return" ";" 
    | returnExpr: "return" Expression ";"
    ;

syntax Expression 
    = variable: Identifier 
    | @category="Constant" hexadecimalConstant: HexadecimalConstant 
    | @category="Constant" integerConstant: IntegerConstant 
    | @category="Constant" characterConstant: CharacterConstant 
    | @category="Constant" floatingPointConstant: FloatingPointConstant 
    | @category="Constant" stringConstant: StringConstant 
    | subscript: Expression "[" Expression "]" 
    | call: Expression "(" {Expression ","}* ")" 
    | sizeOf: "sizeof" "(" TypeName ")" 
    | bracket "(" Expression ")" 
    | field: Expression "." Identifier 
    | ptrField: Expression "-\>" Identifier 
    | postIncr: Expression "++" 
    | postDecr: Expression "--" 
    > preIncr: [+] !<< "++" Expression 
    | preDecr: [\-] !<< "--" Expression 
    | addrOf: "&" Expression 
    | refOf: "*" Expression 
    | pos: "+" Expression 
    | neg: "-" Expression 
    | bitNot: "~" Expression 
    | not: "!" Expression 
    | sizeOfExpression: "sizeof" Expression exp // May be ambiguous with "sizeof(TypeName)".
    | "(" TypeName ")" Expression 
    > left ( mul: Expression lexp "*" Expression rexp // May be ambiguous with "TypeName *Declarator".
           | div: Expression "/" Expression 
           | \mod: Expression "%" Expression
           ) 
    > left ( add: Expression "+" Expression 
           | sub: Expression "-" Expression
           )
    > left ( shl: Expression "\<\<" Expression 
           | shr: Expression "\>\>" Expression
           )
    > left ( lt: Expression "\<" Expression 
           | gt: Expression "\>" Expression 
           | leq: Expression "\<=" Expression 
           | geq: Expression "\>=" Expression
           )
    > left ( eq: Expression "==" Expression 
           | neq: Expression "!=" Expression
           )
    > left bitAnd: Expression "&" Expression 
    > left bitXor: Expression "^" Expression 
    > left bitOr: Expression "|" Expression 
    > left and: Expression "&&" Expression 
    > left or: Expression "||" Expression 
    > right cond: Expression "?" Expression ":" Expression 
    > right ( assign: Expression "=" Expression 
            | mulAssign: Expression "*=" Expression 
            | divAssign: Expression "/=" Expression 
            | modAssign: Expression "%=" Expression 
            | addAssign: Expression "+=" Expression 
            | subAssign: Expression "-=" Expression 
            | shlAssign: Expression "\<\<=" Expression 
            | shrAssign: Expression "\>\>=" Expression 
            | bitAndAssign: Expression "&=" Expression 
            | bitXorAssign: Expression "^=" Expression 
            | bitOrAssign: Expression "|=" Expression
            )
    ;


lexical Identifier = id: ([a-zA-Z_] [a-zA-Z0-9_]* !>> [a-zA-Z0-9_]) \ Keyword;


keyword Keyword 
    = "module"
    | "import"
    | "auto" 
    | "break" 
    | "case" 
    //| "char" 
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
    = identifier: Identifier 
    | \void: "void" 
    | int8: "int8"
    | int16: "int16"
    | int32: "int32"
    | int64: "int64"
    | uint8: "uint8"
    | uint16: "uint16"
    | uint32: "uint32"
    | uint64: "uint64"
    | \boolean: "boolean"
    | \float: "float" 
    | \double: "double" 
    | struct: "struct" Identifier 
    | structDecl: "struct" Identifier "{" Field* "}" 
    | structAnonDecl: "struct" "{" Field* "}" 
    | union: "union" Identifier 
    | unionDecl: "union" Identifier "{" Field* "}" 
    | unionAnonDecl: "union" "{" Field* "}" 
    | enum: "enum" Identifier 
    | enumDecl: "enum" Identifier "{" {Enumerator ","}+ "}" 
    | enumAnonDecl: "enum" "{" {Enumerator ","}+ "}"
    | openArray: Type "[" "]"
    | fixedArray: Type "[" IntegerConstant "]"
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
    = field: Type Identifier ";"
    ;

syntax Enumerator 
    = name: Identifier 
    | nameValue: Identifier "=" Expression!comma
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
