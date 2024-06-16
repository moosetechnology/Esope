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
FamixF77StatementFunction >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self assert: parentEntity isNotNil description: 'StatementFunction without parentEntity'.
]

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> implicitDictionary [

	^parentEntity implicitDictionary
]

{ #category : #'*EsopeImporter' }
FamixF77StatementFunction >> resolveVariable: variableName with: resolver [ 
	"StatementFunctions have Parameters and no LocalVariable,
	 but can access LocalVariables of their parentEntity"

	^(resolver resolveVariableNamed: variableName in: self)
		ifNotNil: [ :localVar | localVar ]
		ifNil: [ parentEntity resolveVariable: variableName with: resolver  ]

]
