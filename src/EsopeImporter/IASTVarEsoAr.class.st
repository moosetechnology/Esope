Class {
	#name : #IASTVarEsoAr,
	#superclass : #IASTVarEso,
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #'instance creation' }
IASTVarEsoAr class >> realName [
	^ ''
]

{ #category : #accessing }
IASTVarEsoAr >> accept: aVisitor [

	^ aVisitor visitIASTVarEsoAr: self
]
