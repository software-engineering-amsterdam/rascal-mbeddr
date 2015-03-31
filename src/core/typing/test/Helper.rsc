module typing::\test::Helper

import core::typing::Scope;
import core::typing::IndexTable;
import core::typing::indexer::Indexer;
import core::typing::resolver::Resolver;
import core::typing::constraints::Constraints;

extend \test::Helper;
extend typechecker::resolver::Runner;
extend typechecker::indexer::Runner;
extend typechecker::constraints::Runner;
