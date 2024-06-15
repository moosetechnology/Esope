Extension { #name : #FamixF77Access }

{ #category : #'*EsopeImporter' }
FamixF77Access >> famixImportSanityCheck [

	self assert: variable isNotNil description: 'Access without variable'.
	self assert: accessor isNotNil description: 'Access without accessor'
]
