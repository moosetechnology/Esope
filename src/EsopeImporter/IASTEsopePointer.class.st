Class {
	#name : 'IASTEsopePointer',
	#superclass : 'IASTEntityRef',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'visiting' }
IASTEsopePointer >> accept: aVisitor [

	^ aVisitor visitIASTEsopePointer: self
]

{ #category : 'testing' }
IASTEsopePointer >> isEsope [
	^true
]
