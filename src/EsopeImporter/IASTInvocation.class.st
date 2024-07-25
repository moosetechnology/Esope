Class {
	#name : #IASTInvocation,
	#superclass : #IASTEntityRef,
	#instVars : [
		'isIntrinsic',
		'arguments',
		'indices'
	],
	#category : 'EsopeImporter-AST-IR'
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
IASTInvocation >> indices [

	^ indices
]

{ #category : #accessing }
IASTInvocation >> indices: anObject [

	indices := anObject
]

{ #category : #accessing }
IASTInvocation >> isIntrinsic [

	^ isIntrinsic
]

{ #category : #accessing }
IASTInvocation >> isIntrinsic: anObject [

	isIntrinsic := anObject
]

{ #category : #testing }
IASTInvocation >> isInvocation [
	^true
]
