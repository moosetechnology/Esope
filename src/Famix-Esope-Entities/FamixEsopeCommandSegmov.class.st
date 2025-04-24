"
## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `changedAccess` | `FamixEsopeCommandSegmov` | `changedAccessOwner` | `FamixF77Access` | |



"
Class {
	#name : 'FamixEsopeCommandSegmov',
	#superclass : 'FamixEsopeCommand',
	#category : 'Famix-Esope-Entities-Entities',
	#package : 'Famix-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixEsopeCommandSegmov class >> annotation [

	<FMClass: #CommandSegmov super: #FamixEsopeCommand>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FamixEsopeCommandSegmov >> changedAccess [
	"Relation named: #changedAccess type: #FamixF77Access opposite: #changedAccessOwner"

	<generated>
	<FMProperty: #changedAccess type: #FamixF77Access opposite: #changedAccessOwner>
	^ self attributeAt: #changedAccess ifAbsent: [ nil ]
]

{ #category : 'accessing' }
FamixEsopeCommandSegmov >> changedAccess: anObject [

	<generated>
	(self attributeAt: #changedAccess ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self changedAccess.
		self attributeAt: #changedAccess put: anObject.
		otherSide changedAccessOwner: nil ]
	ifNotNil: [ 
		self attributeAt: #changedAccess put: anObject.
		anObject changedAccessOwner: self ]
]
