Extension { #name : #FamixF77PUFunction }

{ #category : #'*EsopeImporter' }
FamixF77PUFunction >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: declaredType isNotNil description: name , ' without declaredType'.
]
