Class {
	#name : #IASTEsopePointer,
	#superclass : #IASTEntityRef,
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #visiting }
IASTEsopePointer >> accept: aVisitor [

	^ aVisitor visitIASTEsopePointer: self
]
