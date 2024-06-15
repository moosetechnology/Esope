Extension { #name : #FamixF77PUComment }

{ #category : #'*EsopeImporter' }
FamixF77PUComment >> famixImportSanityCheck [
	"same check, but PUComment does not have a name"
	self assert: programFile isNotNil description: 'PUComment without parent ProgramFile'
]
