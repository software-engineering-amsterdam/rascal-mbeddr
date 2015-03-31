module extensions::units::\test::Helper

import extensions::units::Syntax;
import extensions::units::AST;
import extensions::units::Desugar;

import extensions::units::typing::Indexer;
import extensions::units::typing::Constraints;
import extensions::units::typing::Resolver;

extend \test::Helper;
extend core::desugar::Runner;
extend typechecker::indexer::Runner;
extend typechecker::constraints::Runner;
extend typechecker::resolver::Runner;