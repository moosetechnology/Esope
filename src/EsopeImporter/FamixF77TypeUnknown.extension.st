Extension { #name : #FamixF77TypeUnknown }

{ #category : #'*EsopeImporter' }
FamixF77TypeUnknown class >> defaultName [
	^#unknownType 
]

{ #category : #'*EsopeImporter' }
FamixF77TypeUnknown >> initialize [
	super initialize.

	self name: self class defaultName 
]
