Extension { #name : 'FamixEsopeSegment' }

{ #category : '*Famix-Esope-Visitors' }
FamixEsopeSegment >> accept: aVisitor [

	^ aVisitor visitFamixEsopeSegment: self
]
