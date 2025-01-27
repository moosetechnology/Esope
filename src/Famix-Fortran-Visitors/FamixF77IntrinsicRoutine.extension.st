Extension { #name : 'FamixF77IntrinsicRoutine' }

{ #category : '*Famix-Fortran-Visitors' }
FamixF77IntrinsicRoutine >> accept: aVisitor [

	^aVisitor visitFamixF77IntrinsicRoutine: self 
]
