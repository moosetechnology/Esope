Class {
	#name : #IASTIndexedFileAnchor,
	#superclass : #Object,
	#instVars : [
		'startLine',
		'startColumn',
		'endLine',
		'endColumn',
		'fileName'
	],
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTIndexedFileAnchor >> accept: aVisitor [
	^aVisitor visitIndexedFileAnchor: self
]

{ #category : #accessing }
IASTIndexedFileAnchor >> endColumn [

	^ endColumn
]

{ #category : #accessing }
IASTIndexedFileAnchor >> endColumn: anObject [

	endColumn := anObject
]

{ #category : #accessing }
IASTIndexedFileAnchor >> endLine [

	^ endLine
]

{ #category : #accessing }
IASTIndexedFileAnchor >> endLine: anObject [

	endLine := anObject
]

{ #category : #accessing }
IASTIndexedFileAnchor >> fileName [

	^ fileName
]

{ #category : #accessing }
IASTIndexedFileAnchor >> fileName: anObject [

	fileName := anObject
]

{ #category : #accessing }
IASTIndexedFileAnchor >> startColumn [

	^ startColumn
]

{ #category : #accessing }
IASTIndexedFileAnchor >> startColumn: anObject [

	startColumn := anObject
]

{ #category : #accessing }
IASTIndexedFileAnchor >> startLine [

	^ startLine
]

{ #category : #accessing }
IASTIndexedFileAnchor >> startLine: anObject [

	startLine := anObject
]
