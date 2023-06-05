"
# Handling of data structures: `SEGMENT`

Few instructions have been added to those of `fortran77`. They are used to manipulate and use the `SEGMENTS`.

As in Fortran, we are led to have a declarative instruction of the SEGMENT and then instructions which act on the SEGMENT. The main thing is to :

    - `segini`: create a segment (or INItialize)
    - `segsup`: Delete(SUPprimer) a segment
    - `segdes`: deactivate (DESactiver) a segment
    - `segact`: ACTivate a segment
    - `segadj`: ADJust the size of a segment.	

"
Class {
	#name : #FamixEsopeSegmentCommand,
	#superclass : #FamixEsopeEntity,
	#traits : 'FamixTNamedEntity',
	#classTraits : 'FamixTNamedEntity classTrait',
	#instVars : [
		'#pointer => FMOne type: #FamixEsopePointer opposite: #segmentCommand'
	],
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeSegmentCommand class >> annotation [

	<FMClass: #SegmentCommand super: #FamixEsopeEntity>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixEsopeSegmentCommand >> eComment [
	"Relation named: #eComment type: #FamixFortran77EComment opposite: #segmentCommand"

	<generated>
	<derived>
	<FMProperty: #eComment type: #FamixFortran77EComment opposite: #segmentCommand>
	^ self attributeAt: #eComment ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixEsopeSegmentCommand >> eComment: anObject [

	<generated>
	(self attributeAt: #eComment ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self eComment.
		self attributeAt: #eComment put: anObject.
		otherSide segmentCommand: nil ]
	ifNotNil: [ 
		self attributeAt: #eComment put: anObject.
		anObject segmentCommand: self ]
]

{ #category : #accessing }
FamixEsopeSegmentCommand >> pointer [
	"Relation named: #pointer type: #FamixEsopePointer opposite: #segmentCommand"

	<generated>
	^ pointer
]

{ #category : #accessing }
FamixEsopeSegmentCommand >> pointer: anObject [

	<generated>
	pointer := anObject
]
