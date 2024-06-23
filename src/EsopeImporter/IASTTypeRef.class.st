Class {
	#name : #IASTTypeRef,
	#superclass : #IASTEntityRef,
	#instVars : [
		'length',
		'kind'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTTypeRef >> accept: aVisitor [

	^ aVisitor visitIASTTypeRef: self.
]

{ #category : #accessing }
IASTTypeRef >> kind [

	^ kind
]

{ #category : #accessing }
IASTTypeRef >> kind: anObject [

	kind := anObject
]

{ #category : #accessing }
IASTTypeRef >> length [

	^ length
]

{ #category : #accessing }
IASTTypeRef >> length: anObject [

	length := anObject
]
