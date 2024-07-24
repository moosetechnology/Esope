Extension { #name : 'FamixF77UnknownVariable' }

{ #category : '*EsopeImporter' }
FamixF77UnknownVariable >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: incomingAccesses isNotEmpty description: 'UnknownVariable without incomingAccesses'.
]
