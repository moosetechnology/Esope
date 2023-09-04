Class {
	#name : #IASTVarAccess,
	#superclass : #IASTEntityRef,
	#instVars : [
		'isWrite',
		'indices'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTVarAccess >> accept: aVisitor [

	^ aVisitor visitIASTVarAccess: self.
]

{ #category : #accessing }
IASTVarAccess >> indices [

	^ indices
]

{ #category : #accessing }
IASTVarAccess >> indices: anObject [

	indices := anObject
]

{ #category : #initialization }
IASTVarAccess >> initialize [
	super initialize.

	indices := OrderedCollection new
]

{ #category : #accessing }
IASTVarAccess >> isEsope [

	^ self entityName
		  ifNotNil: [ { #esoar. #esoat. #esosl } includes: self entityName ]
		  ifNil: [ false ]
]

{ #category : #testing }
IASTVarAccess >> isVarAccess [
	^true
]

{ #category : #accessing }
IASTVarAccess >> isWrite [

	^ isWrite ifNil: [ isWrite := false ]
]

{ #category : #accessing }
IASTVarAccess >> isWrite: anObject [

	isWrite := anObject
]
