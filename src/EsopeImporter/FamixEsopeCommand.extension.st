Extension { #name : #FamixEsopeCommand }

{ #category : #'*EsopeImporter' }
FamixEsopeCommand >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self assert: (variable declaredType class = FamixFortranUserDefinedType) description: 'EsopeCommand on non-pointer variable'.
]
