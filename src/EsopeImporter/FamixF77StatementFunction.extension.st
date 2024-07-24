Extension { #name : #FamixF77StatementFunction }

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> allLocalVariables [

	^self parameters
]

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> allTypes [

	^#()
]

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> createUnresolveVariable: variableName with: resolver [ 
	"StatementFunctions have Parameters and no LocalVariable,
	 unresolved accesses may be found in their parentEntity"

	^resolver resolveVariableNamed: variableName in: parentEntity

]

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: parentEntity isNotNil description: 'StatementFunction without parentEntity'.
]

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> implicitDictionary [

	^parentEntity implicitDictionary
]

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> implicitTypeFor: variableName [
	"statementFunction cannot declare IMPLICIT statement or declare SEGMENT, therefore
	 delegate this message to the parentEntity"

	^parentEntity implicitTypeFor: variableName
]
