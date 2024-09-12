Extension { #name : #FamixF77Entity }

{ #category : #'*EsopeImporter' }
FamixF77Entity >> famixImportSanityCheck [
	"nothing special by default"
]

{ #category : #'*EsopeImporter' }
FamixF77Entity >> isEsopeSegment [

	^false
]

{ #category : #'*EsopeImporter' }
FamixF77Entity >> sanityCheck: aBlock description: aString [
	"copied from Object>>assert:description: with our own exception"

	aBlock value == true ifFalse: [
		SanityCheckException signal: aString ]
]
