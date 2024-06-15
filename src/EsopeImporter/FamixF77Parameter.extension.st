Extension { #name : #FamixF77Parameter }

{ #category : #'*EsopeImporter' }
FamixF77Parameter >> famixImportSanityCheck [

	self assert: parentBehaviouralEntity isNotNil description: 'Parameter without parentBehaviouralEntity'.
	self assert: declaredType isNotNil description: 'Parameter without declaredType'.
]
