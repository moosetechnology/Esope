Class {
	#name : #IASTMainProgram,
	#superclass : #IASTProgramUnit,
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTMainProgram >> accept: aVisitor [

	^ aVisitor visitIASTMainProgram: self.
]
