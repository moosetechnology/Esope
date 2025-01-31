"
# Creating and initializing a SEGMENT:
Let's place ourselves again inside a fortran subprogram. 

After having declared the segment by the instruction `SEGMENT...ENDSEGMENT` we have to define a variable which will reference the instanciated structure: the knowledge of this variable gives access to the whole structure. For this purpose a new type of fortran variable is invented: it is the pointer variable whose declaration is : `pointeur poitername.segmentname`.

For example, to allow the instantiation of the class(segment) `myseg` , we declare something like that : 
```fortran77
pointeur ptr1.myseg, ptr2.myseg, ....
```
In this example, `ptr1` and `ptr2` allow to reference a structure of the `myseg` class.

`ptr1` and `ptr2` become a fortran variable of type integer once the tranlation `Esope -> Fortran77` is done.

The creation of a myseg class structure is done by calling `segini` function and specifying the pointer variable used.



"
Class {
	#name : 'FamixEsopePointer',
	#superclass : 'FamixF77Variable',
	#category : 'Famix-Esope-Entities-Entities',
	#package : 'Famix-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixEsopePointer class >> annotation [

	<FMClass: #Pointer super: #FamixF77Variable>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]
