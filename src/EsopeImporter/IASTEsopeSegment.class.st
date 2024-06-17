"
Intermediate representation of AST for ESOPE segment declaration

A segment has
- an `entityName`
- a list of `declarations` (fields in the segment)
"
Class {
	#name : #IASTEsopeSegment,
	#superclass : #IASTAbstractEntity,
	#instVars : [
		'entityName',
		'declarations'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #visiting }
IASTEsopeSegment >> accept: aVisitor [

	^ aVisitor visitIASTEsopeSegment: self.
]

{ #category : #accessing }
IASTEsopeSegment >> addAllDeclarations: aCollection [

	declarations addAll: aCollection
]

{ #category : #accessing }
IASTEsopeSegment >> addDeclaration: anObject [

	declarations add: anObject
]

{ #category : #accessing }
IASTEsopeSegment >> declarations [

	^ declarations
]

{ #category : #accessing }
IASTEsopeSegment >> declarations: anObject [

	declarations := anObject
]

{ #category : #accessing }
IASTEsopeSegment >> entityName [

	^ entityName
]

{ #category : #accessing }
IASTEsopeSegment >> entityName: anObject [

	entityName := anObject
]

{ #category : #testing }
IASTEsopeSegment >> isEsope [
	^true
]

{ #category : #testing }
IASTEsopeSegment >> isEsopeSegment [
	^true
]
