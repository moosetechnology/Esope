Class {
	#name : #IASTStatementFunction,
	#superclass : #IASTVarAccess,
	#instVars : [
		'entities'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTStatementFunction >> accept: aVisitor [

	^ aVisitor visitIASTStatementFunction: self
]

{ #category : #initialization }
IASTStatementFunction >> entities [

	^ entities
]

{ #category : #initialization }
IASTStatementFunction >> entities: anObject [

	entities := anObject
]

{ #category : #initialization }
IASTStatementFunction >> initialize [
	super initialize.

	entities := OrderedCollection new
]

{ #category : #testing }
IASTStatementFunction >> isVarAccess [
	^false
]
