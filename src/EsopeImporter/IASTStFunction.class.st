Class {
	#name : #IASTStFunction,
	#superclass : #IASTVarAccess,
	#instVars : [
		'entities'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTStFunction >> accept: aVisitor [

	^ aVisitor visitIASTStFunction: self
]

{ #category : #initialization }
IASTStFunction >> entities [

	^ entities
]

{ #category : #initialization }
IASTStFunction >> entities: anObject [

	entities := anObject
]

{ #category : #initialization }
IASTStFunction >> initialize [
	super initialize.

	entities := OrderedCollection new
]

{ #category : #testing }
IASTStFunction >> isVarAccess [
	^false
]
