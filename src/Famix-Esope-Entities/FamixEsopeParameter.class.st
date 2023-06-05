Class {
	#name : #FamixEsopeParameter,
	#superclass : #FamixEsopeEntity,
	#instVars : [
		'#segment => FMOne type: #FamixEsopeSegment opposite: #parameters'
	],
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeParameter class >> annotation [

	<FMClass: #Parameter super: #FamixEsopeEntity>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #accessing }
FamixEsopeParameter >> segment [
	"Relation named: #segment type: #FamixEsopeSegment opposite: #parameters"

	<generated>
	<container>
	^ segment
]

{ #category : #accessing }
FamixEsopeParameter >> segment: anObject [

	<generated>
	segment := anObject
]

{ #category : #navigation }
FamixEsopeParameter >> segmentGroup [
	<generated>
	<navigation: 'Segment'>
	^ MooseSpecializedGroup with: self segment
]
