Extension { #name : 'FamixF77Variable' }

{ #category : '*EsopeImporter' }
FamixF77Variable >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: parentBehaviouralEntity isNotNil description: 'Variable ', name , ' without parentBehaviouralEntity'.
	self sanityCheck: self declaredType isNotNil description: 'Variable ', name , ' without declaredType'.
]
