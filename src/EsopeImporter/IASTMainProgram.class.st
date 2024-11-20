Class {
	#name : 'IASTMainProgram',
	#superclass : 'IASTProgramUnit',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'accessing' }
IASTMainProgram >> accept: aVisitor [

	^ aVisitor visitIASTMainProgram: self.
]
