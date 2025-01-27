Extension { #name : 'FamixF77ProgramFile' }

{ #category : '*Famix-Fortran-Visitors' }
FamixF77ProgramFile >> accept: aVisitor [

	^ aVisitor visitFamixF77ProgramFile: self
]
