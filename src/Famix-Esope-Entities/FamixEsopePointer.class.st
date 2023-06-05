"
# Creating and initializing a SEGMENT:
Let's place ourselves again inside a fortran subprogram. 

After having declared the segment by the instruction `SEGMENT...ENDSEGMENT` we have to define a variable which will reference the instanciated structure: the knowledge of this variable gives access to the whole structure. For this purpose a new type of fortran variable is invented: it is the pointer variable whose declaration is : `pointeur poitername.segmentname`.

For example, to allow the instantiation of the class(segment) `myseg` , we declare something like that : 
```fortran77
pointeur ptr1.myseg, ptr2.myseg, ....
```
In this example, `ptr1` and `ptr2` allow to reference a structure of the `myseg` class.

`ptr1` and `ptr2` become a fortran variable of type integer once the tranlation `Esope -> Fortran77` is done.

The creation of a myseg class structure is done by calling `segini` function and specifying the pointer variable used.

"
Class {
	#name : #FamixEsopePointer,
	#superclass : #FamixEsopeFortranVariable,
	#instVars : [
		'#segment => FMOne type: #FamixEsopeSegment opposite: #pointers',
		'#segmentCommand => FMOne type: #FamixEsopeSegmentCommand opposite: #pointer'
	],
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopePointer class >> annotation [

	<FMClass: #Pointer super: #FamixEsopeFortranVariable>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #'private - utility' }
FamixEsopePointer class >> getNameFrom: anEntity [

	^ (((anEntity removePrefix: #eso) trim removePrefix: #pointeur)
		  trim removePrefix: ',') trim
]

{ #category : #'private - utility' }
FamixEsopePointer class >> newEntity: anEntity [

	self new
		comment: anEntity;
		mooseModel: anEntity mooseModel;
		name: (self getNameFrom: anEntity content)
]

{ #category : #accessing }
FamixEsopePointer >> eComment [
	"Relation named: #eComment type: #FamixFortran77EComment opposite: #pointer"

	<generated>
	<derived>
	<FMProperty: #eComment type: #FamixFortran77EComment opposite: #pointer>
	^ self attributeAt: #eComment ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixEsopePointer >> eComment: anObject [

	<generated>
	(self attributeAt: #eComment ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self eComment.
		self attributeAt: #eComment put: anObject.
		otherSide pointer: nil ]
	ifNotNil: [ 
		self attributeAt: #eComment put: anObject.
		anObject pointer: self ]
]

{ #category : #accessing }
FamixEsopePointer >> segment [
	"Relation named: #segment type: #FamixEsopeSegment opposite: #pointers"

	<generated>
	^ segment
]

{ #category : #accessing }
FamixEsopePointer >> segment: anObject [

	<generated>
	segment := anObject
]

{ #category : #accessing }
FamixEsopePointer >> segmentCommand [
	"Relation named: #segmentCommand type: #FamixEsopeSegmentCommand opposite: #pointer"

	<generated>
	<derived>
	^ segmentCommand
]

{ #category : #accessing }
FamixEsopePointer >> segmentCommand: anObject [

	<generated>
	segmentCommand := anObject
]
