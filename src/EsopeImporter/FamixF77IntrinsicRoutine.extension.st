Extension { #name : #FamixF77IntrinsicRoutine }

{ #category : #'*EsopeImporter' }
FamixF77IntrinsicRoutine >> famixImportSanityCheck [
	"not calling super because does not have a parent Programfile"

	self
		assert: self incomingInvocations isNotEmpty
		description: name , ' without invocations'.
]
