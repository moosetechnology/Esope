Class {
	#name : 'IASTIOStatement',
	#superclass : 'IASTAbstractEntity',
	#instVars : [
		'entityName',
		'format',
		'arguments'
	],
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'visiting' }
IASTIOStatement >> accept: aVisitor [

	^ aVisitor visitIASTIOStatement: self
]

{ #category : 'accessing' }
IASTIOStatement >> arguments [

	^ arguments
]

{ #category : 'accessing' }
IASTIOStatement >> arguments: anObject [

	arguments := anObject
]

{ #category : 'accessing' }
IASTIOStatement >> entityName [

	^ entityName
]

{ #category : 'accessing' }
IASTIOStatement >> entityName: anObject [

	entityName := anObject
]

{ #category : 'accessing' }
IASTIOStatement >> format [

	^ format
]

{ #category : 'accessing' }
IASTIOStatement >> format: anObject [

	format := anObject
]
