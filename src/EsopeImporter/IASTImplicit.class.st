Class {
	#name : #IASTImplicit,
	#superclass : #IASTAbstractEntity,
	#instVars : [
		'rules'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTImplicit >> accept: aVisitor [

	^ aVisitor visitIASTImplicit: self.
]

{ #category : #testing }
IASTImplicit >> isImplicit [
	^true
]

{ #category : #accessing }
IASTImplicit >> rules [

	^ rules
]

{ #category : #accessing }
IASTImplicit >> rules: anObject [

	rules := anObject
]
