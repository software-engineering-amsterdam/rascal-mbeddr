module typing::TypeMessage
extend Message;

import lang::mbeddr::AST;

data Message
	= error( ErrorType error, str msg, loc at )
	;

data ErrorType
	= // Expect something but get nothing instead
	  missingReturnError( )
	  
	  // Expect one type but get a different one
	| typeMismatchError( )
	| argumentsMismatchError( )
	| subscriptMismatchError( )
	| referenceMismatchError( )
	| conditionalMismatchError( )
	| returnMismatchError( )

	  // Supply something of incorrect type to statement or expression
	| conditionalAbuseError( )
	| subscriptAbuseError( )
	| loopAbuseError( )

	  // Reference something that is not their or of unexpected type
	| referenceError( )
	| functionReferenceError( )
	| fieldReferenceError( )
	
	  // Use an operator in an incorrect manner
	| unaryArgumentError( )
	| binaryArgumentError( )

	  // Try to assign something with something that is not meant compatible
	| assignmentError( )
	| nonFittingTypesError( )
	| incompatibleTypesError( )
	
	| functionAssignmentError( )
	| structAssignmentError( )
	| fieldAssignmentError( )
	| pointerAssignmentError( )
	| constantAssignmentError( )

	  // Type messages related to declarations
	| redefinitionError( )
	| conflictingRedefinitionError( )
	| unkownTypeError( )
	| indexError( )

	  // Type messages related to expressions
	| staticEvaluationError( )
	
	| constraintError( )
	;