Class {
	#name : #IASTAbstractEntity,
	#superclass : #Object,
	#instVars : [
		'sourceAnchor'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #visiting }
IASTAbstractEntity >> accept: aVisitor [

	self subclassResponsibility
]

{ #category : #testing }
IASTAbstractEntity >> isEsopeSegment [
	^false
]

{ #category : #accessing }
IASTAbstractEntity >> sourceAnchor [

	<FMProperty: #tokenPosition type: #Object>
	<FMComment: 'represente the position(startLine, startColumn, endLine, endColumn) of each node of IRAST'>
	^ sourceAnchor
]

{ #category : #accessing }
IASTAbstractEntity >> sourceAnchor: anObject [

	sourceAnchor := anObject
]
