Extension { #name : 'FamixEsopeSegment' }

{ #category : '*EsopeImporter' }
FamixEsopeSegment >> addLocalVariable: aVariable [
	self addAttribute: aVariable
]

{ #category : '*EsopeImporter' }
FamixEsopeSegment >> isEsopeSegment [

	^true
]

{ #category : '*EsopeImporter' }
FamixEsopeSegment >> localVariableClass [
	^FamixFortranAttribute
]

{ #category : '*EsopeImporter' }
FamixEsopeSegment class >> metamodel [
	"temporary solution to issue https://github.com/moosetechnology/Famix/issues/808"

	^ FamixEsopeModel metamodel
]
