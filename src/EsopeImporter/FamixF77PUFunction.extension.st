Extension { #name : #FamixF77PUFunction }

{ #category : #'*EsopeImporter' }
FamixF77PUFunction >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self assert: declaredType isNotNil description: 'Function without declaredType'.
]
