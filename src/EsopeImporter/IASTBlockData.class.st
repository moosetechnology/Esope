Class {
	#name : #IASTBlockData,
	#superclass : #IASTProgramUnit,
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTBlockData >> accept: aVisitor [

	^ aVisitor visitIASTBlockData: self.
]
