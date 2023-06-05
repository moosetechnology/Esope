"
# ACTivate a segment `SEGACT`:


Suppose that the `ptr1` segment has been defined and then deactivated in the fortran subprogram `sp1` which calls `sp2` and that we wish to use `ptr1` in this last subprogram. `sp2` must contain the declarative order of the segment class and moreover it must know the value of the pointer variable instantiating `myseg`. It can be supplied either by `COMMON` or by argument (or by another segment) since it is above all of type Integer. To activate the segment, use the instruction :

```
SEGACT pointer-variable-name
```

This activation is read-only, to be able to modify the values contained in the segment, i.e. to have read/write access, the instruction must be terminated with `*MOD`. The instruction becomes :

```diff
-SEGACT pointer-variable-name
+SEGACT pointer-variable-name*MOD
```

For example, the following sequence could be considered:

```fortran77
c        1         2         3         4         5         6         7
c23456789012345678901234567890123456789012345678901234567890123456789012
		subroutine sp1 (ll,lc,...) 

	   segment myseg
             integer ijk,nomb(ll,lc),jlc 
             real x,xx(n)
             real*8 y,yy(3,mm) 
             character*nbca icha(8,ik),chai
      endsegment 

      pointeur ptr1.myseg  
          . 
          . 
      segini ptr1 

      INTER=PTR1 
      SEGDES PTR1 
      CALL SP2(INTER,... )
      return 
      end 
```   
```fortran77
c        1         2         3         4         5         6         7
c23456789012345678901234567890123456789012345678901234567890123456789012
      subroutine sp2(INTER,....) 

      segment myseg 
             integer ijk,nomb(ll,lc),jlc 
             real x,xx(n) 
             real*8 y,yy(3,mm) 
             character*nbca icha(8,ik),chai 
      endsegment 
      
      pointeur ptr1.myseg   
      .  
      .  
      PTR1=INTER 
      SEGACT PTR1  
      AZ=PTR1.XX(2)  
      SEGDES PTR1 
      .  
      .  
      SEGACT PTR1*MOD  
      PTR1.XX(1)=PTR1.XX(1)*2  
      SEGDES PTR1 
      return 
      end
```

Once a segment is activated, all the variables it contains are accessible in reading mode, just like the other Fortran variables, but it is not possible to modify them. Indeed, it is not normal to want to modify an object which already exists and the memory structures used transitorily in an operator must be created at the beginning of the operator and destroyed at the end of the operator. It is nevertheless possible to modify a segment deactivated then activated by following the name of the pointer to be activated with `*MOD` (`SEGACT PTR1*MOD`).

Remember that `LL`,`LC`, `...` are not variables contained in the segment, the following particular instruction is used to know the dimensions of the tables: `LHJ=PTR1.NOMB(/i)`.

In `LHJ` is the value of the ith dimension of the array `NOMB`. String arrays are treated differently. `PTR1.ICHA(/1)` contains the length of the strings in the array `ICHA`, which is 4 in our example. `PTR1.ICHA(/i)` contains the (i-1)th dimension of the array `ICHA`. 

In a subprogram, it is possible to know the dimension of an array and Esope allows to change its dimension. 

"
Class {
	#name : #FamixEsopeSegact,
	#superclass : #FamixEsopeSegmentCommand,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeSegact class >> annotation [

	<FMClass: #Segact super: #FamixEsopeSegmentCommand>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : #'private - utility' }
FamixEsopeSegact class >> getNameFrom: anEntity [

	^ (((anEntity removePrefix: #eso) trim removePrefix: #segact)
		  trim removePrefix: ',') trim
]
