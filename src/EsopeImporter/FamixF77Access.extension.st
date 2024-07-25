Extension { #name : #FamixF77Access }

{ #category : #'*EsopeImporter' }
FamixF77Access >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: variable isNotNil description: 'Access without variable'.
	self sanityCheck: accessor isNotNil description: 'Access without accessor'
]
