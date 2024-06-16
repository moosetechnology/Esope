Extension { #name : #FamixF77Entity }

{ #category : #'*EsopeImporter' }
FamixF77Entity >> assert: aBlock description: aString [
	"reimplement Object>>assert:description: because we want a resumable Failure"

	aBlock value == true ifFalse: [
		Exception signal: aString ]
]

{ #category : #'*EsopeImporter' }
FamixF77Entity >> famixImportSanityCheck [
	"nothing special by default"
]

{ #category : #'*EsopeImporter' }
FamixF77Entity >> isEsopeSegment [

	^false
]
