Extension { #name : #FamixFortran77EEntity }

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EEntity >> esoTransformation [
	"Relation named: #esoTransformation type: #FamixEsopeEsoTransformation opposite: #eEntity"

	<generated>
	<derived>
	<FMProperty: #esoTransformation type: #FamixEsopeEsoTransformation opposite: #eEntity>
	<package: #'Famix-Esope-Entities'>
	^ self attributeAt: #esoTransformation ifAbsent: [ nil ]
]

{ #category : #'*Famix-Esope-Entities-accessing' }
FamixFortran77EEntity >> esoTransformation: anObject [

	<generated>
	(self attributeAt: #esoTransformation ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self esoTransformation.
		self attributeAt: #esoTransformation put: anObject.
		otherSide eEntity: nil ]
	ifNotNil: [ 
		self attributeAt: #esoTransformation put: anObject.
		anObject eEntity: self ]
]
