Class {
	#name : #FortranImporterTempFile,
	#superclass : #FileReference,
	#instVars : [
		'localName'
	],
	#category : #'EsopeImporter-Importer'
}

{ #category : #'instance creation' }
FortranImporterTempFile class >> from: aFileReference [

	^self fileSystem: aFileReference fileSystem path: aFileReference path
]

{ #category : #accessing }
FortranImporterTempFile >> localName [

	^ localName
]

{ #category : #accessing }
FortranImporterTempFile >> localName: anObject [

	localName := anObject
]
