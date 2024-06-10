Class {
	#name : #IASTProgramUnit,
	#superclass : #IASTAbstractEntity,
	#instVars : [
		'body',
		'entityName',
		'implicits',
		'annotations'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTProgramUnit >> accesses [
	^self filterBodyWith: [ :entity | entity isVarAccess ]
]

{ #category : #accessing }
IASTProgramUnit >> annotations [

	^ annotations
]

{ #category : #accessing }
IASTProgramUnit >> annotations: anObject [

	annotations := anObject
]

{ #category : #accessing }
IASTProgramUnit >> body [

	^ body
]

{ #category : #accessing }
IASTProgramUnit >> body: anObject [

	body := anObject
]

{ #category : #accessing }
IASTProgramUnit >> comments [
	^self localComments 
]

{ #category : #accessing }
IASTProgramUnit >> entityName [

	^ entityName
]

{ #category : #accessing }
IASTProgramUnit >> entityName: anObject [

	entityName := anObject
]

{ #category : #accessing }
IASTProgramUnit >> filterBodyWith: aFilterBlock [
	^body
		  ifNil:    [ #( ) ]
		  ifNotNil: [ body flattened select: aFilterBlock ]
]

{ #category : #accessing }
IASTProgramUnit >> implicits [
	^implicits ifNil: [ 
		implicits := self filterBodyWith: [ :entity | entity isImplicit ] ]
]

{ #category : #accessing }
IASTProgramUnit >> implicits: anObject [

	implicits := anObject
]

{ #category : #accessing }
IASTProgramUnit >> invocations [
	^self filterBodyWith: [ :entity | entity isInvocation ]
]

{ #category : #testing }
IASTProgramUnit >> isProgUnit [

	^true
]

{ #category : #testing }
IASTProgramUnit >> isProgUnit: anObject [

	"ignored
	 polymorphism with IASTComment"
]

{ #category : #accessing }
IASTProgramUnit >> localComments [
	^self filterBodyWith: [ :entity | entity isComment ]
]

{ #category : #accessing }
IASTProgramUnit >> localVariables [
	^self filterBodyWith: [ :entity | entity isVariable ]
]
