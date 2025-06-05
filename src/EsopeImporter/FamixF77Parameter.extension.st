Extension { #name : 'FamixF77Parameter' }

{ #category : '*EsopeImporter' }
FamixF77Parameter >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: parentBehaviouralEntity isNotNil description: 'Parameter without parentBehaviouralEntity'.
	self sanityCheck: self declaredType isNotNil description: 'Parameter without declaredType'.
]
