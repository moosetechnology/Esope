Class {
	#name : 'IASTStatementFunction',
	#superclass : 'IASTVarAccess',
	#instVars : [
		'entities',
		'body',
		'parameters'
	],
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'accessing' }
IASTStatementFunction >> accept: aVisitor [

	^ aVisitor visitIASTStatementFunction: self
]

{ #category : 'accessing' }
IASTStatementFunction >> body [

	^ body
]

{ #category : 'accessing' }
IASTStatementFunction >> body: anObject [

	body := anObject
]

{ #category : 'initialization' }
IASTStatementFunction >> entities [

	^ entities
]

{ #category : 'initialization' }
IASTStatementFunction >> entities: anObject [

	entities := anObject
]

{ #category : 'initialization' }
IASTStatementFunction >> initialize [
	super initialize.

	entities := OrderedCollection new
]

{ #category : 'testing' }
IASTStatementFunction >> isVarAccess [
	^false
]

{ #category : 'accessing' }
IASTStatementFunction >> parameters [

	^ parameters
]

{ #category : 'accessing' }
IASTStatementFunction >> parameters: anObject [

	parameters := anObject
]
