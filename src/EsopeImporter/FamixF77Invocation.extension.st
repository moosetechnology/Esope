Extension { #name : #FamixF77Invocation }

{ #category : #'*EsopeImporter' }
FamixF77Invocation >> famixImportSanityCheck [

	self assert: sender isNotNil description: 'Invocation without sender'.
	self assert: candidates isNotEmpty description: 'Invocation without candidates'.
]
