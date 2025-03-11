"
## Relations
======================

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `newAccess` | `FamixEsopeCommandSegcop` | `newAccessOwner` | `FamixF77Access` | |



"
Class {
	#name : 'FamixEsopeCommandSegcop',
	#superclass : 'FamixEsopeCommand',
	#category : 'Famix-Esope-Entities-Entities',
	#package : 'Famix-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixEsopeCommandSegcop class >> annotation [

	<FMClass: #CommandSegcop super: #FamixEsopeCommand>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FamixEsopeCommandSegcop >> newAccess [
	"Relation named: #newAccess type: #FamixF77Access opposite: #newAccessOwner"

	<generated>
	<FMProperty: #newAccess type: #FamixF77Access opposite: #newAccessOwner>
	^ self attributeAt: #newAccess ifAbsent: [ nil ]
]

{ #category : 'accessing' }
FamixEsopeCommandSegcop >> newAccess: anObject [

	<generated>
	(self attributeAt: #newAccess ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self newAccess.
		self attributeAt: #newAccess put: anObject.
		otherSide newAccessOwner: nil ]
	ifNotNil: [ 
		self attributeAt: #newAccess put: anObject.
		anObject newAccessOwner: self ]
]
