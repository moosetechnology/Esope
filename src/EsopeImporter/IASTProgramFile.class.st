Class {
	#name : #IASTProgramFile,
	#superclass : #IASTAbstractEntity,
	#instVars : [
		'filename',
		'version',
		'body'
	],
	#category : 'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTProgramFile >> accept: aVisitor [

	^ aVisitor visitIASTProgramFile: self.
]

{ #category : #accessing }
IASTProgramFile >> addProgramUnit: anObject [

	^ self body add: anObject
]

{ #category : #accessing }
IASTProgramFile >> body [

	^ body
]

{ #category : #accessing }
IASTProgramFile >> body: anObject [

	body := anObject
]

{ #category : #accessing }
IASTProgramFile >> filename [

	^ filename
]

{ #category : #accessing }
IASTProgramFile >> filename: anObject [

	filename := anObject
]

{ #category : #accessing }
IASTProgramFile >> initialize [

	super initialize.

	"Default value initialization"
	version := 'Fortran77'.
	body := OrderedCollection new.

]

{ #category : #accessing }
IASTProgramFile >> version [

	^ version
]

{ #category : #accessing }
IASTProgramFile >> version: anObject [

	version := anObject
]
