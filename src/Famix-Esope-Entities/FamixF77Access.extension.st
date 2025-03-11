Extension { #name : 'FamixF77Access' }

{ #category : '*Famix-Esope-Entities-accessing' }
FamixF77Access >> changedAccessOwner [
	"Relation named: #changedAccessOwner type: #FamixEsopeCommandSegmov opposite: #changedAccess"

	<generated>
	<derived>
	<FMProperty: #changedAccessOwner type: #FamixEsopeCommandSegmov opposite: #changedAccess>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #changedAccessOwner ifAbsent: [ nil ]
]

{ #category : '*Famix-Esope-Entities-accessing' }
FamixF77Access >> changedAccessOwner: anObject [

	<generated>
	(self attributeAt: #changedAccessOwner ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self changedAccessOwner.
		self attributeAt: #changedAccessOwner put: anObject.
		otherSide changedAccess: nil ]
	ifNotNil: [ 
		self attributeAt: #changedAccessOwner put: anObject.
		anObject changedAccess: self ]
]

{ #category : '*Famix-Esope-Entities-accessing' }
FamixF77Access >> newAccessOwner [
	"Relation named: #newAccessOwner type: #FamixEsopeCommandSegcop opposite: #newAccess"

	<generated>
	<derived>
	<FMProperty: #newAccessOwner type: #FamixEsopeCommandSegcop opposite: #newAccess>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #newAccessOwner ifAbsent: [ nil ]
]

{ #category : '*Famix-Esope-Entities-accessing' }
FamixF77Access >> newAccessOwner: anObject [

	<generated>
	(self attributeAt: #newAccessOwner ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self newAccessOwner.
		self attributeAt: #newAccessOwner put: anObject.
		otherSide newAccess: nil ]
	ifNotNil: [ 
		self attributeAt: #newAccessOwner put: anObject.
		anObject newAccess: self ]
]

{ #category : '*Famix-Esope-Entities-accessing' }
FamixF77Access >> oldAccessOwner [
	"Relation named: #oldAccessOwner type: #FamixEsopeCommandSegcop opposite: #oldAccess"

	<generated>
	<derived>
	<FMProperty: #oldAccessOwner type: #FamixEsopeCommandSegcop opposite: #oldAccess>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #oldAccessOwner ifAbsent: [ nil ]
]

{ #category : '*Famix-Esope-Entities-accessing' }
FamixF77Access >> oldAccessOwner: anObject [

	<generated>
	(self attributeAt: #oldAccessOwner ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self oldAccessOwner.
		self attributeAt: #oldAccessOwner put: anObject.
		otherSide oldAccess: nil ]
	ifNotNil: [ 
		self attributeAt: #oldAccessOwner put: anObject.
		anObject oldAccess: self ]
]
