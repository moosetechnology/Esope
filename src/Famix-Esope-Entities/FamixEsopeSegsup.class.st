"
# `segsup`: Delete(SUPprimer) of a segment
The order of declaration of the segment being in the head of the subprogram, one can at any time execute the SEGSUP instruction whose syntax is : `segsup name_of_pointer_variable`.

In our example, suppose that the data structure MYSEG instantiated by PTR1 is only used within the subroutine SP1, then the segment must be deleted before leaving the subroutine.

```fortran77
c        1         2         3         4         5         6         7
c23456789012345678901234567890123456789012345678901234567890123456789012
      subroutine subroutine sp1 (ll,lc, ...)

      segment myseg
            integer ijk,nomb(ll,lc),jlc 
            real x,xx(n) 
            real*8 y,yy(3,mm) 
            character*nbca icha(8,ik),chai
      endsegment

      pointeur ptr1.myseg, ptr2.myseg
      . 
      .      
      n=5 
      mm=3 
      ik=12 
      nbca=4
		
      segini ptr1

      ptr1.xx(3)=... 
      ptr1.icha(5,2)='BIEN'
      .    
      .
      SEGSUP PTR1
      .
      return
      end 

```


"
Class {
	#name : #FamixEsopeSegsup,
	#superclass : #FamixEsopeSegmentCommand,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeSegsup class >> annotation [

	<FMClass: #Segsup super: #FamixEsopeSegmentCommand>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #'instance creation' }
FamixEsopeSegsup class >> getNameFrom: anEntity [

	^ (((anEntity removePrefix: #eso) trim removePrefix: #segsup)
		  trim removePrefix: ',') trim
]
