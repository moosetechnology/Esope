Extension { #name : #FamixF77IncludedFile }

{ #category : #'*EsopeImporter' }
FamixF77IncludedFile >> allTypes [

	"empty collection because because members of included files are treated by the including files"

	^#()
]

{ #category : #'*EsopeImporter' }
FamixF77IncludedFile >> createUnresolveVariable: variableName with: resolver [

	^mooseModel newUnknownVariableNamed: variableName

]

{ #category : #'*EsopeImporter' }
FamixF77IncludedFile >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self assert: inclusions isNotEmpty description: 'IncludedFile without inclusions'.
]
