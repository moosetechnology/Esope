"
# ADJust a segment `SEGADJ`
The instruction, `SEGADJ pointer-variable-name`, is used as `SEGINI`, i.e, all dimensional variables of the segment arrays must be defined before the call. 

ESOPE, depending on the request, will truncate or enlarge the array, keeping the values of the variables that exist before and after the instruction.

For example:
```fortran77
c        1         2         3         4         5         6         7
c23456789012345678901234567890123456789012345678901234567890123456789012
      subroutine sp1 (ll,lc,n,mm,inter,...) 

      segment myseg 
             integer ijk,nomb(ll,lc),jlc 
             real x,xx(n) 
             real*8 y,yy(3,mm) 
             character*nbca icha(8,ik),chai 
      endsegment 

      pointeur mons1.monseg 
          . 
          . 
      MONS1=INTER 
      N=36 
      IK=18 
      SEGADJ MONS1
          . 
          . 
       
```


"
Class {
	#name : #FamixEsopeSegadj,
	#superclass : #FamixEsopeSegmentCommand,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeSegadj class >> annotation [

	<FMClass: #Segadj super: #FamixEsopeSegmentCommand>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #'instance creation' }
FamixEsopeSegadj class >> getNameFrom: anEntity [

	^ (((anEntity removePrefix: #eso) trim removePrefix: #segadj)
		  trim removePrefix: ',') trim
]
