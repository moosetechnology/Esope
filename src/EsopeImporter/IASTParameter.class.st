Class {
	#name : 'IASTParameter',
	#superclass : 'IASTEntityRef',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'accessing' }
IASTParameter >> accept: aVisitor [

	^ aVisitor visitIASTParameter: self.
]
