Class {
	#name : 'IASTVarEsoAt',
	#superclass : 'IASTVarEso',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'instance creation' }
IASTVarEsoAt class >> realName [
	^ 'd__'
]

{ #category : 'accessing' }
IASTVarEsoAt >> accept: aVisitor [

	^ aVisitor visitIASTVarEsoAt: self
]
