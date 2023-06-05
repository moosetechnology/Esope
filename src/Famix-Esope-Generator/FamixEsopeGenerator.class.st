Class {
	#name : #FamixEsopeGenerator,
	#superclass : #FamixMetamodelGenerator,
	#instVars : [
		'segment',
		'segini',
		'segsup',
		'segdes',
		'segact',
		'segadj',
		'type',
		'attribute',
		'accesPointeur',
		'accessToDimensions',
		'accessToPointer',
		'implicitPointer',
		'attributeAssignment',
		'esoat',
		'esoar',
		'esosl',
		'pointer',
		'fortranVariable',
		'unknown',
		'parameter',
		'segmentCommand',
		'esoTransformation',
		'eComment',
		'eEntity'
	],
	#category : #'Famix-Esope-Generator'
}

{ #category : #generating }
FamixEsopeGenerator class >> packageName [
	^#'Famix-Esope-Entities'
]

{ #category : #generating }
FamixEsopeGenerator class >> prefix [
	^#FamixEsope
]

{ #category : #generating }
FamixEsopeGenerator class >> submetamodels [
	^{ FamixFortran77Generator }
]

{ #category : #comment }
FamixEsopeGenerator >> commentAccesPointer [
	^'Accessing a pointer `Pointeur` pointing to a segment'
]

{ #category : #comment }
FamixEsopeGenerator >> commentAccessToDimensions [
	^ 'Les accès aux dimensions de la forme `abc.def(/1)`'
]

{ #category : #comment }
FamixEsopeGenerator >> commentAttribute [
	^ '# Attribute
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
	
'
]

{ #category : #comment }
FamixEsopeGenerator >> commentAttributeAssignment [
	^ 'Les instructions d’affectation de champs pour les instructions pointées de la
forme `abc.def=variable/value`'
]

{ #category : #comment }
FamixEsopeGenerator >> commentEsoTransformation [
	^ 'Comment for abstract class EsopeFunction parent of EsoAt, EsoAr, EsoSl'
]

{ #category : #comment }
FamixEsopeGenerator >> commentEsoar [
	^''
]

{ #category : #comment }
FamixEsopeGenerator >> commentEsoat [
	^''
]

{ #category : #comment }
FamixEsopeGenerator >> commentEsosl [
	^''
]

{ #category : #comment }
FamixEsopeGenerator >> commentFortranVariable [

	^ 'comment for name of variable pointer'
]

{ #category : #comment }
FamixEsopeGenerator >> commentImplicitPointer [
	^ ''
]

{ #category : #comment }
FamixEsopeGenerator >> commentParameter [
	^''
]

{ #category : #comment }
FamixEsopeGenerator >> commentPointer [

	^ '# Creating and initializing a SEGMENT:
Let''s place ourselves again inside a fortran subprogram. 

After having declared the segment by the instruction `SEGMENT...ENDSEGMENT` we have to define a variable which will reference the instanciated structure: the knowledge of this variable gives access to the whole structure. For this purpose a new type of fortran variable is invented: it is the pointer variable whose declaration is : `pointeur poitername.segmentname`.

For example, to allow the instantiation of the class(segment) `myseg` , we declare something like that : 
```fortran77
pointeur ptr1.myseg, ptr2.myseg, ....
```
In this example, `ptr1` and `ptr2` allow to reference a structure of the `myseg` class.

`ptr1` and `ptr2` become a fortran variable of type integer once the tranlation `Esope -> Fortran77` is done.

The creation of a myseg class structure is done by calling `segini` function and specifying the pointer variable used.
'
]

{ #category : #comment }
FamixEsopeGenerator >> commentSegact [

	^ '# ACTivate a segment `SEGACT`:


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
'
]

{ #category : #comment }
FamixEsopeGenerator >> commentSegadj [

	^ '# ADJust a segment `SEGADJ`
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

'
]

{ #category : #comment }
FamixEsopeGenerator >> commentSegdes [

	^ '# `segdes`: deactivate (DESactiver) a segment.

As a general rule, at the end of a Fortran sub-program or as soon as possible, the segments are deactivated to make the RAM they occupy usable. This is done with the instruction :
`segdes  name_of_pointer_variable`.

Waiting on the working disk will only be done if the memory requests require it and if the disk space allows it. In any case, once a segment is deactivated, it will need to be reactivated before it can be used again.
'
]

{ #category : #comment }
FamixEsopeGenerator >> commentSegini [

	^ '# `segini`: creation of segment (INItialize)
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
      PTR1.ICHA(5,2)=''BIEN''
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

'
]

{ #category : #comment }
FamixEsopeGenerator >> commentSegment [

	^ ' # Segment:

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
'
]

{ #category : #comment }
FamixEsopeGenerator >> commentSegmentCommand [

	^ '# Handling of data structures: `SEGMENT`

Few instructions have been added to those of `fortran77`. They are used to manipulate and use the `SEGMENTS`.

As in Fortran, we are led to have a declarative instruction of the SEGMENT and then instructions which act on the SEGMENT. The main thing is to :

    - `segini`: create a segment (or INItialize)
    - `segsup`: Delete(SUPprimer) a segment
    - `segdes`: deactivate (DESactiver) a segment
    - `segact`: ACTivate a segment
    - `segadj`: ADJust the size of a segment.	
'
]

{ #category : #comment }
FamixEsopeGenerator >> commentSegsup [

	^ '# `segsup`: Delete(SUPprimer) of a segment
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
      ptr1.icha(5,2)=''BIEN''
      .    
      .
      SEGSUP PTR1
      .
      return
      end 

```

'
]

{ #category : #comment }
FamixEsopeGenerator >> commentType [
	^ 'comment for type'
]

{ #category : #comment }
FamixEsopeGenerator >> commentUnknown [

	^ 'This entity do not exist or wrongly processed'
]

{ #category : #definition }
FamixEsopeGenerator >> defineClasses [

	super defineClasses.

	attribute := builder
		newClassNamed: #Attribute
		comment: self commentAttribute.

	esoTransformation := builder
		newClassNamed: #EsoTransformation
		comment: self commentEsoTransformation.

	esoar := builder
		newClassNamed: #EsoAr
		comment: self commentEsoar.
	esoat := builder
		newClassNamed: #EsoAt
		comment: self commentEsoat.
	esosl := builder
		newClassNamed: #EsoSl
		comment: self commentEsosl.

	eComment := self
		remoteEntity: #EComment
		withPrefix: #FamixFortran77.

	fortranVariable := builder
		newClassNamed: #FortranVariable
		comment: self commentFortranVariable.

	eEntity := self
		remoteEntity: #EEntity
		withPrefix: #FamixFortran77.

	implicitPointer := builder
		newClassNamed: #ImplicitPointer
		comment: self commentImplicitPointer.
	
	parameter := builder
		newClassNamed: #Parameter
		comment: self commentParameter.

	pointer := builder
		newClassNamed: #Pointer
		comment: self commentPointer.

	segact := builder
		newClassNamed: #Segact
		comment: self commentSegact.
	segadj := builder
		newClassNamed: #Segadj
		comment: self commentSegadj.
	segdes := builder
		newClassNamed: #Segdes
		comment: self commentSegdes.
	segini := builder
		newClassNamed: #Segini
		comment: self commentSegini.
	segsup := builder
		newClassNamed: #Segsup
		comment: self commentSegsup.

	segment := builder
		newClassNamed: #Segment
		comment: self commentSegment.

	segmentCommand := builder
		newClassNamed: #SegmentCommand
		comment: self commentSegmentCommand.

	unknown := builder
		newClassNamed: #Unknown
		comment: self commentUnknown
]

{ #category : #definition }
FamixEsopeGenerator >> defineHierarchy [

	super defineHierarchy.

	attribute --|> #TAttribute.
	attribute --|> fortranVariable.

	esoar --|> esoTransformation.
	esoat --|> esoTransformation.
	esosl --|> esoTransformation.
	
"	esoTransformation --|> #TFunction."
	
	implicitPointer --|> fortranVariable.
	
	"pointer --|> #TType."
	pointer --|> fortranVariable.

	segact --|> segmentCommand.

	segadj --|> segmentCommand.

	segdes --|> segmentCommand.

	segini --|> segmentCommand.

	segsup --|> segmentCommand.

	segment --|> #TType.

	segmentCommand --|> #TNamedEntity.
	
	fortranVariable --|> #TStructuralEntity.
]

{ #category : #definition }
FamixEsopeGenerator >> defineProperties [ 
	super defineProperties
]

{ #category : #definition }
FamixEsopeGenerator >> defineRelations [

	super defineRelations.

	eComment - unknown.

	eComment - pointer.
	eComment - segment.
	eComment - segmentCommand.

	esoTransformation - eEntity.

	segment -* pointer.
	segment <>-* attribute.
	segment <>-* parameter.
	

	segmentCommand - pointer
]

{ #category : #definition }
FamixEsopeGenerator >> newBuilder [
	^super newBuilder
		  withFileImport;
		  yourself
]
