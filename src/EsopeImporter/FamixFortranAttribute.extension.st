Extension { #name : #FamixFortranAttribute }

{ #category : #'*EsopeImporter' }
FamixFortranAttribute >> famixImportSanityCheck [

	self assert: parentType isNotNil description: 'Variable without parentType'.
	self assert: declaredType isNotNil description: 'Variable without declaredType'.
]
