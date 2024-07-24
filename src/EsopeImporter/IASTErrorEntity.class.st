"
An Entity created when there is an import error.
It does not do anything and has some methods to be polymorphic with other entities
"
Class {
	#name : #IASTErrorEntity,
	#superclass : #IASTAbstractEntity,
	#instVars : [
		'filename'
	],
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #visiting }
IASTErrorEntity >> accept: aVisitor [

]

{ #category : #accessing }
IASTErrorEntity >> filename [

	^ filename
]

{ #category : #accessing }
IASTErrorEntity >> filename: anObject [

	filename := anObject
]
