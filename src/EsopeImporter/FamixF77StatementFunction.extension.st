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

	self assert: parentEntity isNotNil description: 'StatementFunction without parentEntity'.
]

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> implicitDictionary [

	^parentEntity implicitDictionary
]
