"
A special IASTNode to model Implied Do.
It is basically a collection of IASTVarAccess
"
Class {
	#name : 'IASTImpliedDo',
	#superclass : 'IASTAbstractEntity',
	#instVars : [
		'doSpecs',
		'expressions'
	],
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'visiting' }
IASTImpliedDo >> accept: aVisitor [

	aVisitor visitIASTImpliedDo: self
]

{ #category : 'accessing' }
IASTImpliedDo >> doSpecs [

	^ doSpecs
]

{ #category : 'accessing' }
IASTImpliedDo >> doSpecs: anObject [

	doSpecs := anObject
]

{ #category : 'accessing' }
IASTImpliedDo >> expressions [

	^ expressions
]

{ #category : 'accessing' }
IASTImpliedDo >> expressions: anObject [

	expressions := anObject
]
