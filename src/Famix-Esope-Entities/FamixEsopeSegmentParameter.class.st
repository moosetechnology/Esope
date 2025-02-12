"
I am a parameter for arrays in a segment

## Relations
======================

### Parents
| Relation | Origin | Opposite | Type | Comment |
|---|
| `segment` | `FamixEsopeSegmentParameter` | `segmentParameters` | `FamixEsopeSegment` | |



"
Class {
	#name : 'FamixEsopeSegmentParameter',
	#superclass : 'FamixF77Variable',
	#instVars : [
		'#segment => FMOne type: #FamixEsopeSegment opposite: #segmentParameters'
	],
	#category : 'Famix-Esope-Entities-Entities',
	#package : 'Famix-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixEsopeSegmentParameter class >> annotation [

	<FMClass: #SegmentParameter super: #FamixF77Variable>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FamixEsopeSegmentParameter >> segment [
	"Relation named: #segment type: #FamixEsopeSegment opposite: #segmentParameters"

	<generated>
	<container>
	^ segment
]

{ #category : 'accessing' }
FamixEsopeSegmentParameter >> segment: anObject [

	<generated>
	segment := anObject
]

{ #category : 'navigation' }
FamixEsopeSegmentParameter >> segmentGroup [
	<generated>
	<navigation: 'Segment'>
	^ MooseSpecializedGroup with: self segment
]
