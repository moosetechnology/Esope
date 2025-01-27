Extension { #name : 'FamixF77ExternalDeclaration' }

{ #category : '*Famix-Fortran-Visitors' }
FamixF77ExternalDeclaration >> accept: aVisitor [

	^ aVisitor visitFamixF77ExternalDeclaration: self
]
