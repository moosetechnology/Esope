Class {
	#name : 'IASTVarEsoSl',
	#superclass : 'IASTVarEso',
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'instance creation' }
IASTVarEsoSl class >> realName [
	^ 's__'
]

{ #category : 'accessing' }
IASTVarEsoSl >> accept: aVisitor [

	^ aVisitor visitIASTVarEsoSl: self
]
