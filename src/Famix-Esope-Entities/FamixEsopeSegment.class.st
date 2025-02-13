"
# Segment:

Before the first executable instruction of a fortran subprogram, the SEGMENTS that will be used must be declared.

A SEGMENT can contain as many fortran variables as necessary and of all allowed fortran types. The declaration is done as follows:
```fortran77
c        1         2         3         4         5         6         7
c23456789012345678901234567890123456789012345678901234567890123456789012
c     a example of segment definition
      segment myseg
            integer scalar, array(size), matrix(row, col)
            real x, yy(n)
            real*8 Y, YY(3, MM)
            character*nbca icha(8, ik), chai 
      end segment
```

The statement is included between the words `SEGMENT` and `ENDSEGMENT`. Remember that we are in `Fortran77` and that these instructions must be typed after the seventh column.

`MYSEG` is the name of the class of the structure materialized by this segment. A structure belonging to the class `MYSEG` will contain an integer `scalar`, an array of integers `array`, a matrix `row x col` of integer, ... and finally a string of NBCA characters called `CHAI`.


## Relations
======================

### Children
| Relation | Origin | Opposite | Type | Comment |
|---|
| `accesses` | `FamixEsopeSegment` | `segment` | `FamixF77Access` | |
| `segmentParameters` | `FamixEsopeSegment` | `segment` | `FamixEsopeSegmentParameter` | |



"
Class {
	#name : 'FamixEsopeSegment',
	#superclass : 'FamixFortranUserDefinedType',
	#instVars : [
		'#segmentParameters => FMMany type: #FamixEsopeSegmentParameter opposite: #segment'
	],
	#category : 'Famix-Esope-Entities-Entities',
	#package : 'Famix-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixEsopeSegment class >> annotation [

	<FMClass: #Segment super: #FamixFortranUserDefinedType>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FamixEsopeSegment >> accesses [
	"Relation named: #accesses type: #FamixF77Access opposite: #segment"

	<generated>
	<derived>
	<FMProperty: #accesses type: #FamixF77Access opposite: #segment>
	<package: #'Carrefour-Esope-Model'>
	^ self attributeAt: #accesses ifAbsentPut: [ FMMultivalueLink on: self opposite: #segment: ]
]

{ #category : 'accessing' }
FamixEsopeSegment >> accesses: anObject [

	<generated>
	self accesses value: anObject
]

{ #category : 'navigation' }
FamixEsopeSegment >> accessesGroup [
	<generated>
	<navigation: 'Accesses'>
	^ MooseSpecializedGroup withAll: self accesses asSet
]

{ #category : 'adding' }
FamixEsopeSegment >> addAccess: anObject [
	<generated>
	^ self accesses add: anObject
]

{ #category : 'adding' }
FamixEsopeSegment >> addSegmentParameter: anObject [
	<generated>
	^ self segmentParameters add: anObject
]

{ #category : 'accessing' }
FamixEsopeSegment >> segmentParameters [
	"Relation named: #segmentParameters type: #FamixEsopeSegmentParameter opposite: #segment"

	<generated>
	<derived>
	^ segmentParameters
]

{ #category : 'accessing' }
FamixEsopeSegment >> segmentParameters: anObject [

	<generated>
	segmentParameters value: anObject
]

{ #category : 'navigation' }
FamixEsopeSegment >> segmentParametersGroup [
	<generated>
	<navigation: 'SegmentParameters'>
	^ MooseSpecializedGroup withAll: self segmentParameters asSet
]
