"
Famix Esope Generator, submodule of Famix-Fortran77

```plantuml
@startuml
hide empty members

package F77 {

class Access #edf {}
abstract class Type #edf {}
class Variable #edf {}
abstract class TypeIntrinsic {}
abstract class Numeric {}
class Character {}
class Integer #edf {}
class Real {}
class Complex {}
class Logical {}

}

package Esope {

abstract class Command {
 name: String
}
class Segment {}
class Attribute {}
class ImplicitPointer {}
class Segact {}
class Segadj {}
class Segdes {}
class Segini {}
class Segsup {}
class Pointeur {}

}

Segment *-right- ""*"" Attribute
Segment -up-|> Type

Variable -left-> Type : declaredType

Attribute -up-|> Variable
ImplicitPointer -left-|> Variable

Command -up-|> Access

Access --> Variable: var

together {
Segact -up-|> Command
Segadj -up-|> Command
Segdes -up-|> Command
Segini -up-|> Command
Segsup -up-|> Command
}

TypeIntrinsic --|> Type
Numeric --|> TypeIntrinsic
Character --|> TypeIntrinsic
Logical --|> TypeIntrinsic

Integer --|> Numeric
Real --|> Numeric
Complex --|> Numeric

Pointeur --|> Integer

@enduml
```
"
Class {
	#name : 'FamixEsopeGenerator',
	#superclass : 'FamixMetamodelGenerator',
	#instVars : [
		'attribute',
		'implicitPointer',
		'segment',
		'command',
		'access',
		'variable',
		'type',
		'pointer',
		'intrinsicRoutine',
		'intrinsicProcedure',
		'segmentParameter'
	],
	#category : 'Famix-Esope-Generator',
	#package : 'Famix-Esope-Generator'
}

{ #category : 'accessing' }
FamixEsopeGenerator class >> packageName [

	^ #'Famix-Esope-Entities'
]

{ #category : 'accessing' }
FamixEsopeGenerator class >> prefix [

	^ #FamixEsope
]

{ #category : 'accessing' }
FamixEsopeGenerator class >> submetamodels [

	^ {
		  FamixFortran77Generator.
		  FamixFortranUDTGenerator }
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentAccesPointer [
	^'Accessing a pointer `Pointeur` pointing to a segment'
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentAccessToDimensions [
	^ 'Les accès aux dimensions de la forme `abc.def(/1)`'
]

{ #category : 'comment' }
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

{ #category : 'comment' }
FamixEsopeGenerator >> commentAttributeAssignment [
	^ 'Les instructions d’affectation de champs pour les instructions pointées de la
forme `abc.def=variable/value`'
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentCommand [

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

{ #category : 'comment' }
FamixEsopeGenerator >> commentEAccess [
	^ 'Comment for abstract class EsopeFunction parent of EsoAt, EsoAr, EsoSl'
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentEsoar [
	^''
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentEsoat [
	^''
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentEsopeType [

	^ 'I am a fortran type + esope type (pointeur)'
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentEsosl [
	^''
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentFVariable [

	^ 'comment for name of variable pointer'
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentImplicitPointer [

	^ 'Im an implicit pointer, Im created when a segment is defined.
	'
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentParameter [
	^''
]

{ #category : 'comment' }
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

{ #category : 'comment' }
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

{ #category : 'comment' }
FamixEsopeGenerator >> commentType [

	^ 'comment for type'
]

{ #category : 'comment' }
FamixEsopeGenerator >> commentUnknown [

	^ 'This entity do not exist or wrongly processed'
]

{ #category : 'definition' }
FamixEsopeGenerator >> defineClasses [

	super defineClasses.

	access := self remoteEntity: #Access withPrefix: #FamixF77.

	attribute := self remoteEntity: #Attribute withPrefix: #FamixFortran.

	command := self
		           newClassNamed: #Command
		           comment: self commentCommand.

	segmentParameter := self
		                      newClassNamed: #SegmentParameter
		                      comment: self segmentParameterComment.

	implicitPointer := self
		                   newClassNamed: #ImplicitPointer
		                   comment: self commentImplicitPointer.
	
	intrinsicProcedure := self newClassNamed: #IntrinsicProcedure comment: 'Procedure defined in esope itself'.
	
	intrinsicRoutine := self remoteEntity: #IntrinsicRoutine withPrefix: #FamixF77.
		
	pointer := self newClassNamed: #Pointer comment: self commentPointer.

	segment := self
		           newClassNamed: #Segment
		           comment: self commentSegment.

	type := self remoteEntity: #Type withPrefix: #FamixF77.

	variable := self remoteEntity: #Variable withPrefix: #FamixF77
]

{ #category : 'definition' }
FamixEsopeGenerator >> defineHierarchy [

	super defineHierarchy.

	attribute --|> #TAttribute.
	attribute --|> variable.

	command --|> access.

	implicitPointer --|> variable.
	
	intrinsicProcedure --|> intrinsicRoutine.
	
	pointer --|> variable.

	segment --|> type.
	segment --|> #TWithAttributes.

	segmentParameter --|> variable
]

{ #category : 'definition' }
FamixEsopeGenerator >> defineProperties [

	super defineProperties.

	(command property: #commandName type: #String) comment:
		'Carrying the actual name of the esope command.
		
		Instead of using a property to distinguish esope''s commands,
		it can be a better solution to use inheritance.'
]

{ #category : 'definition' }
FamixEsopeGenerator >> defineRelations [

	super defineRelations.

	segment <>-* segmentParameter.
	segment <>-* access
]

{ #category : 'definition' }
FamixEsopeGenerator >> newBuilder [
	^super newBuilder
		  withFileImport;
		  yourself
]

{ #category : 'comment' }
FamixEsopeGenerator >> segmentParameterComment [

	^ 'I am a parameter for arrays in a segment'
]
