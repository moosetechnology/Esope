Class {
	#name : 'IASTExternalFunctionStatement',
	#superclass : 'IASTEntityRef',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'visiting' }
IASTExternalFunctionStatement >> accept: aVisitor [

	^ aVisitor visitIASTExternalFunctionStatement: self.
]
