Extension { #name : #FamixF77UnknownVariable }

{ #category : #'*EsopeImporter' }
FamixF77UnknownVariable >> famixImportSanityCheck [

	self assert: incomingAccesses isNotEmpty description: 'UnknownVariable without incomingAccesses'.
]
