Class {
	#name : 'IASTBlockData',
	#superclass : 'IASTProgramUnit',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'accessing' }
IASTBlockData >> accept: aVisitor [

	^ aVisitor visitIASTBlockData: self.
]
