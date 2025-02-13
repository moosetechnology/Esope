Extension { #name : 'FamixF77Access' }

{ #category : '*Famix-Esope-Entities-accessing' }
FamixF77Access >> segment [
	"Relation named: #segment type: #FamixEsopeSegment opposite: #accesses"

	<generated>
	<container>
	<FMProperty: #segment type: #FamixEsopeSegment opposite: #accesses>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #segment ifAbsent: [ nil ]
]

{ #category : '*Famix-Esope-Entities-accessing' }
FamixF77Access >> segment: anObject [

	<generated>
	self attributeAt: #segment put: (FMMultivalueLink on: self update: #accesses from: self segment to: anObject).
]
