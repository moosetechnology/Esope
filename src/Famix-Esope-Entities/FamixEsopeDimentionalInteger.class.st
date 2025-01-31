"
I am a parameter for arrays in a segment

## Relations
======================

### Parents
| Relation | Origin | Opposite | Type | Comment |
|---|
| `segment` | `FamixEsopeDimentionalInteger` | `dimentionalIntegers` | `FamixEsopeSegment` | |



"
Class {
	#name : 'FamixEsopeDimentionalInteger',
	#superclass : 'FamixF77Variable',
	#instVars : [
		'#segment => FMOne type: #FamixEsopeSegment opposite: #dimentionalIntegers'
	],
	#category : 'Famix-Esope-Entities-Entities',
	#package : 'Famix-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixEsopeDimentionalInteger class >> annotation [

	<FMClass: #DimentionalInteger super: #FamixF77Variable>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FamixEsopeDimentionalInteger >> segment [
	"Relation named: #segment type: #FamixEsopeSegment opposite: #dimentionalIntegers"

	<generated>
	<container>
	^ segment
]

{ #category : 'accessing' }
FamixEsopeDimentionalInteger >> segment: anObject [

	<generated>
	segment := anObject
]

{ #category : 'navigation' }
FamixEsopeDimentionalInteger >> segmentGroup [
	<generated>
	<navigation: 'Segment'>
	^ MooseSpecializedGroup with: self segment
]
