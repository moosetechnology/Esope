Class {
	#name : #IASTProgramFile,
	#superclass : #IASTAbstractEntity,
	#instVars : [
		'filename',
		'version',
		'progUnits'
	],
	#category : #'EsopeImporter-AST-IR'
}

{ #category : #accessing }
IASTProgramFile >> accept: aVisitor [

	^ aVisitor visitIASTProgramFile: self.
]

{ #category : #accessing }
IASTProgramFile >> addProgramUnit: anObject [

	^ self progUnits add: anObject
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
	progUnits := OrderedCollection new.

]

{ #category : #accessing }
IASTProgramFile >> progUnits [

	^ progUnits
]

{ #category : #accessing }
IASTProgramFile >> progUnits: anObject [

	progUnits := anObject
]

{ #category : #accessing }
IASTProgramFile >> version [

	^ version
]

{ #category : #accessing }
IASTProgramFile >> version: anObject [

	version := anObject
]
