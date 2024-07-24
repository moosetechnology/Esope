Class {
	#name : #IASTIncludedFile,
	#superclass : #IASTProgramUnit,
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #visiting }
IASTIncludedFile >> accept: aVisitor [

	^ aVisitor visitIASTIncludedFile: self
]
