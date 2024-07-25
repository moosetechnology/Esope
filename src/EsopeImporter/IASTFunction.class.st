Class {
	#name : #IASTFunction,
	#superclass : #IASTSubroutine,
	#instVars : [
		'returnType'
	],
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTFunction >> accept: aVisitor [

	^ aVisitor visitIASTFunction: self.
]

{ #category : #accessing }
IASTFunction >> returnType [

	^ returnType
]

{ #category : #accessing }
IASTFunction >> returnType: anObject [

	returnType := anObject
]
