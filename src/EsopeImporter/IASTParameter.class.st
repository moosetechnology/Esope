Class {
	#name : #IASTParameter,
	#superclass : #IASTEntityRef,
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTParameter >> accept: aVisitor [

	^ aVisitor visitIASTParameter: self.
]
