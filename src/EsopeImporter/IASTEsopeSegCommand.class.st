Class {
	#name : #IASTEsopeSegCommand,
	#superclass : #IASTAbstractEntity,
	#instVars : [
		'entityName',
		'command'
	],
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #visiting }
IASTEsopeSegCommand >> accept: aVisitor [

	^aVisitor visitIASTEsopeSegCommand: self
]

{ #category : #accessing }
IASTEsopeSegCommand >> entityName [

	^ entityName
]

{ #category : #accessing }
IASTEsopeSegCommand >> entityName: anObject [

	entityName := anObject
]

{ #category : #accessing }
IASTEsopeSegCommand >> esopeCommand [

	^ command
]

{ #category : #accessing }
IASTEsopeSegCommand >> esopeCommand: anObject [

	command := anObject
]

{ #category : #testing }
IASTEsopeSegCommand >> isEsope [
	^true
]
