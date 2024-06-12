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

	importer srcFolders: { fileSystem / 'project/src' }.
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

{ #category : #running }
FortranProjectImporterTest >> tearDown [ 

	| folder |
	super tearDown.

	folder := './tmpEsopeImport' asFileReference.
	folder exists ifTrue: [ folder deleteAll ].

	folder := './tmpFortranImport' asFileReference.
	folder exists ifTrue: [ folder deleteAll ]
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
FortranProjectImporterTest >> testCollectIncludedFileNames [

	self prepareWorkspace.

	self
		assertCollection: importer collectIncludedFileNames
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
FortranProjectImporterTest >> testEsopeFileToFortran [

	| srcFile destFile |
	srcFile := fileSystem / 'esope.e'.
	srcFile writeStreamDo: [ :st |
		st << '      subroutine rtn
      segini p
      end
' ].
	destFile := fileSystem / 'esope.f'.

	importer deEsopify: srcFile from: fileSystem root to: fileSystem root.

	self assert: destFile exists.
	self
		assert: destFile contents withInternalLineEndings
		equals: '      subroutine rtn
c@_   segini p
      end
'
]

{ #category : #'tests - import steps' }
FortranProjectImporterTest >> testEsopeToFortran [

	| tempFolder |
	self prepareWorkspace.

	importer esopeToFortran.

	tempFolder := './tmpFortranImport' asFileReference.
	self assert: tempFolder exists.
	self assert: tempFolder children size equals: 1.
	self assert: tempFolder children anyOne basename equals: 'project'.

	tempFolder := tempFolder / 'project'.
	self assert: tempFolder children size equals: 1.
	self assert: tempFolder children anyOne basename equals: 'src'.

	tempFolder := tempFolder / 'src'.
	self
		assertCollection: (tempFolder children collect: #basename)
		hasSameElements: #( 'f1.f' 'f2.f' ).

]

{ #category : #tests }
FortranProjectImporterTest >> testFakeEsopeProgramUnitTo [

	| srcFile resultFile |
	(fileSystem  / 'inc') createDirectory.
	srcFile := (fileSystem / 'inc' / 'included.h').
	srcFile writeStreamDo: [:st | st << 'a line' ; cr].

	importer fakeEsopeProgramUnit: srcFile to: (fileSystem / 'tmpEsope').

	resultFile := fileSystem / 'tmpEsope' / 'inc' / 'included.h.E'.

	self assert: resultFile exists.
	self assert: resultFile contents equals: '      subroutine _$included_h
a line
      end
'
]

{ #category : #tests }
FortranProjectImporterTest >> testFileReferencesForIn [

	| files |
	self prepareWorkspace.

	files := importer findFiles: #( 'f2.seg' ) in: { importer includeFolders first }.

	self assert: files size equals: 1.
	self assert: files anyOne fullName equals: '/project/inc1/f2.seg'
]

{ #category : #tests }
FortranProjectImporterTest >> testFileReferencesForInNotFound [

	| files |
	self prepareWorkspace.

	files := importer findFiles: #( 'inexistent.file' ) in: importer includeFolders.

	self assert: files size equals: 0
]

{ #category : #tests }
FortranProjectImporterTest >> testFileReferencesForInWithDuplicate [

	| files |
	self prepareWorkspace.


	files := importer findFiles: #( 'f1.inc' ) in: importer includeFolders.

	self assert: files size equals: 1.
	self assert: files anyOne fullName equals: '/project/inc1/f1.inc'
]

{ #category : #tests }
FortranProjectImporterTest >> testFindIncludesIn [
	| includer files |
	self prepareWorkspace.

	includer := importer srcFolders anyOne children detect: [ :file | file basename = 'f1.fc' ].
	files := importer includedNamesIn: includer.

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

{ #category : #'tests - import steps' }
FortranProjectImporterTest >> testFortranToJsonAST [

	"This test depends on having a parser available.
	 But parsers are external to Pharo so, would fail on CI"

	"| tempFolder |
	self prepareWorkspace.

	importer fortranToJsonAST.

	tempFolder := './tmpJsonImport' asFileReference.
	self assert: tempFolder exists.
	self assert: tempFolder children size equals: 1.
	self assert: tempFolder children anyOne basename equals: 'project'.

	tempFolder := tempFolder / 'project'.
	self assert: tempFolder children size equals: 1.
	self assert: tempFolder children anyOne basename equals: 'src'.

	tempFolder := tempFolder / 'src'.
	self
		assertCollection: (tempFolder children collect: #basename)
		hasSameElements: #( 'f3.json' ).
"
]

{ #category : #tests }
FortranProjectImporterTest >> testGetIncludedFile [

	self assert: (importer getIncludedFileName: '#include  "blah.inc"') equals: 'blah.inc'
]

{ #category : #'tests - import steps' }
FortranProjectImporterTest >> testIncludedFilesToEsope [

	| tempFolder |
	self prepareWorkspace.

	importer includedFilesToEsope.

	tempFolder := './tmpEsopeImport' asFileReference.
	self assert: tempFolder exists.
	self assert: tempFolder children size equals: 1.
	self assert: tempFolder children anyOne basename equals: 'project'.

	tempFolder := tempFolder / 'project'.
	self
		assertCollection: (tempFolder children collect: #basename)
		hasSameElements: #( 'inc1' 'inc2' ).

	self
		assertCollection: ((tempFolder / 'inc1') children collect: #basename)
		hasSameElements: #( 'f1.inc.E' 'f2.seg.E' ).

	self
		assertCollection: ((tempFolder / 'inc2') children collect: #basename)
		hasSameElements: #( 'f3.obj.E').

]

{ #category : #tests }
FortranProjectImporterTest >> testUnquoteIncludedFile [

	self assert: (importer unquoteIncludedFile: 'blah') equals: 'blah'.
	self assert: (importer unquoteIncludedFile: 'blah.f') equals: 'blah.f'.
	self assert: (importer unquoteIncludedFile: '"blah.inc"') equals: 'blah.inc'.
	self assert: (importer unquoteIncludedFile: '<lib/blah.h>') equals: 'lib/blah.h'
]
