"
I am a test class for testing the management of files and paths in FortranProjectImporter
"
Class {
	#name : 'FortranProjectImporterTest',
	#superclass : 'FamixEsopeUtilitiesTest',
	#instVars : [
		'importer',
		'fileSystem'
	],
	#category : 'EsopeImporter-Tests-Importer',
	#package : 'EsopeImporter-Tests',
	#tag : 'Importer'
}

{ #category : 'running' }
FortranProjectImporterTest >> prepareWorkspace [

	| f1 f2 |
	fileSystem createDirectory: '/project'.
	fileSystem createDirectory: '/project/includes'.
	fileSystem createDirectory: '/project/includes/inc1'.
	fileSystem createDirectory: '/project/includes/inc2'.
	fileSystem createDirectory: '/project/sources'.

	(fileSystem / '/project/includes/inc1/f1.inc') createFile.
	(fileSystem / '/project/includes/inc1/f2.seg') createFile.
	(fileSystem / '/project/includes/inc2/f3.obj') createFile.
	"note: duplicated name f1.inc, by default importer will take the first found"
	(fileSystem / '/project/includes/inc2/f1.inc') createFile.
	(fileSystem / '/project/includes/inc2/f4.h') createFile.

	f1 := (fileSystem / 'project/sources/f1.fc') createFile.
	f2 := (fileSystem / 'project/sources/f2.ec') createFile.
	(fileSystem / 'project/sources/f3.f') createFile.

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

{ #category : 'running' }
FortranProjectImporterTest >> setUp [
	super setUp.

	importer := FortranProjectImporter new.
	importer errorHandler: FortranErrorManager new.

	fileSystem := FileSystem memory.

	importer sourceFolder: fileSystem / 'project' / 'sources'.
	importer includeFolder: fileSystem / 'project' / 'includes'
]

{ #category : 'running' }
FortranProjectImporterTest >> tearDown [ 

	| folder |
	super tearDown.

	folder := './tmpEsopeImport' asFileReference.
	folder exists ifTrue: [ folder deleteAll ].

	folder := './tmpFortranImport' asFileReference.
	folder exists ifTrue: [ folder deleteAll ].

	folder := './tmpJsonImport' asFileReference.
	folder exists ifTrue: [ folder deleteAll ]

]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testCollectFilesIn [

	| files |
	self prepareWorkspace.

	files := importer collectFilesIn: fileSystem / 'project' / 'includes'.

	self
		assertCollection: (files collect: #pathString)
		hasSameElements: #(
			'/project/includes/inc1/f1.inc'
			'/project/includes/inc1/f2.seg'
			'/project/includes/inc2/f3.obj'
			'/project/includes/inc2/f1.inc'
			'/project/includes/inc2/f4.h' ).

]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testCollectFilesInWithExtensions [

	| files |
	self prepareWorkspace.

	files := importer
		collectFilesIn: importer includeFolder
		withExtensions: {'obj'}.
	self assert: files size equals: 1.
	self assert: files anyOne fullName equals: '/project/includes/inc2/f3.obj'
]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testCollectFilesInWithExtensionsSeveralFiles [

	| files |
	self prepareWorkspace.

	files := importer
		collectFilesIn: importer includeFolder 
		withExtensions: {'inc'}.
	self assert: files size equals: 2.
	self
		assertCollection: (files collect: #fullName)
		hasSameElements: #( '/project/includes/inc1/f1.inc' '/project/includes/inc2/f1.inc')
]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testCollectIncludedFileNames [

	self prepareWorkspace.

	self
		assertCollection: (importer collectIncludedFileNames)
		hasSameElements: #( 'f1.inc' 'f2.seg' 'f3.obj' )
]

{ #category : 'tests - import steps' }
FortranProjectImporterTest >> testDeEsopifyFromTo [

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

{ #category : 'tests - import steps' }
FortranProjectImporterTest >> testEsopeToFortran [

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

{ #category : 'tests - import steps' }
FortranProjectImporterTest >> testFakeEsopeProgramUnitFromTo [

	| srcFile resultFile |
	importer includeFolder: (fileSystem / 'inc').

	(fileSystem  / 'inc') createDirectory.
	srcFile := (fileSystem / 'inc' / 'included.h').
	srcFile writeStreamDo: [:st | st << 'a line' << OSPlatform current lineEnding ].

	importer
		fakeEsopeProgramUnit: srcFile
		from: (fileSystem / 'inc')
		to: (fileSystem / 'tmpEsope' / 'inc').

	resultFile := fileSystem / 'tmpEsope' / 'inc' / 'included.h.E'.

	self assert: resultFile exists.
	self assert: resultFile contents equals: '      subroutine _$included_h
a line
      end
' withPlatformLineEndings
]

{ #category : 'tests - import steps' }
FortranProjectImporterTest >> testFortranToJsonAST [

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

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testGetIncludedFile [

	| names |
	names := importer getIncludedFileName: '#include  "blah.inc"'.

	self assert: names equals: 'blah.inc'
]

{ #category : 'tests - import steps' }
FortranProjectImporterTest >> testIASTToFamix [
	"json file and assert: taken from
	   IASTToFamixVisitorTest >> testFamixFortran77PUFunctionWithParameter"

	| iastEntity fmxEntity param |
	iastEntity := IASTParameter new
			entityName: 'var' ;
			yourself.
	iastEntity := IASTFunction new
		entityName: 'fct' ;
		parameters: { iastEntity } ;
		yourself.
	iastEntity := IASTProgramFile new
		filename: './main.f' ;
		body: {  iastEntity } ;
		yourself.
	importer iastModel: { iastEntity }.

	importer iASTToFamix.

	self assert: (importer famixModel allWithType: FamixF77ProgramFile) size equals: 1.

	fmxEntity := (importer famixModel allWithType: FamixF77ProgramFile) anyOne.
	self assert: fmxEntity programUnits size equals: 1.

	fmxEntity := fmxEntity programUnits first.
	self assert: fmxEntity class equals: FamixF77PUFunction.
	self assert: fmxEntity name equals: 'fct'.
	self assert: fmxEntity programFile isNotNil.

	self assert: fmxEntity parameters size equals: 1.
	param := fmxEntity parameters first.
	self assert: param class equals: FamixF77Parameter.
	self assert: param name equals: 'var'.
	self assert: param parentBehaviouralEntity equals: fmxEntity.
]

{ #category : 'tests - import steps' }
FortranProjectImporterTest >> testIncludedFilesToEsope [

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

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testIncludedNamesIn [
	| includer files |
	self prepareWorkspace.

	includer := importer sourceFolder children detect: [ :file | file basename = 'f1.fc' ].
	files := importer includedNamesIn: includer.

	self
		assertCollection: files
		hasSameElements: #( 'f1.inc' 'f3.obj' )
]

{ #category : 'tests - import steps' }
FortranProjectImporterTest >> testJsonASTToIAST [
	"json file and assert: taken from JsonToIASTVisitorTest >> testMultipleStatements

		subroutine hello
      integer someVar
      someVar = 3 * someVar
      end"

	| jsonFile  stmt |

	jsonFile := importer tempJsonFolder / 'sources/aFile.json'.
	jsonFile ensureCreateFile.
	jsonFile writeStreamDo: [ :st |
		st
			<< '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:21)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:15)-(2:21)","type":"scalar","variable":{"anno":[],"span":"(2:15)-(2:21)","tag":"value","value":{"contents":"somevar","tag":"variable"}}}],"span":"(2:15)-(2:21)"},"span":"(2:7)-(2:21)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:27)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:17)-(3:17)","tag":"value","value":{"contents":["3",null],"tag":"integer"}},"op":{"tag":"multiplication"},"right":{"anno":[],"span":"(3:21)-(3:27)","tag":"value","value":{"contents":"somevar","tag":"variable"}},"span":"(3:17)-(3:27)","tag":"binary"},"span":"(3:7)-(3:27)","tag":"assign_expression","target":{"anno":[],"span":"(3:7)-(3:13)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'
	].

	importer jsonASTToIAST.

	programFile := importer iastModel anyOne.
	
	self assert: programFile isNotNil.
	self assert: programFile body first body size equals: 2.

	stmt := programFile body first body first first.
	self assert: stmt class equals: IASTVariable.
	self assert: stmt typeSpec class equals: IASTTypeRef.
	self assert: stmt entityName equals: 'somevar'.

	stmt := programFile body first body second first.
	self assert: stmt class equals: IASTVarAccess.
	self assert: stmt isWrite.
	self deny: stmt isParameterDefinition.
	self assert: stmt entityName equals: 'somevar'.

	stmt := programFile body first body second second.
	self assert: stmt class equals: IASTVarAccess.
	self deny: stmt isWrite.
	self assert: stmt entityName equals: 'somevar'.

]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testPathOfIn [

	| path |
	(fileSystem / 'included.h') createFile.

	path := importer pathOf: 'included.h' in: fileSystem root.

	self assert: path fullName equals: '/included.h'
]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testPathOfInFirstPathFound [

	| path |
	(fileSystem / 'inc1') createDirectory.
	(fileSystem / 'inc1' / 'included.h') createFile.
	(fileSystem / 'inc2') createDirectory.
	(fileSystem / 'inc2' / 'included.h') createFile.

	path := importer pathOf: 'included.h' in: fileSystem root.

	self assert: path fullName equals: '/inc1/included.h'
]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testPathOfInNoExtension [

	| path |

	(fileSystem / 'included') createFile.

	path := importer pathOf: 'included' in: fileSystem root.

	self assert: path fullName equals: '/included'
]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testPathOfInNotFound [

	| path |
	(fileSystem / 'excluded.h') createFile.

	path := importer pathOf: 'included.h' in: fileSystem root.

	self assert: path equals: nil
]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testPathOfInSubDirectory [

	| path |
	(fileSystem / 'includes') createDirectory.
	(fileSystem / 'includes' / 'included.h') createFile.

	path := importer pathOf: 'included.h' in: fileSystem root.

	self assert: path fullName equals: '/includes/included.h'
]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testPathOfInWithPath [

	| path |
	(fileSystem / 'includes') createDirectory.
	(fileSystem / 'includes' / 'included.h') createFile.

	path := importer pathOf: 'includes/included.h' in: fileSystem root.

	self assert: path fullName equals: '/includes/included.h'
]

{ #category : 'tests - import steps' }
FortranProjectImporterTest >> testPostImportChecks [
	"test copied from #testSanityCheckParameterPass"

	(self newEntity: FamixF77Parameter)
		declaredType: (self newEntity: FamixF77TypeIntrinsic) ;
		parentBehaviouralEntity: (self defaultSubroutine: 'aRoutine').

	importer withSanityChecks: true.
	importer stopOnError: true.
	importer famixModel: mooseModel.

	self shouldnt: [ importer postImportChecks ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckAccessNoAccessor [

	| access |
	access := self newEntity: FamixF77Access.
	access variable: (self newEntity: FamixF77Variable).

	self should: [ access famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckAccessNoVariable [

	| access |
	access := self newEntity: FamixF77Access.
	access accessor: (self newEntity: FamixF77PUSubroutine).

	self should: [ access famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckAccessPass [

	| access |
	access := self newEntity: FamixF77Access.
	access variable: (self newEntity: FamixF77Variable).
	access accessor: (self newEntity: FamixF77PUSubroutine).

	self shouldnt: [ access famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckAttributeNoDeclaredType [

	| var |
	var := self newEntity: FamixFortranAttribute named: 'anAttribute'.
	var parentType: (self newEntity: FamixEsopeSegment).

	self should: [ var famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckAttributeNoParent [

	| var |
	var := self newEntity: FamixFortranAttribute named: 'anAttribute'.
	var declaredType: (self newEntity: FamixF77TypeIntrinsic).

	self should: [ var famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckAttributePass [

	| var |
	var := self newEntity: FamixFortranAttribute named: 'anAttribute'.
	var parentType: (self newEntity: FamixEsopeSegment).
	var declaredType: (self newEntity: FamixF77TypeIntrinsic).

	self shouldnt: [ var famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckEsopeCommandNoAccessor [

	| cmd |
	cmd := self newEntity: FamixEsopeCommand.
	cmd variable: (self newEntity: FamixF77Variable).
	cmd variable declaredType: (self newEntity: FamixEsopeSegment).

	self should: [cmd famixImportSanityCheck] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckEsopeCommandNoVariable [

	| cmd |
	cmd := self newEntity: FamixEsopeCommand.
	cmd accessor: (self newEntity: FamixF77PUSubroutine).

	self should: [cmd famixImportSanityCheck] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckEsopeCommandNotPointer [

	| cmd |
	cmd := self newEntity: FamixEsopeCommand.
	cmd variable: (self newEntity: FamixF77Variable).
	cmd variable declaredType: (self newEntity: FamixF77TypeIntrinsic).
	cmd accessor: (self newEntity: FamixF77PUSubroutine).

	self should: [cmd famixImportSanityCheck] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckEsopeCommandPass [

	| cmd |
	cmd := self newEntity: FamixEsopeCommand.
	cmd variable: (self newEntity: FamixF77Variable).
	cmd variable declaredType: (self newEntity: FamixEsopeSegment).
	cmd accessor: (self newEntity: FamixF77PUSubroutine).

	self shouldnt: [cmd famixImportSanityCheck] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckIncludedFileNoInclusion [

	| includedFile |
	includedFile := self newEntity: FamixF77IncludedFile named: 'file.inc'.
	includedFile programFile: (self newEntity: FamixF77ProgramFile).

	self should: [ includedFile famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckIncludedFileNoParent [

	| includedFile |
	includedFile := self newEntity: FamixF77IncludedFile named: 'file.inc'.
	includedFile inclusions: { self newEntity: FamixF77Include }.

	self should: [ includedFile famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckIncludedFilePass [

	| includedFile |
	includedFile := self newEntity: FamixF77IncludedFile named: 'file.inc'.
	includedFile programFile: (self newEntity: FamixF77ProgramFile).
	includedFile inclusions: { self newEntity: FamixF77Include }.

	self shouldnt: [ includedFile famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckIntrinsicRoutineNoInvoker [

	| includedFile |
	includedFile := self newEntity: FamixF77IntrinsicRoutine named: 'write'.
	includedFile incomingInvocations: #().

	self should: [ includedFile famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckIntrinsicRoutinePass [

	| includedFile |
	includedFile := self newEntity: FamixF77IntrinsicRoutine named: 'write'.
	includedFile incomingInvocations: { self newEntity: FamixF77Invocation }.

	self shouldnt: [ includedFile famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckInvocationNoCandidates [

	| invok |
	invok := self newEntity: FamixF77Invocation.
	invok sender: (self newEntity: FamixF77PUSubroutine).
	invok candidates: #().

	self should: [ invok famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckInvocationNoSender [

	| invok |
	invok := self newEntity: FamixF77Invocation.
	invok candidates: { self newEntity: FamixF77PUFunction }.

	self should: [ invok famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckInvocationPass [

	| invok |
	invok := self newEntity: FamixF77Invocation.
	invok sender: (self newEntity: FamixF77PUSubroutine).
	invok candidates: { self newEntity: FamixF77PUFunction }.

	self shouldnt: [ invok famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckMainNoParent [

	| main |
	main := self newEntity: FamixF77PUMain named: 'myMain'.

	self should: [ main famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckMainPass [

	| main |
	main := self newEntity: FamixF77PUMain named: 'myMain'.
	main programFile: (self newEntity: FamixF77ProgramFile).

	self shouldnt: [ main famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckPUFunctionNoDeclaredType [

	| fct |
	fct := self newEntity: FamixF77PUFunction named: 'f'.
	fct programFile: (self newEntity: FamixF77ProgramFile).

	self should: [ fct famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckPUFunctionNoParent [

	| fct |
	fct := self newEntity: FamixF77PUFunction named: 'f'.
	fct declaredType: (self newEntity: FamixF77TypeIntrinsic).

	self should: [ fct famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckPUFunctionPass [

	| fct |
	fct := self newEntity: FamixF77PUFunction named: 'f'.
	fct programFile: (self newEntity: FamixF77ProgramFile).
	fct declaredType: (self newEntity: FamixF77TypeIntrinsic).

	self shouldnt: [ fct famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckParameterNoDeclaredType [

	| param |
	param := self newEntity: FamixF77Parameter.
	param parentBehaviouralEntity: (self newEntity: FamixF77PUSubroutine).

	self should: [ param famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckParameterNoParent [

	| param |
	param := self newEntity: FamixF77Parameter.
	param declaredType: (self newEntity: FamixF77TypeIntrinsic).

	self should: [ param famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckParameterPass [

	| param |
	param := self newEntity: FamixF77Parameter.
	param declaredType: (self newEntity: FamixF77TypeIntrinsic).
	param parentBehaviouralEntity: (self newEntity: FamixF77PUSubroutine).

	self shouldnt: [ param famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckStatementFunctionNoParent [

	| fct |
	fct := self newEntity: FamixF77StatementFunction named: 'f'.

	self should: [ fct famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckStatementFunctionPass [

	| fct |
	fct := self newEntity: FamixF77StatementFunction named: 'f'.
	fct parentEntity: (self newEntity: FamixF77PUSubroutine).

	self shouldnt: [ fct famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckUnknownVariableNoAccess [

	| var |
	var := self newEntity: FamixF77UnknownVariable.
	var incomingAccesses: #().

	self should: [ var famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckUnknownVariablePass [

	| var |
	var := self newEntity: FamixF77UnknownVariable.
	var incomingAccesses: {  self newEntity: FamixF77Access }.

	self shouldnt: [ var famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckVariableNoDeclaredType [

	| var |
	var := self newEntity: FamixF77Variable named: 'aVariable'.
	var parentBehaviouralEntity: (self newEntity: FamixF77PUSubroutine).

	self should: [ var famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckVariableNoParent [

	| var |
	var := self newEntity: FamixF77Variable named: 'aVariable'.
	var declaredType: (self newEntity: FamixF77TypeIntrinsic).

	self should: [ var famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'test - sanityCheck' }
FortranProjectImporterTest >> testSanityCheckVariablePass [

	| var |
	var := self newEntity: FamixF77Variable named: 'aVariable'.
	var parentBehaviouralEntity: (self newEntity: FamixF77PUSubroutine).
	var declaredType: (self newEntity: FamixF77TypeIntrinsic).

	self shouldnt: [ var famixImportSanityCheck ] raise: SanityCheckException.

]

{ #category : 'tests - file-management' }
FortranProjectImporterTest >> testUnquoteIncludedFile [

	self assert: (importer unquoteIncludedFile: 'blah') equals: 'blah'.
	self assert: (importer unquoteIncludedFile: 'blah.f') equals: 'blah.f'.
	self assert: (importer unquoteIncludedFile: '"blah.inc"') equals: 'blah.inc'.
	self assert: (importer unquoteIncludedFile: '<lib/blah.h>') equals: 'lib/blah.h'
]
