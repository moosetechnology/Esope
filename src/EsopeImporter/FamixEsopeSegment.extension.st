Extension { #name : #FamixEsopeSegment }

{ #category : #'*EsopeImporter' }
FamixEsopeSegment >> addLocalVariable: aVariable [

	self addAttribute: aVariable
]

{ #category : #'*EsopeImporter' }
FamixEsopeSegment >> localVariableClass [

	^ FamixEsopeAttribute
]
