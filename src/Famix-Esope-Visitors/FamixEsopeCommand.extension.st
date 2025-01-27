Extension { #name : 'FamixEsopeCommand' }

{ #category : '*Famix-Esope-Visitors' }
FamixEsopeCommand >> accept: aVisitor [

	^ aVisitor visitFamixEsopeCommand: self
]
