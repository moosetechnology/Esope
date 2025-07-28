"
Responsible to import an Esope project into a Famix model

To use:

## Build an Esope model

change `/path/to/...` in the importer initialiser, regardless of your project's path

### Initialise the project importer
```st
importer := FamixEsopeImporter new.
""importer := FamixFortranImporter new.""

importer 
	sourceFolder: '/path/to/project/rootdir'; 
	includeFolder: '/path/to/include/folder'

```
### Construct the model
```st
model := importer import.
```

This will import all files with a `*.E` (or `*.ec`) extension + all included files (`*.inc`, `*.seg`,, `*.obg`, ...)
This is done in various steps (see `#importSteps`):
- copy Esope files (`*.E`) in a temporary directory (`./Esope/`)
- create special Esope files for included files (in same directory `./Esope/`)
- convert Esope files to Fortran files by annotating Esope instruction (in `./Fortran/`)
- get AST of Fortran files into Json files (in `./AST/`)
- import AST into an intermediate representation
- convert intermediate representation to Famix
- resolve  symbols in Famix


### Managing import errors

Importing errors are recorded by the importer's `errorHandler`

```st
error := importer errorHandler.
```

You can also list all errors after the import with:
```st
importer errors.
```

Additional checking can be run on the final model:
```st
importer withSanityChecks: true.
```

Finally, for debugging, you can instruct the importer to stop at errors:
```st
importer stopOnError: true.
```

"
Class {
	#name : 'FamixFortranImporter',
	#superclass : 'Object',
	#instVars : [
		'famixModel',
		'iastmodel',
		'defaultFileEncoding',
		'errorHandler',
		'stopOnError',
		'includedFiles',
		'tempEsopeFolder',
		'tempFortranFolder',
		'tempJsonFolder',
		'resolver',
		'withSanityChecks',
		'includeFolder',
		'srcFolder',
		'withEsope',
		'fortranVersion'
	],
	#category : 'EsopeImporter-Importer',
	#package : 'EsopeImporter',
	#tag : 'Importer'
}

