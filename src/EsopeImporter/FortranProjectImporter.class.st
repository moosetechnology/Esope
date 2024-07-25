"
Responsible to import an Esope project into a Famix model

To use:

## Build an Esope model

change `/path/to/...` in the importer initialiser, regardless of your project's path

### Initialise the project importer
```st
importer := FortranProjectImporter new
	srcFolders:  { '/path/to/source'. '/path/to/anothersource' };
 	includeFolders: { '/path/to/include'. '/path/to/anotherinclude' };
	yourself.
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




### Check the importer errors

If an error occurs while importing the project, it will be reported to the importer's `errorHandler` instance variable

```st
error := importer errorHandler.
```
"
Class {
	#name : #FortranProjectImporter,
	#superclass : #Object,
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
		'srcFolder'
	],
	#category : #'EsopeImporter-Importer'
}

{ #category : #importing }
FortranProjectImporter class >> import [
	<script>
	^self new
		import
]

{ #category : #testing }
FortranProjectImporter class >> isDummySubroutine: aName [
	"name matches: _$ + a sequence of at least one character"

	^ '_$#*' match: aName
]

{ #category : #importing }
FortranProjectImporter class >> parseString: fortranCode [

	| srcFile destFile |
	srcFile  := './srcCode.f' asFileReference ensureDelete.
	destFile := './srcCode.json' asFileReference ensureDelete.

	srcFile writeStreamDo: [ :stream | 
		stream << fortranCode withUnixLineEndings ].

	self new
		parseFortran77File: srcFile to: destFile.

	^destFile contents
]

{ #category : #'private - files' }
FortranProjectImporter >> appendPath: aPath toParent: aFolder [
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

{ #category : #'private - files' }
FortranProjectImporter >> collectFilesIn: aFileReference [

	^aFileReference isDirectory
		ifTrue: [ aFileReference children flatCollect: [ :child | self collectFilesIn: child  ] ]
		ifFalse: [ { aFileReference } ]
]

{ #category : #'private - files' }
FortranProjectImporter >> collectFilesIn: srcFileReference withExtensions: extensions [

	^(self collectFilesIn: srcFileReference)
		select: [ :file | extensions includes: file extension ]
]

{ #category : #'private - files' }
FortranProjectImporter >> collectIncludedFileNames [

	^(self collectFilesIn: srcFolder withExtensions: self extensionsEsope)
		flatCollectAsSet: [ :srcFileReference | self includedNamesIn: srcFileReference]
]

{ #category : #'private - files' }
FortranProjectImporter >> copy: aPath from: src to: dest [

	| localizedPath |
	localizedPath := aPath relativeTo: src.
	aPath asFileReference
		copyTo: (self appendPath: localizedPath toParent: dest)
]

{ #category : #'private - import' }
FortranProjectImporter >> deEsopify: srcFile from: sourceFolder to: destFolder [
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

{ #category : #accessing }
FortranProjectImporter >> defaultFileEncoding [
	"other possibilities are 'latin1', 'utf8', ...
	see `ZnCharacterEncoder knownEncodingIdentifiers` for all possibilities"

	^defaultFileEncoding ifNil: [ 'iso-8859-1' ]
]

{ #category : #accessing }
FortranProjectImporter >> defaultFileEncoding: aString [
	"other possibilities are 'latin1', 'utf8', ...
	see `ZnCharacterEncoder knownEncodingIdentifiers` for all possibilities"

	defaultFileEncoding := aString
]

{ #category : #'private - files' }
FortranProjectImporter >> ensureEmptyFolder: folder [

	folder exists ifTrue: [ folder deleteAll  ].
	folder ensureCreateDirectory.
	^folder
]

{ #category : #'error management' }
FortranProjectImporter >> errorHandler [

	^ errorHandler ifNil: [ errorHandler := FortranErrorManager new ]
]

{ #category : #'error management' }
FortranProjectImporter >> errorHandler: anObject [

	errorHandler := anObject
]

{ #category : #'error management' }
FortranProjectImporter >> errors [

	^errorHandler errors
]

{ #category : #run }
FortranProjectImporter >> esopeToFortran [
	"'de-esopifying Esope files to be able to parse them in Fortran
	The result goes in the FortranWorkingDirectory"

	(self collectFilesIn: self tempEsopeFolder) do: [ :path |
		self
			deEsopify: path
			from: self tempEsopeFolder
			to: self tempFortranFolder
		].

	(self collectFilesIn: srcFolder withExtensions: self extensionsEsope) do: [ :srcFile |
		"self copy: srcFile from: srcFolder to: (self tempEsopeFolder / 'src')."
		self
			deEsopify: srcFile
			from: srcFolder
			to: (self tempFortranFolder / 'src')
		]
]

{ #category : #constants }
FortranProjectImporter >> extensionsEsope [
	"Add F and fc as esope files in order to let the ReWriter handle the include statement for this type of file"

	^#(E ec e F fc)
]

{ #category : #constants }
FortranProjectImporter >> extensionsFortran [

	^#(f for)
]

{ #category : #accessing }
FortranProjectImporter >> f77parser [

	^ 'fortran-src-extras serialize -t json -v77l encode '
]

{ #category : #'private - import' }
FortranProjectImporter >> fakeEsopeProgramUnit: includedFile from: sourceFolder to: workingEsopeFolder [
	"creates a fake programUnit from an includedFile"

	| localizedSrcFile destFile |
	localizedSrcFile := includedFile relativeTo: sourceFolder.

	destFile := (workingEsopeFolder / localizedSrcFile pathString) , 'E'.
	destFile ensureCreateFile.

	destFile writeStreamDo: [ :tmpStream |
		tmpStream
			<< '      subroutine _$' ;
			<< (includedFile basename copy replaceAll: $. with: $_) ;
			cr ;
			<< includedFile contents ;
			<< '      end' ;
			cr ]
]

{ #category : #accessing }
FortranProjectImporter >> famixModel [

	^ famixModel
]

{ #category : #accessing }
FortranProjectImporter >> famixModel: anObject [

	famixModel := anObject
]

{ #category : #run }
FortranProjectImporter >> famixResolve [
	"creates a resolver and resolve all pending names"

	self newResolver
		resolve.

]

{ #category : #run }
FortranProjectImporter >> fortranToJsonAST [
	"Goes through all Fortran-77 files and parses each one to produce a corresponding Json AST
	 - 1st, de-esopified files
	 - 2nd, pure Fortran files"

	(self collectFilesIn: self tempFortranFolder) do: [ :localPath |
		self parseFortran77: localPath from: self tempFortranFolder to: self tempJsonFolder ].

	(self collectFilesIn: srcFolder withExtensions: self extensionsFortran) do: [ :projectPath |
		| localPath |
		localPath := projectPath relativeTo: srcFolder.
		"projectPath asFileReference
			copyTo: (self appendPath: localPath toParent: tempFortranFolder / 'src')."
		self parseFortran77: projectPath from: srcFolder to: self tempJsonFolder / 'src' ]
]

{ #category : #'private - files' }
FortranProjectImporter >> getIncludedFileName: aString [

	| file |
	file := (Character space split: aString) allButFirst
		detect: [ :token | token isNotEmpty ].

	^self unquoteIncludedFile: file
]

{ #category : #'error management' }
FortranProjectImporter >> hasErrors [

	^errorHandler isNotEmpty
]

{ #category : #run }
FortranProjectImporter >> iASTToFamix [

	| visitor |
	visitor := IASTToFamixFortranVisitor new.

	iastmodel do: [ :iastProgramFile |
		errorHandler enterContext: ('file:' , iastProgramFile filename).
		iastProgramFile accept: visitor.
		errorHandler leaveContext
	].

	famixModel := visitor model
]

{ #category : #'private - testing' }
FortranProjectImporter >> iastModel [

	^ iastmodel
]

{ #category : #'private - testing' }
FortranProjectImporter >> iastModel: anObject [

	iastmodel := anObject
]

{ #category : #run }
FortranProjectImporter >> import [

	srcFolder ifNil: [ Warning signal: 'Set source folder first' ].

	errorHandler := FortranErrorManager new.
	errorHandler stopOnError: self stopOnError.

	UIManager default displayProgress: ''
		from: 0 to: (self importSteps size - 1)
		during: [:bar |
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

{ #category : #run }
FortranProjectImporter >> importSteps [
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

{ #category : #accessing }
FortranProjectImporter >> includeFolder [

	^ includeFolder ifNil: [ self sourceFolder ]
]

{ #category : #accessing }
FortranProjectImporter >> includeFolder: folder [
	"folder is either a String of a FileReference"

	includeFolder := folder isString
		ifTrue: [ folder asFileReference ]
		ifFalse: [ folder ]

]

{ #category : #run }
FortranProjectImporter >> includedFilesToEsope [

	self collectIncludedFileNames
		do: [ :fileName |
			errorHandler enterContext: fileName.

			(self pathOf: fileName in: self includeFolder)
			ifNotNil: [ :srcFile |
				self fakeEsopeProgramUnit: srcFile from: includeFolder to: self tempEsopeFolder / 'inc'].

			errorHandler leaveContext
		]
]

{ #category : #'private - files' }
FortranProjectImporter >> includedNamesIn: srcFileReference [
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

{ #category : #'private - files' }
FortranProjectImporter >> isIncludeLine: aString [

	(aString beginsWith: '#include ' caseSensitive: false) ifTrue: [ ^true ].
	(aString beginsWith: '%INC ' caseSensitive: false) ifTrue: [ ^true ].
	(aString beginsWith: 'include ' caseSensitive: false) ifTrue: [ ^true ].

	^false
]

{ #category : #run }
FortranProjectImporter >> jsonASTToIAST [

	| visitor iastEntity |
	visitor := JsonToIASTVisitor new.

	iastmodel := (self tempJsonFolder allFiles) 
		collect: [ :jsonFile | 
			errorHandler enterContext: jsonFile fullName.
			iastEntity := visitor visitProgramFile:
				(NeoJSONReader fromString: jsonFile contents).
			errorHandler leaveContext.
			iastEntity
		]

]

{ #category : #'private - import' }
FortranProjectImporter >> newResolver [

	^resolver := (FamixEsopeResolver on: famixModel)
		errorHandler: errorHandler
]

{ #category : #'private - import' }
FortranProjectImporter >> parseFortran77: srcFile from: src to: dest [
	"runs fortran77 parser on localPath in srcFolder to JSON file in destFolder"

	| localizedFile destFile cmdReturn |

	localizedFile := srcFile relativeTo: src.
	destFile := (self appendPath: localizedFile toParent: dest) withExtension: 'json'.
	destFile ensureCreateFile.

	cmdReturn := self parseFortran77File: srcFile to: destFile.

	(cmdReturn = 0) ifTrue: [ ^self ].

	errorHandler error: 'Error while parsing ' , srcFile pathString.
	destFile ensureDelete

]

{ #category : #'private - import' }
FortranProjectImporter >> parseFortran77File: srcFileReference to: destFileReference [

	^LibC runCommand: (
		'{1} "{2}" > "{3}" 2>&1'
		format: {
			self f77parser .
			srcFileReference fullName .
			destFileReference fullName
		}
	)
]

{ #category : #'private - files' }
FortranProjectImporter >> pathOf: includedFileName in: folder [
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

{ #category : #run }
FortranProjectImporter >> postImportChecks [

	withSanityChecks ifTrue: [
		famixModel entities do: [ :entity |
			errorHandler enterContext: entity asString.
			entity famixImportSanityCheck.
			errorHandler leaveContext
		]
	]
]

{ #category : #accessing }
FortranProjectImporter >> sourceFolder [

	^srcFolder 
]

{ #category : #accessing }
FortranProjectImporter >> sourceFolder: folder [
	"folder is either a String or a FileReference"

	srcFolder := folder isString
		ifTrue: [ folder asFileReference ]
		ifFalse: [ folder ]

]

{ #category : #'error management' }
FortranProjectImporter >> stopOnError [

	^ stopOnError ifNil: [ false ]
]

{ #category : #'error management' }
FortranProjectImporter >> stopOnError: anObject [

	stopOnError := anObject
]

{ #category : #accessing }
FortranProjectImporter >> tempEsopeFolder [

	^tempEsopeFolder
		ifNil: [
			tempEsopeFolder := self ensureEmptyFolder: self workingEsopeName asFileReference
		]

]

{ #category : #accessing }
FortranProjectImporter >> tempFortranFolder [

	^tempFortranFolder
		ifNil: [
			tempFortranFolder := self ensureEmptyFolder: self workingFortranName asFileReference
		]

]

{ #category : #accessing }
FortranProjectImporter >> tempJsonFolder [

	^tempJsonFolder
		ifNil: [
			tempJsonFolder := self ensureEmptyFolder: self workingJsonName asFileReference
		]

]

{ #category : #'private - files' }
FortranProjectImporter >> unquoteIncludedFile: fileName [
	"returns the name of an included file in an include line, without optional quotes"

	^(#( $" $< ) includes: fileName first)
		ifTrue: [ fileName copyFrom: 2 to: fileName size -1 ]
		ifFalse: [ fileName ]
]

{ #category : #accessing }
FortranProjectImporter >> withSanityChecks [

	^ withSanityChecks
]

{ #category : #accessing }
FortranProjectImporter >> withSanityChecks: anObject [

	withSanityChecks := anObject
]

{ #category : #constants }
FortranProjectImporter >> workingEsopeName [

	^'tmpEsopeImport'
]

{ #category : #constants }
FortranProjectImporter >> workingFortranName [

	^'tmpFortranImport'
]

{ #category : #constants }
FortranProjectImporter >> workingJsonName [
	
	^'tmpJsonImport'
]
