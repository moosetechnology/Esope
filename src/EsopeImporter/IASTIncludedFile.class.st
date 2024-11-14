Class {
	#name : 'IASTIncludedFile',
	#superclass : 'IASTProgramUnit',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'visiting' }
IASTIncludedFile >> accept: aVisitor [

	^ aVisitor visitIASTIncludedFile: self
]
