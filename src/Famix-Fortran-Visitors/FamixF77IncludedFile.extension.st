Extension { #name : 'FamixF77IncludedFile' }

{ #category : '*Famix-Fortran-Visitors' }
FamixF77IncludedFile >> accept: aVisitor [

	^ aVisitor visitFamixF77IncludedFile: self
]
