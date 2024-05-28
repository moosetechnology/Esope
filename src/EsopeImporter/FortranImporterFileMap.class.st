Class {
	#name : #FortranImporterFileMap,
	#superclass : #Object,
	#instVars : [
		'includedFiles',
		'esopeFiles',
		'fortranFiles'
	],
	#category : #'EsopeImporter-Importer'
}

{ #category : #initialization }
FortranImporterFileMap >> initialize [ 

	includedFiles := OrderedCollection new.
	esopeFiles := OrderedCollection new.
	fortranFiles := OrderedCollection new
]
