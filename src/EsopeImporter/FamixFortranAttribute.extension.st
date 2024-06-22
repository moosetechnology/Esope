Extension { #name : #FamixFortranAttribute }

{ #category : #'*EsopeImporter' }
FamixFortranAttribute >> famixImportSanityCheck [
	"not calling super because does not have a parentBehaviouralEntity"

	self sanityCheck: parentType isNotNil description: 'Attribute ', name , ' without parentType'.
	self sanityCheck: declaredType isNotNil description: 'Attribute ', name , ' without declaredType'.
]
