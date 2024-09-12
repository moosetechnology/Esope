Extension { #name : #FamixEsopeCommand }

{ #category : #'*EsopeImporter' }
FamixEsopeCommand >> famixImportSanityCheck [

	super famixImportSanityCheck.

	self sanityCheck: (variable declaredType isEsopeSegment) description: 'EsopeCommand on non-pointer variable'.
]

{ #category : #'*EsopeImporter' }
FamixEsopeCommand class >> metamodel [
	"temporary solution to issue https://github.com/moosetechnology/Famix/issues/808"

	^ FamixEsopeModel metamodel
]
