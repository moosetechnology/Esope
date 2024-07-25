Class {
	#name : #IASTAbstractEntity,
	#superclass : #Object,
	#instVars : [
		'sourceAnchor'
	],
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #visiting }
IASTAbstractEntity >> accept: aVisitor [

	self subclassResponsibility
]

{ #category : #testing }
IASTAbstractEntity >> isComment [
	^false
]

{ #category : #testing }
IASTAbstractEntity >> isEsopeSegment [
	^false
]

{ #category : #testing }
IASTAbstractEntity >> isImplicit [
	^false
]

{ #category : #testing }
IASTAbstractEntity >> isInvocation [
	^false
]

{ #category : #testing }
IASTAbstractEntity >> isVarAccess [
	^false
]

{ #category : #testing }
IASTAbstractEntity >> isVariable [
	^false
]

{ #category : #accessing }
IASTAbstractEntity >> sourceAnchor [

	^ sourceAnchor
]

{ #category : #accessing }
IASTAbstractEntity >> sourceAnchor: anObject [

	sourceAnchor := anObject
]
