Class {
	#name : 'IASTEntityRef',
	#superclass : 'IASTAbstractEntity',
	#instVars : [
		'entityName',
		'annotations'
	],
	#category : 'EsopeImporter-AST-IR',
	#package : 'EsopeImporter',
	#tag : 'AST-IR'
}

{ #category : 'accessing' }
IASTEntityRef >> annotations [

	^ annotations
]

{ #category : 'accessing' }
IASTEntityRef >> annotations: anObject [

	annotations := anObject
]

{ #category : 'accessing' }
IASTEntityRef >> entityName [

	^ entityName
]

{ #category : 'accessing' }
IASTEntityRef >> entityName: anObject [

	entityName := anObject
]
