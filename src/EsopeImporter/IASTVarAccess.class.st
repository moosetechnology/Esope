Class {
	#name : #IASTVarAccess,
	#superclass : #IASTEntityRef,
	#instVars : [
		'isWrite'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTVarAccess >> accept: aVisitor [

	^ aVisitor visitIASTVarAccess: self.
]

{ #category : #accessing }
IASTVarAccess >> isEsope [

	^ self entityName
		  ifNotNil: [ { #esoar. #esoat. #esosl } includes: self entityName ]
		  ifNil: [ false ]
]

{ #category : #accessing }
IASTVarAccess >> isWrite [

	^ isWrite ifNil: [ isWrite := false ]
]

{ #category : #accessing }
IASTVarAccess >> isWrite: anObject [

	isWrite := anObject
]
