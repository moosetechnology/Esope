Extension { #name : 'FamixF77PUFunction' }

{ #category : '*EsopeImporter' }
FamixF77PUFunction >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: self declaredType isNotNil description: name , ' without declaredType'.
]
