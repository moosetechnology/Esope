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

"
Class {
	#name : #FamixEsopeSegment,
	#superclass : #FamixF77Type,
	#traits : 'FamixTWithAttributes',
	#classTraits : 'FamixTWithAttributes classTrait',
	#instVars : [
		'#dimentionalIntegers => FMMany type: #FamixEsopeDimentionalInteger opposite: #segment'
	],
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeSegment class >> annotation [

	<FMClass: #Segment super: #FamixF77Type>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #adding }
FamixEsopeSegment >> addDimentionalInteger: anObject [
	<generated>
	^ self dimentionalIntegers add: anObject
]

{ #category : #accessing }
FamixEsopeSegment >> dimentionalIntegers [
	"Relation named: #dimentionalIntegers type: #FamixEsopeDimentionalInteger opposite: #segment"

	<generated>
	<derived>
	^ dimentionalIntegers
]

{ #category : #accessing }
FamixEsopeSegment >> dimentionalIntegers: anObject [

	<generated>
	dimentionalIntegers value: anObject
]

{ #category : #navigation }
FamixEsopeSegment >> dimentionalIntegersGroup [
	<generated>
	<navigation: 'DimentionalIntegers'>
	^ MooseSpecializedGroup withAll: self dimentionalIntegers asSet
]
