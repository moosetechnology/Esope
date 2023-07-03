"
# Attribute
A `segment` entity is a grouping of Fortran variables defined by the programmer.
This such of variable called `attribute`

In the follow example:
```fortran77
c        1         2         3         4         5         6         7
c23456789012345678901234567890123456789012345678901234567890123456789012
c     a example of segment definition
      segment myseg
            integer scalar, array(size), matrix(row, col)
            real x, xx(n)
            real*8 Y, YY(3, MM)
            character*nbca icha(8, ik), chai 
      end segment
```
the segment `myseg` have the following attributes: `scalar`, `array`, `matrix`, `x`, `xx`, `Y`,  `YY`,  `icha`, `chai`, 
	

"
Class {
	#name : #FamixEsopeAttribute,
	#superclass : #FamixFortran77Variable,
	#traits : 'FamixTAttribute',
	#classTraits : 'FamixTAttribute classTrait',
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeAttribute class >> annotation [

	<FMClass: #Attribute super: #FamixFortran77Variable>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]
