"
# `segdes`: deactivate (DESactiver) a segment.

As a general rule, at the end of a Fortran sub-program or as soon as possible, the segments are deactivated to make the RAM they occupy usable. This is done with the instruction :
`segdes  name_of_pointer_variable`.

Waiting on the working disk will only be done if the memory requests require it and if the disk space allows it. In any case, once a segment is deactivated, it will need to be reactivated before it can be used again.



"
Class {
	#name : #FamixEsopeSegdes,
	#superclass : #FamixEsopeCommand,
	#category : #'Famix-Esope-Entities-Entities'
}

{ #category : #meta }
FamixEsopeSegdes class >> annotation [

	<FMClass: #Segdes super: #FamixEsopeCommand>
	<package: #'Famix-Esope-Entities'>
	<generated>
	^ self
]
