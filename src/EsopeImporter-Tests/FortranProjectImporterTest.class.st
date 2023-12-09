"
A FortranProjectImporterTest is a test class for testing the behavior of FortranProjectImporter
"
Class {
	#name : #FortranProjectImporterTest,
	#superclass : #TestCase,
	#instVars : [
		'importer',
		'fileSystem'
	],
	#category : #'EsopeImporter-Tests-Importer'
}

{ #category : #running }
FortranProjectImporterTest >> setUp [
	super setUp.

	importer := FortranProjectImporter new.
	fileSystem := FileSystem memory

]

{ #category : #tests }
FortranProjectImporterTest >> testGetIncludedFile [

	self assert: (importer getIncludedFile: '#include  "blah.inc"') equals: 'blah.inc'
]

{ #category : #tests }
FortranProjectImporterTest >> testSearchIncludedAmong [

	| file1 |
	file1 := (fileSystem / 'included.h') createFile.

	self assert: (importer searchIncluded: 'included.h' among: { fileSystem } ) equals: file1.
]

{ #category : #tests }
FortranProjectImporterTest >> testSearchIncludedAmongNoExtension [

	| file1 |
	file1 := (fileSystem / 'included') createFile.

	self assert: (importer searchIncluded: 'included' among: { fileSystem } ) equals: file1.
]

{ #category : #tests }
FortranProjectImporterTest >> testSearchIncludedAmongNotFound [

	| file1 |
	file1 := (fileSystem / 'excluded.h') createFile.

	self assert: (importer searchIncluded: 'included.h' among: { fileSystem } ) equals: nil.
]

{ #category : #tests }
FortranProjectImporterTest >> testSearchIncludedAmongWithPath [

	| srcFile resultFile |
	(fileSystem  / 'inc') createDirectory.
	srcFile := (fileSystem / 'inc' / 'included.h').
	srcFile writeStreamDo: [:st | st << 'a line' ; cr].

	importer fakeEsopeProgramUnit: srcFile to: (fileSystem / 'tmpEsope').

	resultFile := fileSystem / 'tmpEsope' / 'tmpIncludeDirectory' / 'inc' / 'included.h.E'.

	self assert: resultFile exists.
	self assert: resultFile contents equals: '      subroutine __$__
a line
      end
'
]

{ #category : #tests }
FortranProjectImporterTest >> testUnquoteIncludedFile [

	self assert: (importer unquoteIncludedFile: 'blah') equals: 'blah'.
	self assert: (importer unquoteIncludedFile: 'blah.f') equals: 'blah.f'.
	self assert: (importer unquoteIncludedFile: '"blah.inc"') equals: 'blah.inc'.
	self assert: (importer unquoteIncludedFile: '<lib/blah.h>') equals: 'lib/blah.h'
]
