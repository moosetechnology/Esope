"
# Handling of data structures: `SEGMENT`

Few instructions have been added to those of `fortran77`. They are used to manipulate and use the `SEGMENTS`.

As in Fortran, we are led to have a declarative instruction of the SEGMENT and then instructions which act on the SEGMENT. The main thing is to :

    - `segini`: create a segment (or INItialize)
    - `segsup`: Delete(SUPprimer) a segment
    - `segdes`: deactivate (DESactiver) a segment
    - `segact`: ACTivate a segment
    - `segadj`: ADJust the size of a segment.	


## Properties
======================

| Name | Type | Default value | Comment |
|---|
| `commandName` | `String` | nil | Carrying the actual name of the esope command. 		 		Instead of using a property to distinguish esope's commands, 		it can be a better solution to use inheritance.|

"
Class {
	#name : 'FamixEsopeCommand',
	#superclass : 'FamixF77Access',
	#instVars : [
		'#commandName => FMProperty'
	],
	#category : 'Famix-Esope-Entities-Entities',
	#package : 'Famix-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FamixEsopeCommand class >> annotation [

	<FMClass: #Command super: #FamixF77Access>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'accessing' }
FamixEsopeCommand >> commandName [

	<FMProperty: #commandName type: #String>
	<generated>
	<FMComment: 'Carrying the actual name of the esope command.
		
		Instead of using a property to distinguish esope''s commands,
		it can be a better solution to use inheritance.'>
	^ commandName
]

{ #category : 'accessing' }
FamixEsopeCommand >> commandName: anObject [
	<generated>
	commandName := anObject
]
