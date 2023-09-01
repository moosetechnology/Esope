"
Here `entityName` hold the `includedFileName` property.
We use the `includeCommand` to distinguish between the kind of include: 
 - `#include`
 - `-INC` or `%INC`
 - `include` 
"
Class {
	#name : #IASTInclude,
	#superclass : #IASTProgramUnit,
	#instVars : [
		'includeCommand'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #visiting }
IASTInclude >> accept: aVisitor [

	^ aVisitor visitIASTInclude: self
]

{ #category : #accessing }
IASTInclude >> includeCommand [

	^ includeCommand
]

{ #category : #accessing }
IASTInclude >> includeCommand: anObject [

	includeCommand := anObject
]
