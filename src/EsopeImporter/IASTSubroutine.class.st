Class {
	#name : #IASTSubroutine,
	#superclass : #IASTProgramUnit,
	#instVars : [
		'parameters'
	],
	#category : #'EsopeImporter-AST-IR'
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
IASTSubroutine >> parameters: nodes [

	parameters := nodes
]
