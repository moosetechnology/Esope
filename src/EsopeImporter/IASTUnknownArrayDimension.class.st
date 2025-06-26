"
This marks an unknown dimension in an array declaration.
Like so: `INTEGER anArray(*)`
"
Class {
	#name : 'IASTUnknownArrayDimension',
	#superclass : 'IASTAbstractEntity',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'visiting' }
IASTUnknownArrayDimension >> accept: aVisitor [

	^ aVisitor visitIASTUnknownArrayDimension: self.
]
