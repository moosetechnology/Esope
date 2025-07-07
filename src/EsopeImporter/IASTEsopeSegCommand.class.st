Class {
	#name : 'IASTEsopeSegCommand',
	#superclass : 'IASTAbstractEntity',
	#instVars : [
		'entityName',
		'command',
		'isWritable'
	],
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'visiting' }
IASTEsopeSegCommand >> accept: aVisitor [

	^aVisitor visitIASTEsopeSegCommand: self
]

{ #category : 'accessing' }
IASTEsopeSegCommand >> entityName [

	^ entityName
]

{ #category : 'accessing' }
IASTEsopeSegCommand >> entityName: anObject [

	entityName := anObject
]

{ #category : 'accessing' }
IASTEsopeSegCommand >> esopeCommand [

	^ command
]

{ #category : 'accessing' }
IASTEsopeSegCommand >> esopeCommand: anObject [

	command := anObject
]

{ #category : 'testing' }
IASTEsopeSegCommand >> isEsope [
	^true
]

{ #category : 'testing' }
IASTEsopeSegCommand >> isParameterDefinition [ 

	^false
]

{ #category : 'accessing' }
IASTEsopeSegCommand >> isWritable [

	^ isWritable
]

{ #category : 'accessing' }
IASTEsopeSegCommand >> isWritable: anObject [

	isWritable := anObject
]
