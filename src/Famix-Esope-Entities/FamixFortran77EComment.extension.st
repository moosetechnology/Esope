Extension { #name : #FamixFortran77EComment }

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EComment >> pointer [
	"Relation named: #pointer type: #FamixEsopePointer opposite: #eComment"

	<generated>
	<FMProperty: #pointer type: #FamixEsopePointer opposite: #eComment>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #pointer ifAbsent: [ nil ]
]

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EComment >> pointer: anObject [

	<generated>
	(self attributeAt: #pointer ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self pointer.
		self attributeAt: #pointer put: anObject.
		otherSide eComment: nil ]
	ifNotNil: [ 
		self attributeAt: #pointer put: anObject.
		anObject eComment: self ]
]

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EComment >> segment [
	"Relation named: #segment type: #FamixEsopeSegment opposite: #eComment"

	<generated>
	<FMProperty: #segment type: #FamixEsopeSegment opposite: #eComment>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #segment ifAbsent: [ nil ]
]

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EComment >> segment: anObject [

	<generated>
	(self attributeAt: #segment ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self segment.
		self attributeAt: #segment put: anObject.
		otherSide eComment: nil ]
	ifNotNil: [ 
		self attributeAt: #segment put: anObject.
		anObject eComment: self ]
]

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EComment >> segmentCommand [
	"Relation named: #segmentCommand type: #FamixEsopeSegmentCommand opposite: #eComment"

	<generated>
	<FMProperty: #segmentCommand type: #FamixEsopeSegmentCommand opposite: #eComment>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #segmentCommand ifAbsent: [ nil ]
]

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EComment >> segmentCommand: anObject [

	<generated>
	(self attributeAt: #segmentCommand ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self segmentCommand.
		self attributeAt: #segmentCommand put: anObject.
		otherSide eComment: nil ]
	ifNotNil: [ 
		self attributeAt: #segmentCommand put: anObject.
		anObject eComment: self ]
]

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EComment >> unknown [
	"Relation named: #unknown type: #FamixEsopeUnknown opposite: #eComment"

	<generated>
	<FMProperty: #unknown type: #FamixEsopeUnknown opposite: #eComment>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #unknown ifAbsent: [ nil ]
]

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EComment >> unknown: anObject [

	<generated>
	(self attributeAt: #unknown ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self unknown.
		self attributeAt: #unknown put: anObject.
		otherSide eComment: nil ]
	ifNotNil: [ 
		self attributeAt: #unknown put: anObject.
		anObject eComment: self ]
]
