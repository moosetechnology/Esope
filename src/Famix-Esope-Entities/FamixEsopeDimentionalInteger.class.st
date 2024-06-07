"
Im an 'Entier Dimentionnel'
"
Class {
	#name : #FamixEsopeDimentionalInteger,
	#superclass : #AnObsoleteFamixF77Variable,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeDimentionalInteger class >> annotation [

	<FMClass: #DimentionalInteger super: #FamixF77Variable>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixEsopeDimentionalInteger >> segment [
	"Relation named: #segment type: #FamixEsopeSegment opposite: #dimentionalIntegers"

	<generated>
	<container>
	^ segment
]

{ #category : #accessing }
FamixEsopeDimentionalInteger >> segment: anObject [

	<generated>
	segment := anObject
]

{ #category : #navigation }
FamixEsopeDimentionalInteger >> segmentGroup [
	<generated>
	<navigation: 'Segment'>
	^ MooseSpecializedGroup with: self segment
]
