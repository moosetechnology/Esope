"
# Handling of data structures: `SEGMENT`

Few instructions have been added to those of `fortran77`. They are used to manipulate and use the `SEGMENTS`.

As in Fortran, we are led to have a declarative instruction of the SEGMENT and then instructions which act on the SEGMENT. The main thing is to :

    - `segini`: create a segment (or INItialize)
    - `segsup`: Delete(SUPprimer) a segment
    - `segdes`: deactivate (DESactiver) a segment
    - `segact`: ACTivate a segment
    - `segadj`: ADJust the size of a segment.	



"
Class {
	#name : 'FamixEsopeCommand',
	#superclass : 'FamixF77Access',
	#category : 'Famix-Esope-Entities-Entities',
	#package : 'Famix-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixEsopeCommand class >> annotation [

	<FMClass: #Command super: #FamixF77Access>
	<package: #'Famix-Esope-Entities'>
	<generated>
	<abstract>
	^ self
]

{ #category : 'testing' }
FamixEsopeCommand class >> isAbstract [

	<generated>
	^ self == FamixEsopeCommand
]
