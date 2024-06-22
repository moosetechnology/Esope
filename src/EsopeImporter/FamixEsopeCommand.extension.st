Extension { #name : #FamixEsopeCommand }

{ #category : #'*EsopeImporter' }
FamixEsopeCommand >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: (variable declaredType isEsopeSegment) description: 'EsopeCommand on non-pointer variable'.
]
