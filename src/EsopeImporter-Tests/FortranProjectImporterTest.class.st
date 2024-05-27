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
	"note: duplicated name f1.inc, by default importer will take the first found"
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
FortranProjectImporterTest >> testCollectFilesInWithExtensions [

	| files |
	self prepareWorkspace.

	files := importer
		collectFilesIn: importer includeFolders first "project/inc1"
		withExtensions: {'inc'}.
	self assert: files size equals: 1.
	self assert: files anyOne fullName equals: '/project/inc1/f1.inc'.
]

{ #category : #tests }
FortranProjectImporterTest >> testCollectFilesInWithExtensionsSeveralFiles [

	| files |
	self prepareWorkspace.

	files := importer
		collectFilesIn: importer includeFolders anyOne parent "/project/"
		withExtensions: {'inc'}.
	self assert: files size equals: 2.
	self assert: files anyOne basename equals: 'f1.inc'.
]

{ #category : #tests }
FortranProjectImporterTest >> testCollectIncludedFiles [

	self prepareWorkspace.
	importer collectIncludedFiles.

	self
		assertCollection: importer includedFiles
		hasSameElements: #( 'f1.inc' 'f2.seg' 'f3.obj' )
]

{ #category : #tests }
FortranProjectImporterTest >> testCollectSrcFilesWithExtensions [
	| files |
	self prepareWorkspace.

	files := importer collectSrcFilesWithExtensions: {'fc' . 'ec' }.
	self
		assertCollection: (files collect: #basename)
		 hasSameElements: #( 'f1.fc' 'f2.ec' )
]

{ #category : #tests }
FortranProjectImporterTest >> testFakeEsopeProgramUnitTo [

	| srcFile resultFile |
	(fileSystem  / 'inc') createDirectory.
	srcFile := (fileSystem / 'inc' / 'included.h').
	srcFile writeStreamDo: [:st | st << 'a line' ; cr].

	importer fakeEsopeProgramUnit: srcFile to: (fileSystem / 'tmpEsope').

	self assert: importer originalFileMap size equals: 1.
	self
		assert: (importer originalFileMap at: '/tmpEsope/tmpIncludeDirectory/inc/included.h.E')
		equals: '/inc/included.h'.

	resultFile := fileSystem / 'tmpEsope' / 'tmpIncludeDirectory' / 'inc' / 'included.h.E'.

	self assert: resultFile exists.
	self assert: resultFile contents equals: '      subroutine __$__
a line
      end
'
]

{ #category : #test }
FortranProjectImporterTest >> testFileReferencesForIn [

	| files |
	self prepareWorkspace.

	files := importer fileReferencesFor: #( 'f2.seg' ) in: { importer includeFolders first }.

	self assert: files size equals: 1.
	self assert: files anyOne fullName equals: '/project/inc1/f2.seg'
]

{ #category : #test }
FortranProjectImporterTest >> testFileReferencesForInNotFound [

	| files |
	self prepareWorkspace.

	files := importer fileReferencesFor: #( 'inexistent.file' ) in: importer includeFolders.

	self assert: files size equals: 0
]

{ #category : #test }
FortranProjectImporterTest >> testFileReferencesForInWithDuplicate [

	| files |
	self prepareWorkspace.


	files := importer fileReferencesFor: #( 'f1.inc' ) in: importer includeFolders.

	self assert: files size equals: 1.
	self assert: files anyOne fullName equals: '/project/inc1/f1.inc'
]

{ #category : #tests }
FortranProjectImporterTest >> testFindIncludesIn [
	| includer files |
	self prepareWorkspace.

	includer := importer srcFolders anyOne children detect: [ :file | file basename = 'f1.fc' ].
	files := importer findIncludesIn: includer.

	self
		assertCollection: files
		 hasSameElements: #( 'f1.inc' 'f3.obj' )
]

{ #category : #tests }
FortranProjectImporterTest >> testFolderContainingAmong [

	| file |
	file := (fileSystem / 'included.h') createFile.

	self assert: (importer folderContaining: 'included.h' among: { fileSystem } ) equals: file
]

{ #category : #tests }
FortranProjectImporterTest >> testFolderContainingAmongNoExtension [

	| file |
	file := (fileSystem / 'included') createFile.

	self assert: (importer folderContaining: 'included' among: { fileSystem } ) equals: file
]

{ #category : #tests }
FortranProjectImporterTest >> testFolderContainingAmongNotFound [

	(fileSystem / 'excluded.h') createFile.

	self assert: (importer folderContaining: 'included.h' among: { fileSystem } ) equals: nil
]

{ #category : #tests }
FortranProjectImporterTest >> testFolderContainingAmongWithPath [

	| file |
	(fileSystem  / 'inc') createDirectory.
	file := (fileSystem / 'inc' / 'included.h') createFile.

	self assert: (importer folderContaining: 'inc/included.h' among: { fileSystem } ) equals: file
]

{ #category : #tests }
FortranProjectImporterTest >> testGetIncludedFile [

	self assert: (importer getIncludedFileName: '#include  "blah.inc"') equals: 'blah.inc'
]

{ #category : #tests }
FortranProjectImporterTest >> testUnquoteIncludedFile [

	self assert: (importer unquoteIncludedFile: 'blah') equals: 'blah'.
	self assert: (importer unquoteIncludedFile: 'blah.f') equals: 'blah.f'.
	self assert: (importer unquoteIncludedFile: '"blah.inc"') equals: 'blah.inc'.
	self assert: (importer unquoteIncludedFile: '<lib/blah.h>') equals: 'lib/blah.h'
]
