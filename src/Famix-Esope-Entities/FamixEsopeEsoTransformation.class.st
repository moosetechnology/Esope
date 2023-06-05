"
Comment for abstract class EsopeFunction parent of EsoAt, EsoAr, EsoSl
"
Class {
	#name : #FamixEsopeEsoTransformation,
	#superclass : #FamixEsopeEntity,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeEsoTransformation class >> annotation [

	<FMClass: #EsoTransformation super: #FamixEsopeEntity>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixEsopeEsoTransformation >> eEntity [
	"Relation named: #eEntity type: #FamixFortran77EEntity opposite: #esoTransformation"

	<generated>
	<FMProperty: #eEntity type: #FamixFortran77EEntity opposite: #esoTransformation>
	^ self attributeAt: #eEntity ifAbsent: [ nil ]
]

{ #category : #accessing }
FamixEsopeEsoTransformation >> eEntity: anObject [

	<generated>
	(self attributeAt: #eEntity ifAbsentPut: [nil]) == anObject ifTrue: [ ^ anObject ].
	anObject ifNil: [ | otherSide |
		otherSide :=  self eEntity.
		self attributeAt: #eEntity put: anObject.
		otherSide esoTransformation: nil ]
	ifNotNil: [ 
		self attributeAt: #eEntity put: anObject.
		anObject esoTransformation: self ]
]
