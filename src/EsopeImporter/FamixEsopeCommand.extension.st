Extension { #name : #FamixEsopeCommand }

{ #category : #'*EsopeImporter' }
FamixEsopeCommand >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self assert: (variable declaredType class = FamixEsopeSegment) description: 'EsopeCommand on non-pointer variable'.
]
