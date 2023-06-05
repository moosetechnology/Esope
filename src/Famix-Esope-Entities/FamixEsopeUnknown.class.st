"
This entity do not exist or wrongly processed
"
Class {
	#name : #FamixEsopeUnknown,
	#superclass : #FamixEsopeEntity,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeUnknown class >> annotation [

	<FMClass: #Unknown super: #FamixEsopeEntity>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #'private - utility' }
FamixEsopeUnknown class >> getNameFrom: anEntity [

	^ self
]

{ #category : #'private - utility' }
FamixEsopeUnknown class >> newEntity: anEntity [

	self new
		comment: anEntity;
		mooseModel: anEntity mooseModel
]

{ #category : #accessing }
FamixEsopeUnknown >> eComment [
	"Relation named: #eComment type: #FamixFortran77EComment opposite: #unknown"

	<generated>
	<derived>
	<FMProperty: #eComment type: #FamixFortran77EComment opposite: #unknown>
	^ self attributeAt: #eComment ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixEsopeUnknown >> eComment: anObject [

	<generated>
	(self attributeAt: #eComment ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self eComment.
		self attributeAt: #eComment put: anObject.
		otherSide unknown: nil ]
	ifNotNil: [ 
		self attributeAt: #eComment put: anObject.
		anObject unknown: self ]
]
