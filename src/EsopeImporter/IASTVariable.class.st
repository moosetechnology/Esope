Class {
	#name : #IASTVariable,
	#superclass : #IASTEntityRef,
	#instVars : [
		'typeSpec',
		'initialValue',
		'isEsope',
		'dimensions'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTVariable >> accept: aVisitor [

	^ aVisitor visitIASTVariable: self.
]

{ #category : #accessing }
IASTVariable >> initialValue [

	^ initialValue
]

{ #category : #accessing }
IASTVariable >> initialValue: anObject [

	initialValue := anObject
]

{ #category : #accessing }
IASTVariable >> isEsope [

	^ isEsope
]

{ #category : #accessing }
IASTVariable >> isEsope: anObject [

	isEsope := anObject
]

{ #category : #testing }
IASTVariable >> isVariable [
	^true
]

{ #category : #accessing }
IASTVariable >> typeSpec [

	^ typeSpec
]

{ #category : #accessing }
IASTVariable >> typeSpec: anObject [

	typeSpec := anObject
]
