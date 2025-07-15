Class {
	#name : 'IASTCommon',
	#superclass : 'IASTEntityRef',
	#instVars : [
		'variables'
	],
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'visiting' }
IASTCommon >> accept: aVisitor [

	^aVisitor visitIASTCommon: self
]

{ #category : 'accessing' }
IASTCommon >> variables [

	^ variables
]

{ #category : 'accessing' }
IASTCommon >> variables: anObject [

	variables := anObject
]
