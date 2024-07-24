Class {
	#name : #IASTSubroutine,
	#superclass : #IASTProgramUnit,
	#instVars : [
		'parameters'
	],
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTSubroutine >> accept: aVisitor [

	^ aVisitor visitIASTSubroutine: self.
]

{ #category : #accessing }
IASTSubroutine >> parameters [

	^ parameters ifNil: [ parameters := #() ]
]

{ #category : #accessing }
IASTSubroutine >> parameters: aNodes [

	parameters := aNodes ifNil: [ #(  ) ] ifNotNil: [ 
		              aNodes collect: [ :node | 
			              IASTParameter new
				              sourceAnchor: node sourceAnchor ;
				              entityName: node entityName ;
				              yourself ] ]
]
