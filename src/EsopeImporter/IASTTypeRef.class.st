Class {
	#name : #IASTTypeRef,
	#superclass : #IASTEntityRef,
	#instVars : [
		'length',
		'kind'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTTypeRef >> accept: aVisitor [

	^ aVisitor visitIASTTypeRef: self.
]

{ #category : #accessing }
IASTTypeRef >> addSelector: selector [

	self flag: #NOTHING. "self length: (selector first = 'Nothing'
			 ifFalse: [ 
				 (selector first class = IASTVarAccess and: [ 
					  selector first isAssigned ])
					 ifTrue: [ selector first entityName asNumber ]
					 ifFalse: [ 0 ] ]).
	self kind: (selector second = 'Nothing'
			 ifFalse: [ 
				 selector second isAssigned ifTrue: [ 
					 selector second entityName asNumber ] ])"
	self length: (selector first ifNotNil: [ 
			 (selector first class = IASTVarAccess and: [ 
				  selector first isAssigned ])
				 ifTrue: [ selector first entityName asNumber ]
				 ifFalse: [ 0 ] ]).
	self kind: (selector second ifNotNil: [ 
			 selector second isAssigned ifTrue: [ 
				 selector second entityName asNumber ] ])
]

{ #category : #accessing }
IASTTypeRef >> kind [

	^ kind
]

{ #category : #accessing }
IASTTypeRef >> kind: anObject [

	kind := anObject
]

{ #category : #accessing }
IASTTypeRef >> length [

	^ length
]

{ #category : #accessing }
IASTTypeRef >> length: anObject [

	length := anObject
]
