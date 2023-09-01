Class {
	#name : #IASTVariable,
	#superclass : #IASTEntityRef,
	#instVars : [
		'typeSpec',
		'initialValue',
		'dimension'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTVariable >> accept: aVisitor [

	^ aVisitor visitIASTVariable: self.
]

{ #category : #accessing }
IASTVariable >> dimension [

	^ dimension
]

{ #category : #accessing }
IASTVariable >> dimension: anObject [

	dimension := anObject
]

{ #category : #accessing }
IASTVariable >> initialValue [
	self flag: 'to remove'.
	^ initialValue
]

{ #category : #accessing }
IASTVariable >> initialValue: anObject [

	initialValue := anObject
]

{ #category : #accessing }
IASTVariable >> typeSpec [

	^ typeSpec
]

{ #category : #accessing }
IASTVariable >> typeSpec: anObject [

	typeSpec := anObject
]
