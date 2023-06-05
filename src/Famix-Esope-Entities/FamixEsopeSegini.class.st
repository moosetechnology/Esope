"
# `segini`: creation of segment (INItialize)
The creation of a myseg class structure is done by calling `segini` function and specifying the pointer variable used thanks to this esope instruction: `segini ptr1`.

In our example, this gives:
```fortran77
c        1         2         3         4         5         6         7
c23456789012345678901234567890123456789012345678901234567890123456789012
      subroutine sp1 (......) 

      segment myseg
            integer ijk,nomb(ll,lc),jlc 
            real x,xx(n) 
            real*8 y,yy(3,mm) 
            character*nbca icha(8,ik),chai
      endsegment

      pointeur ptr1.myseg, ptr2.myseg
      . 
      .      

      SEGINI ptr1 

      .    
      . 
      return 
      end
```

Of course, the dimensioning variables of the segment must be defined before the SEGINI instruction (otherwise the result depends on the compiler!). We could have made the instruction set as follows:

```fortran77
c        1         2         3         4         5         6         7
c23456789012345678901234567890123456789012345678901234567890123456789012
      subroutine subroutine sp1 (LL,LC......)

      segment myseg
            integer ijk,nomb(ll,lc),jlc 
            real x,xx(n) 
            real*8 y,yy(3,mm) 
            character*nbca icha(8,ik),chai
      endsegment

      pointeur ptr1.myseg, ptr2.myseg
      . 
      .      
      N=5 
      MM=3 
      IK=12 
      NBCA=4
		
      SEGINI ptr1

      PTR1.XX(3)=... 
      PTR1.ICHA(5,2)='BIEN'
      .    
      . 
      return
      end
```

In the last example, the array YY is sized to 3 rows and 3 columns, while ICHA is an array of 4-character strings that has 8 rows and 12 columns.

Once the SEGINI instruction has been executed and as long as the subroutine remains, all the elements of the SEGMENT can be considered by the programmer as normal fortran variables. To reach them, it is necessary to remember that they belong to the structure referenced by the pointer variable PTR1.

Remarks :

    - on creation, all the variables contained in the segment are set to zero.
    - It is possible to create a segment by copying another one (see [link here](link)).

ESOPE offers the possibility to free the memory space occupied by the segment. The segment can either be deleted or deactivated.


"
Class {
	#name : #FamixEsopeSegini,
	#superclass : #FamixEsopeSegmentCommand,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeSegini class >> annotation [

	<FMClass: #Segini super: #FamixEsopeSegmentCommand>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #'instance creation' }
FamixEsopeSegini class >> getNameFrom: anEntity [

	^ (((anEntity removePrefix: #eso) trim removePrefix: #segini)
		  trim removePrefix: ',') trim
]
