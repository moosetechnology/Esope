Class {
	#name : #IASTImplicitTypingRule,
	#superclass : #IASTAbstractEntity,
	#instVars : [
		'forType',
		'ranges'
	],
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTImplicitTypingRule >> accept: aVisitor [

	^ aVisitor visitIASTImplicit: self.
]

{ #category : #accessing }
IASTImplicitTypingRule >> forType [

	^ forType
]

{ #category : #accessing }
IASTImplicitTypingRule >> forType: anObject [

	forType := anObject
]

{ #category : #accessing }
IASTImplicitTypingRule >> ranges [
	"actually a collection of ranges, each range being an array {from . to}"
	^ranges
]

{ #category : #accessing }
IASTImplicitTypingRule >> ranges: anObject [

	ranges := anObject
]
