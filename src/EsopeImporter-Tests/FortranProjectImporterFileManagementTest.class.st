"
I am a test class for testing the management of files and paths in FortranProjectImporter
"
Class {
	#name : #FortranProjectImporterFileManagementTest,
	#superclass : #TestCase,
	#instVars : [
		'importer',
		'fileSystem'
	],
	#category : #'EsopeImporter-Tests-Importer'
}

{ #category : #running }
FortranProjectImporterFileManagementTest >> prepareWorkspace [

	| f1 f2 |
	fileSystem createDirectory: '/project'.
	fileSystem createDirectory: '/project/inc'.
	fileSystem createDirectory: '/project/inc/inc1'.
	fileSystem createDirectory: '/project/inc/inc2'.
	fileSystem createDirectory: '/project/src'.

	(fileSystem / '/project/inc/inc1/f1.inc') createFile.
	(fileSystem / '/project/inc/inc1/f2.seg') createFile.
	(fileSystem / '/project/inc/inc2/f3.obj') createFile.
	"note: duplicated name f1.inc, by default importer will take the first found"
	(fileSystem / '/project/inc/inc2/f1.inc') createFile.
	(fileSystem / '/project/inc/inc2/f4.h') createFile.

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

]

{ #category : #running }
FortranProjectImporterFileManagementTest >> setUp [
	super setUp.

	importer := FortranProjectImporter new.
	importer errorHandler: FortranErrorManager new.

	fileSystem := FileSystem memory.

	importer srcFolder: fileSystem / 'project' / 'src'.
	importer includeFolder: fileSystem / 'project' / 'inc'
]

{ #category : #running }
FortranProjectImporterFileManagementTest >> tearDown [ 

	| folder |
	super tearDown.

	folder := './tmpEsopeImport' asFileReference.
	folder exists ifTrue: [ folder deleteAll ].

	folder := './tmpFortranImport' asFileReference.
	folder exists ifTrue: [ folder deleteAll ]
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testAllLocalizedFilesIn [

	| files |
	self prepareWorkspace.

	files := importer allLocalizedFilesIn: fileSystem / 'project' / 'inc'.

	self
		assertCollection: (files collect: #pathString)
		hasSameElements: #( 'inc1/f1.inc' 'inc1/f2.seg' 'inc2/f3.obj' 'inc2/f1.inc' 'inc2/f4.h' ).

]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testCollectFilesInWithExtensions [

	| files |
	self prepareWorkspace.

	files := importer
		collectFilesIn: importer includeFolder
		withExtensions: {'obj'}.
	self assert: files size equals: 1.
	self assert: files anyOne fullName equals: '/project/inc/inc2/f3.obj'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testCollectFilesInWithExtensionsSeveralFiles [

	| files |
	self prepareWorkspace.

	files := importer
		collectFilesIn: importer includeFolder 
		withExtensions: {'inc'}.
	self assert: files size equals: 2.
	self
		assertCollection: (files collect: #fullName)
		hasSameElements: #( '/project/inc/inc1/f1.inc' '/project/inc/inc2/f1.inc')
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testCollectIncludedFileNames [

	self prepareWorkspace.

	self
		assertCollection: (importer collectIncludedFileNames)
		 hasSameElements: #( 'f1.inc' 'f2.seg' 'f3.obj' )
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testCollectRelativePathsToIn [

	| files |
	self prepareWorkspace.

	files := importer collectRelativePathsTo: #( 'f2.seg' ) in: importer includeFolder.

	self assert: files size equals: 1.
	self assert: files anyOne equals: 'inc1/f2.seg'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testCollectRelativePathsToInNotFound [

	| files |
	self prepareWorkspace.

	files := importer collectRelativePathsTo: #( 'inexistent.file' ) in: importer includeFolder.

	self assert: files size equals: 0
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testCollectRelativePathsToInWithDuplicate [
	"returns the first file found"

	| files |
	self prepareWorkspace.


	files := importer collectRelativePathsTo: #( 'f1.inc' ) in: importer includeFolder.

	self assert: files size equals: 1.
	self assert: files anyOne equals: 'inc1/f1.inc'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testCollectSrcFilesWithExtensions [
	| files |
	self prepareWorkspace.

	files := importer collectSrcFilesWithExtensions: {'fc' . 'ec' }.
	self
		assertCollection: (files collect: #basename)
		 hasSameElements: #( 'f1.fc' 'f2.ec' )
]

{ #category : #'tests - import steps' }
FortranProjectImporterFileManagementTest >> testDeEsopifyFromTo [

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
FortranProjectImporterFileManagementTest >> testEsopeToFortran [

	| tempFolder |
	self prepareWorkspace.

	importer esopeToFortran.

	tempFolder := './tmpFortranImport' asFileReference.
	self assert: tempFolder exists.
	self assert: tempFolder children size equals: 1.
	self assert: tempFolder children anyOne basename equals: 'src'.

	tempFolder := tempFolder / 'src'.
	self
		assertCollection: (tempFolder children collect: #basename)
		hasSameElements: #( 'f1.f' 'f2.f' ).

]

{ #category : #'tests - import steps' }
FortranProjectImporterFileManagementTest >> testFakeEsopeProgramUnitTo [

	| srcFile resultFile |
	importer includeFolder: (fileSystem / 'inc').

	(fileSystem  / 'inc') createDirectory.
	srcFile := (fileSystem / 'inc' / 'included.h').
	srcFile writeStreamDo: [:st | st << 'a line' ; cr].

	importer fakeEsopeProgramUnit: 'included.h' to: (fileSystem / 'tmpEsope').

	resultFile := fileSystem / 'tmpEsope' / 'inc' / 'included.h.E'.

	self assert: resultFile exists.
	self assert: resultFile contents equals: '      subroutine _$included_h
a line
      end
'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testFindIncludesIn [
	| includer files |
	self prepareWorkspace.

	includer := importer srcFolder children detect: [ :file | file basename = 'f1.fc' ].
	files := importer includedNamesIn: includer.

	self
		assertCollection: files
		hasSameElements: #( 'f1.inc' 'f3.obj' )
]

{ #category : #'tests - import steps' }
FortranProjectImporterFileManagementTest >> testFortranToJsonAST [

	| tempFolder |
	self skip: 'Depends on having a parser available, but parsers are external to Pharo so, would fail on CI'.

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

]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testGetIncludedFile [

	self assert: (importer getIncludedFileName: '#include  "blah.inc"') equals: 'blah.inc'
]

{ #category : #'tests - import steps' }
FortranProjectImporterFileManagementTest >> testIncludedFilesToEsope [

	| tempFolder |
	self prepareWorkspace.

	importer includedFilesToEsope.

	tempFolder := './tmpEsopeImport' asFileReference.
	self assert: tempFolder exists.
	self assert: tempFolder children size equals: 1.
	self assert: tempFolder children anyOne basename equals: 'inc'.

	tempFolder := tempFolder / 'inc'.
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

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testRelativePathToIn [

	(fileSystem / 'included.h') createFile.

	self
		assert: (importer relativePathTo: 'included.h' in: fileSystem root)
		equals: 'included.h'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testRelativePathToInFirstPathFound [

	(fileSystem / 'inc1') createDirectory.
	(fileSystem / 'inc1' / 'included.h') createFile.
	(fileSystem / 'inc2') createDirectory.
	(fileSystem / 'inc2' / 'included.h') createFile.

	self
		assert:
		(importer relativePathTo: 'included.h' in: fileSystem root)
		equals: 'inc1/included.h'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testRelativePathToInNoExtension [

	(fileSystem / 'included') createFile.

	self
		assert: (importer relativePathTo: 'included' in: fileSystem root)
		equals: 'included'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testRelativePathToInNotFound [

	(fileSystem / 'excluded.h') createFile.

	self
		assert: (importer relativePathTo: 'included.h' in: fileSystem root)
		equals: nil
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testRelativePathToInSubDirectory [

	(fileSystem / 'inc') createDirectory.
	(fileSystem / 'inc' / 'included.h') createFile.

	self
		assert: (importer relativePathTo: 'included.h' in: fileSystem root)
		equals: 'inc/included.h'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testRelativePathToInWithPath [

	(fileSystem / 'inc') createDirectory.
	(fileSystem / 'inc' / 'included.h') createFile.

	self
		assert:
		(importer relativePathTo: 'inc/included.h' in: fileSystem root)
		equals: 'inc/included.h'
]

{ #category : #'tests - file-management' }
FortranProjectImporterFileManagementTest >> testUnquoteIncludedFile [

	self assert: (importer unquoteIncludedFile: 'blah') equals: 'blah'.
	self assert: (importer unquoteIncludedFile: 'blah.f') equals: 'blah.f'.
	self assert: (importer unquoteIncludedFile: '"blah.inc"') equals: 'blah.inc'.
	self assert: (importer unquoteIncludedFile: '<lib/blah.h>') equals: 'lib/blah.h'
]
