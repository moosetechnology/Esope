Extension { #name : 'FamixEsopeImplicitPointer' }

{ #category : '*Famix-Esope-Visitors' }
FamixEsopeImplicitPointer >> accept: aVisitor [

	^ aVisitor visitFamixEsopeImplicitPointer: self
]
