"
segact p=q, which copies the contents of q into p, without first allocating memory


"
Class {
	#name : 'FASTEsopeSegmov',
	#superclass : 'FASTEsopeEsopeCommand',
	#category : 'FAST-Esope-Entities-Entities',
	#package : 'FAST-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FASTEsopeSegmov class >> annotation [

	<FMClass: #Segmov super: #FASTEsopeEsopeCommand>
	<package: #'FAST-Esope-Entities'>
	<generated>
	^ self
]
