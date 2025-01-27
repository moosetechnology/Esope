Extension { #name : 'FamixF77Invocation' }

{ #category : '*Famix-Fortran-Visitors' }
FamixF77Invocation >> accept: aVisitor [

	^ aVisitor visitFamixF77Invocation: self
]