{ #category : 'constants' }
FamixFortranImporter class >> extensionsEsope [
	"Add F and fc as esope files in order to let the ReWriter handle the include statement for this type of file"

	^#(E ec e F fc)
]

{ #category : 'constants' }
FamixFortranImporter class >> extensionsFortran [

	^#(f for F90)
]

{ #category : 'importing' }
FamixFortranImporter class >> import [
	<script>
	^self new
		import
]

{ #category : 'testing' }
FamixFortranImporter class >> isDummySubroutine: aName [
	"name matches: _$ + a sequence of at least one character"

	^ '_$#*' match: aName
]

{ #category : 'api' }
FamixFortranImporter class >> onFile: aPathString [

	self assert: aPathString asFileReference exists.

	^self onSourceString: (aPathString asFileReference contents)
]

{ #category : 'api' }
FamixFortranImporter class >> onSourceString: aSourceString [

	| jsonToIastVisitor iastToFamixVistor |

	jsonToIastVisitor :=  JsonToIASTVisitor new 
		visitProgramFile: (NeoJSONReader 
			fromString: (self parseString: aSourceString)
		).

	iastToFamixVistor := IASTToFamixFortranVisitor new.
	iastToFamixVistor visit: jsonToIastVisitor.

	FamixEsopeResolver new model: iastToFamixVistor model; resolve.

	^iastToFamixVistor model.
]

{ #category : 'importing' }
FamixFortranImporter class >> parseString: fortranCode [

	| srcFile destFile |
	srcFile  := './srcCodeOrigin.f' asFileReference ensureDelete.
	destFile := './srcCodeOrigin.json' asFileReference ensureDelete.

	srcFile writeStreamDo: [ :stream | 
		stream << fortranCode withUnixLineEndings ].

	self new
		parseFortran77File: srcFile to: destFile.

	^destFile contents
]

{ #category : 'constants' }
FamixFortranImporter class >> workingEsopeName [

	^'tmpEsopeImport'
]

{ #category : 'constants' }
FamixFortranImporter class >> workingFortranName [

	^'tmpFortranImport'
]

{ #category : 'constants' }
FamixFortranImporter class >> workingJsonName [
	
	^'tmpJsonImport'
]

{ #category : 'private - files' }
FamixFortranImporter >> appendPath: aPath toParent: aFolder [
	"aPath may be a relative or absolute path, we want it 'concatenated' to aFolder
	 to give something like: 'aFolder / aPath' 
	 Additionaly, we make sure the resulting parent path exist so that if it is a file,
	 it can be created"

	| parent |
	(aPath fullName = '') ifTrue: [ ^aFolder ].
	(aPath fullName = '.') ifTrue: [ ^aFolder ].
	(aPath fullName = '/') ifTrue: [ ^aFolder ].

	parent := self appendPath: aPath parent toParent: aFolder.
	parent ensureCreateDirectory.

	^parent / aPath basename

]

{ #category : 'private - files' }
FamixFortranImporter >> collectFilesIn: aFileReference [

	^aFileReference isDirectory
		ifTrue: [ aFileReference children flatCollect: [ :child | self collectFilesIn: child  ] ]
		ifFalse: [ { aFileReference } ]
]

{ #category : 'private - files' }
FamixFortranImporter >> collectFilesIn: srcFileReference withExtensions: extensions [

	^(self collectFilesIn: srcFileReference)
		select: [ :file | extensions includes: file extension ]
]

{ #category : 'private - files' }
FamixFortranImporter >> collectIncludedFileNames [

	^(self collectFilesIn: srcFolder withExtensions: FamixFortranImporter extensionsEsope)
		flatCollectAsSet: [ :srcFileReference | self includedNamesIn: srcFileReference]
]

{ #category : 'private - files' }
FamixFortranImporter >> copy: aPath from: src to: dest [

	| localizedPath |
	localizedPath := aPath relativeTo: src.
	aPath asFileReference
		copyTo: (self appendPath: localizedPath toParent: dest)
]

{ #category : 'private - import' }
FamixFortranImporter >> deEsopify: srcFile from: sourceFolder to: destFolder [
	"de-esopify localPath in sourceFolder to fortran file in destFolder"

	| localPath destFile |

	localPath := srcFile relativeTo: sourceFolder.
	destFile := (self appendPath: localPath toParent: destFolder) withExtension: 'f'.

	errorHandler enterContext: 'file:' , srcFile fullName.

	PPEsopeRewriter
		rewriteFrom: (srcFile readStreamEncoded: self defaultFileEncoding)
		to: destFile.

	errorHandler leaveContext
]

{ #category : 'accessing' }
FamixFortranImporter >> defaultFileEncoding [
	"other possibilities are 'latin1', 'utf8', ...
	see `ZnCharacterEncoder knownEncodingIdentifiers` for all possibilities"

	^defaultFileEncoding ifNil: [ 'iso-8859-1' ]
]

{ #category : 'accessing' }
FamixFortranImporter >> defaultFileEncoding: aString [
	"other possibilities are 'latin1', 'utf8', ...
	see `ZnCharacterEncoder knownEncodingIdentifiers` for all possibilities"

	defaultFileEncoding := aString
]

{ #category : 'accessing' }
FamixFortranImporter >> defaultFortranVersion [
	"known Fortran versions: Fortran[66/77/77Legacy/77Extended/90/2003]
	 66 77 77l 77e 90 2003"
	^'77l'
]

{ #category : 'private - files' }
FamixFortranImporter >> ensureEmptyFolder: folder [

	folder exists ifTrue: [ folder deleteAll  ].
	folder ensureCreateDirectory.
	^folder
]

{ #category : 'error management' }
FamixFortranImporter >> errorHandler [

	^ errorHandler ifNil: [ errorHandler := FortranErrorManager new ]
]

{ #category : 'error management' }
FamixFortranImporter >> errorHandler: anObject [

	errorHandler := anObject
]

{ #category : 'error management' }
FamixFortranImporter >> errors [

	^errorHandler errors
]

{ #category : 'run' }
FamixFortranImporter >> esopeToFortran [
	"'de-esopifying Esope files to be able to parse them in Fortran
	The result goes in the FortranWorkingDirectory"

	withEsope ifFalse: [ ^self ].

	(self collectFilesIn: self tempEsopeFolder) do: [ :path |
		self
			deEsopify: path
			from: self tempEsopeFolder
			to: self tempFortranFolder
		].

	(self collectFilesIn: srcFolder withExtensions: FamixFortranImporter extensionsEsope) do: [ :srcFile |
		self
			deEsopify: srcFile
			from: srcFolder
			to: (self tempFortranFolder / 'src')
		]
]

{ #category : 'accessing' }
FamixFortranImporter >> f77parser [

	^ 'fortran-src-extras serialize -t json -v' , self fortranVersion , ' encode '
]

{ #category : 'private - import' }
FamixFortranImporter >> fakeEsopeProgramUnit: includedFile from: sourceFolder to: workingEsopeFolder [
	"creates a fake programUnit from an includedFile"

	| localizedSrcFile destFile |
	localizedSrcFile := includedFile relativeTo: sourceFolder.

	destFile := (workingEsopeFolder / localizedSrcFile pathString) , 'E'.
	destFile ensureCreateFile.

	destFile writeStreamDo: [ :tmpStream |
		self 
			writeFakeEsopeProgramUnit: (includedFile basename copy replaceAll: $. with: $_)
			from: includedFile contents
			on: tmpStream
		]


]

{ #category : 'accessing' }
FamixFortranImporter >> famixModel [

	^ famixModel
]

{ #category : 'accessing' }
FamixFortranImporter >> famixModel: anObject [

	famixModel := anObject
]

{ #category : 'run' }
FamixFortranImporter >> famixResolve [
	"creates a resolver and resolve all pending names"

	self newResolver
		resolve.

]

{ #category : 'run' }
FamixFortranImporter >> fortranToJsonAST [
	"Goes through all Fortran-77 files and parses each one to produce a corresponding Json AST
	 - 1st, de-esopified files
	 - 2nd, pure Fortran files"

	(self collectFilesIn: self tempFortranFolder) do: [ :localPath |
		self parseFortran77: localPath from: self tempFortranFolder to: self tempJsonFolder ].

	(self collectFilesIn: srcFolder withExtensions: FamixFortranImporter extensionsFortran) do: [ :projectPath |
		| localPath |
		localPath := projectPath relativeTo: srcFolder.
		"projectPath asFileReference
			copyTo: (self appendPath: localPath toParent: tempFortranFolder / 'src')."
		self parseFortran77: projectPath from: srcFolder to: self tempJsonFolder / 'src' ]
]

{ #category : 'accessing' }
FamixFortranImporter >> fortranVersion [

	^fortranVersion ifNil: [ self defaultFortranVersion ]
]

{ #category : 'accessing' }
FamixFortranImporter >> fortranVersion: version [
	(#('66' '77' '77l' '77e' '90' '2003') includes: version)
		ifFalse: [ Error signal: 'Unknown Fortran version: ' , version , ' choose one of 66 77 77l 77e 90 2003' ].
	fortranVersion := version
]

{ #category : 'private - files' }
FamixFortranImporter >> getIncludedFileName: aString [

	| file |
	file := (Character space split: aString) allButFirst
		detect: [ :token | token isNotEmpty ].

	^self unquoteIncludedFile: file
]

{ #category : 'error management' }
FamixFortranImporter >> hasErrors [

	^errorHandler isNotEmpty
]

{ #category : 'run' }
FamixFortranImporter >> iASTToFamix [

	| visitor |
	visitor := IASTToFamixFortranVisitor new.

	iastmodel do: [ :iastProgramFile |
		errorHandler enterContext: ('file:' , iastProgramFile filename).
		iastProgramFile accept: visitor.
		errorHandler leaveContext
	].

	famixModel := visitor model
]

{ #category : 'private - testing' }
FamixFortranImporter >> iastModel [

	^ iastmodel
]

{ #category : 'private - testing' }
FamixFortranImporter >> iastModel: anObject [

	iastmodel := anObject
]

{ #category : 'run' }
FamixFortranImporter >> import [

	srcFolder ifNil: [ Warning signal: 'Set source folder first' ].

	UIManager default 
		displayProgress: ''
		from: 0 
		to: (self importSteps size - 1)
		during: [ :bar |
			self importSteps withIndexDo: [ :step :i |
				bar label: step key.
				bar current: i.

				errorHandler
					handleErrorsFor: step value
					running: [ self perform: step value ]
			] 
		].

	^ famixModel
]

{ #category : 'run' }
FamixFortranImporter >> importSteps [
	^{
		'Converting included files to Esope' -> #includedFilesToEsope .
		'De-Esopifying files' -> #esopeToFortran .
		'Fortran to JSon AST' -> #fortranToJsonAST .

		'JSon AST to Intermediary AST' -> #jsonASTToIAST .
		'Intermediary AST to Famix' -> #iASTToFamix .
		'Famix symbol resolution' -> #famixResolve .

		'Post import sanity checks' -> #postImportChecks
	}
]

{ #category : 'accessing' }
FamixFortranImporter >> includeFolder [

	^ includeFolder ifNil: [ self sourceFolder ]
]

{ #category : 'accessing' }
FamixFortranImporter >> includeFolder: folder [
	"folder is either a String of a FileReference"

	includeFolder := folder isString
		ifTrue: [ folder asFileReference ]
		ifFalse: [ folder ]

]

{ #category : 'run' }
FamixFortranImporter >> includedFilesToEsope [

	withEsope ifFalse: [ ^self ].

	self collectIncludedFileNames
		do: [ :fileName |
			errorHandler enterContext: fileName.

			(self pathOf: fileName in: self includeFolder)
			ifNotNil: [ :srcFile |
				self fakeEsopeProgramUnit: srcFile from: includeFolder to: self tempEsopeFolder / 'inc'].

			errorHandler leaveContext
		]
]

{ #category : 'private - files' }
FamixFortranImporter >> includedNamesIn: srcFileReference [
	"finds all file inclusions from srcFileReference"

	| value |
	errorHandler	enterContext: 'file:' , srcFileReference fullName.

	value := srcFileReference
		readStreamEncoded: self defaultFileEncoding
		do: [ :stream |
			stream contents lines
				select: [ :line | self isIncludeLine: line]
				thenCollect: [ :line | self getIncludedFileName: line ]
		].

	errorHandler leaveContext.
	
	^value

]

{ #category : 'run' }
FamixFortranImporter >> initialize [

	super initialize.

	withEsope := true.
	withSanityChecks := true.

	errorHandler := FortranErrorManager new.
	errorHandler stopOnError: self stopOnError.

]

{ #category : 'private - files' }
FamixFortranImporter >> isIncludeLine: aString [

	(aString beginsWith: '#include ' caseSensitive: false) ifTrue: [ ^true ].
	(aString beginsWith: '%INC ' caseSensitive: false) ifTrue: [ ^true ].
	(aString beginsWith: 'include ' caseSensitive: false) ifTrue: [ ^true ].

	^false
]

{ #category : 'run' }
FamixFortranImporter >> jsonASTToIAST [

	| visitor |
	visitor := JsonToIASTVisitor new.

	iastmodel := (self tempJsonFolder allFiles) 
		collect: [ :jsonFile | | iastEntity jsonDOM code |
			code := jsonFile contents.
			iastEntity := nil.
			jsonDOM := nil.
			errorHandler enterContext: jsonFile fullName.

			[ jsonDOM := NeoJSONReader fromString: code ]
			on: NeoJSONParseError
			do: [  JsonASTParseException signal: code ].
		
		 	jsonDOM ifNotNil: [ iastEntity := visitor visitProgramFile: jsonDOM ].
			
			errorHandler leaveContext.
			iastEntity
		]
	thenReject: #isNil

]

{ #category : 'private - helpers' }
FamixFortranImporter >> newLine [

	^ OSPlatform current lineEnding
]

{ #category : 'private - import' }
FamixFortranImporter >> newResolver [

	^resolver := (FamixEsopeResolver on: famixModel)
		errorHandler: errorHandler
]

{ #category : 'accessing' }
FamixFortranImporter >> noEsope [

	withEsope := false
]

{ #category : 'private - import' }
FamixFortranImporter >> parseFortran77: srcFile from: srcDir to: destDir [
	"runs fortran77 parser on localPath in srcDir to JSON file in destDir"

	| localizedFile destFile cmdReturn |

	localizedFile := srcFile relativeTo: srcDir.
	destFile := (self appendPath: localizedFile toParent: destDir) withExtension: 'json'.
	destFile ensureCreateFile.

	cmdReturn := self parseFortran77File: srcFile to: destFile.

	(cmdReturn = 0) ifTrue: [ ^self ].

	errorHandler error: 'Error while parsing ' , srcFile pathString.
	destFile ensureDelete

]

{ #category : 'private - import' }
FamixFortranImporter >> parseFortran77File: srcFileReference to: destFileReference [

	^LibC runCommand: (
		'{1} "{2}" > "{3}" 2>&1'
		format: {
			self f77parser .
			srcFileReference fullName .
			destFileReference fullName
		}
	)
]

{ #category : 'private - files' }
FamixFortranImporter >> pathOf: includedFileName in: folder [
	"search for includedFileName in #folder or sub-folders
	 Returns the first path to the file relative to #folder.
	 Returns nil if no such includedFileName is found
	 Note: includedFileName may be a path : 'lib/blah.h'"

	(folder / includedFileName) exists ifTrue: [
		^ folder / includedFileName ].

	folder children do: [ :child |
		child isDirectory
		ifTrue: [
			(self pathOf: includedFileName in: child)
			ifNotNil: [ :found | ^found ]
		]
	].

	^ nil
]

{ #category : 'run' }
FamixFortranImporter >> postImportChecks [

	withSanityChecks ifTrue: [
		famixModel entities do: [ :entity |
			errorHandler enterContext: entity asString.
			entity famixImportSanityCheck.
			errorHandler leaveContext
		]
	]
]

{ #category : 'accessing' }
FamixFortranImporter >> sourceFolder [

	^srcFolder 
]

{ #category : 'accessing' }
FamixFortranImporter >> sourceFolder: folder [
	"folder is either a String or a FileReference"

	srcFolder := folder isString
		ifTrue: [ folder asFileReference ]
		ifFalse: [ folder ]

]

{ #category : 'error management' }
FamixFortranImporter >> stopOnError [

	^errorHandler stop
]

{ #category : 'error management' }
FamixFortranImporter >> stopOnError: anObject [

	errorHandler stopOnError: anObject
]

{ #category : 'private - helpers' }
FamixFortranImporter >> subroutineNamed: name [

	| prefix |

	prefix := '_$'.

	^(name beginsWith: prefix)
		ifTrue: [ name ]
		ifFalse: [ prefix , name ]
]

{ #category : 'accessing' }
FamixFortranImporter >> tempEsopeFolder [

	^tempEsopeFolder
		ifNil: [
			tempEsopeFolder := self ensureEmptyFolder: FamixFortranImporter workingEsopeName asFileReference
		]

]

{ #category : 'accessing' }
FamixFortranImporter >> tempFortranFolder [

	^tempFortranFolder
		ifNil: [
			tempFortranFolder := self ensureEmptyFolder: FamixFortranImporter workingFortranName asFileReference
		]

]

{ #category : 'accessing' }
FamixFortranImporter >> tempJsonFolder [

	^tempJsonFolder
		ifNil: [
			tempJsonFolder := self ensureEmptyFolder: FamixFortranImporter workingJsonName asFileReference
		]

]

{ #category : 'private - files' }
FamixFortranImporter >> unquoteIncludedFile: fileName [
	"returns the name of an included file in an include line, without optional quotes"

	^(#( $" $< ) includes: fileName first)
		ifTrue: [ fileName copyFrom: 2 to: fileName size -1 ]
		ifFalse: [ fileName ]
]

{ #category : 'accessing' }
FamixFortranImporter >> withEsope [

	^withEsope
]

{ #category : 'accessing' }
FamixFortranImporter >> withSanityChecks [

	^ withSanityChecks
]

{ #category : 'accessing' }
FamixFortranImporter >> withSanityChecks: anObject [

	withSanityChecks := anObject
]

{ #category : 'private - helpers' }
FamixFortranImporter >> writeFakeEsopeProgramUnit: name from: content on: writeStream [

	writeStream
		<< '      subroutine ';
		<< (self subroutineNamed: name);
		<< self newLine;
		<< content.
	(content isNotEmpty and: [ String crlf includes: content last ])
		ifFalse: [ writeStream << self newLine ].
	writeStream
		<< '      end';
		<< self newLine
]
