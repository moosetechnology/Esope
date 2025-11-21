Extension { #name : 'FamixF77Access' }

{ #category : '*EsopeImporter' }
FamixF77Access >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: self variable isNotNil description: 'Access without variable'.
	self sanityCheck: accessor isNotNil description: 'Access without accessor'
]

{ #category : '*EsopeImporter' }
FamixF77Access >> variable [
	"This method returns only one candidate if there is one, or nil if there is more or less than one candidate."

	self candidates size = 1 ifFalse: [ ^nil ].

	^ self candidates anyOne
]
