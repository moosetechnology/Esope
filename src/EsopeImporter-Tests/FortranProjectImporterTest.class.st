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

{ #category : #'tests - helper' }
FortranProjectImporterTest >> prepareWorkspace [

	| f1 f2 |
	fileSystem createDirectory: '/project'.
	fileSystem createDirectory: '/project/inc1'.
	fileSystem createDirectory: '/project/inc2'.
	fileSystem createDirectory: '/project/src'.

	(fileSystem / '/project/inc1/f1.inc') createFile.
	(fileSystem / '/project/inc1/f2.seg') createFile.
	(fileSystem / '/project/inc2/f3.obj') createFile.
	(fileSystem / '/project/inc2/f1.inc') createFile.
	(fileSystem / '/project/inc2/f4.h') createFile.

	f1 := (fileSystem / 'project/src/f1.fc') createFile.
	f2 := (fileSystem / 'project/src/f2.ec') createFile.
	(fileSystem / 'project/src/f3.f') createFile.

	f1 writeStreamDo: [ :st |
		st
			<< '#include "f1.inc"'; cr;
			<< '#include "f3.obj"'; cr
	].

	f2 writeStreamDo: [ :st |
		st
			<< '#include "f2.seg"'; cr;
			<< '#include "f1.inc"'; cr
	].

	importer srcFolders: { fileSystem / '/project/src' }.
	importer includeFolders: { 
		fileSystem / 'project/inc1'.
		fileSystem / 'project/inc2' 
	}
]

{ #category : #running }
FortranProjectImporterTest >> setUp [
	super setUp.

	importer := FortranProjectImporter new.
	importer errorHandler: FortranErrorManager new.
	fileSystem := FileSystem memory

]

{ #category : #tests }
FortranProjectImporterTest >> testCollectIncludedEsopeFiles [

	[ |expected|
		expected := #( 'f2.seg' 'f1.inc' 'f3.obj' ).
		self prepareWorkspace.
		importer collectIncludedFiles.
		self
			assertCollection: importer includedFiles
			includesAll: expected.
		self assert: importer includedFiles size equals: expected size.
	] ensure: [
		(fileSystem / 'project') ensureDeleteAll
	]
]

{ #category : #tests }
FortranProjectImporterTest >> testCollectIncludedFortranFiles [

	[
		self prepareWorkspace.
		importer collectIncludedFiles.
		self
			assertCollection: importer includedFiles
			includesAll: #( 'f1.inc' 'f3.obj' ).
		self assert: importer includedFiles size equals: 3.
	] ensure: [
		(fileSystem / 'project') ensureDeleteAll 
	]
]

{ #category : #tests }
FortranProjectImporterTest >> testGetIncludedFile [

	self assert: (importer getIncludedFile: '#include  "blah.inc"') equals: 'blah.inc'
]

{ #category : #tests }
FortranProjectImporterTest >> testResolveIncludedFortranFiles [

	[
		self prepareWorkspace.
		importer collectIncludedFiles.
		importer resolveIncludedFiles.
		self
			assert: (importer includedPaths select: #isNotNil) size
			equals: 3.
		self assert: importer includedFilePathsDictionary size equals: 3.
		self
			assertCollection: importer includedFiles
			includesAll: #( 'f1.inc' 'f3.obj' 'f2.seg' ).
		self
			assertCollection: importer includedPaths
			includesAll: #( '/project/inc1/f1.inc' '/project/inc1/f2.seg' '/project/inc2/f3.obj' )
	] ensure: [
		(fileSystem / 'project') ensureDeleteAll 
	]
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
