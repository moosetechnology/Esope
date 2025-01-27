Extension { #name : 'FamixEsopeDimentionalInteger' }

{ #category : '*Famix-Esope-Visitors' }
FamixEsopeDimentionalInteger >> accept: aVisitor [

	^ aVisitor visitFamixEsopeDimentionalInteger: self
]
