Extension { #name : #FamixF77Invocation }

{ #category : #'*EsopeImporter' }
FamixF77Invocation >> famixImportSanityCheck [

	self assert: sender isNotNil description: signature , ' without sender'.
	self assert: candidates isNotEmpty description: signature , ' without candidates'.
]
