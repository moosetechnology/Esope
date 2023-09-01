Class {
	#name : #IASTInvocation,
	#superclass : #IASTEntityRef,
	#instVars : [
		'isIntrinsic',
		'arguments'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTInvocation >> accept: aVisitor [

	^ aVisitor visitIASTInvocation: self.
]

{ #category : #accessing }
IASTInvocation >> arguments [

	^ arguments ifNil: [ arguments := OrderedCollection new ]
]

{ #category : #accessing }
IASTInvocation >> arguments: aNodes [

	arguments := aNodes
]

{ #category : #accessing }
IASTInvocation >> isIntrinsic [

	^ isIntrinsic
]

{ #category : #accessing }
IASTInvocation >> isIntrinsic: anObject [

	isIntrinsic := anObject
]
