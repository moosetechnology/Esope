Extension { #name : 'FamixF77PUFunction' }

{ #category : '*EsopeImporter' }
FamixF77PUFunction >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: typing isNotNil description: name , ' without declaredType'.
]
