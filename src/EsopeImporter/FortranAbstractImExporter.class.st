Class {
	#name : #FortranAbstractImExporter,
	#superclass : #Object,
	#category : #'EsopeImporter-Importer'
}

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> annotateEsopeSourcesFrom [

	(self srcPath allChildrenMatching: '*.E') do: [ :esopeFile | 
		PPEsopeRewriter
			rewriteFrom: esopeFile
			to: (self rewriterPath / ('' join: { 
						  (esopeFile basename removeSuffix: self esopeSuffix).
						  self fortranSuffix })) pathString ]
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> buildPath [

	^ (self rootPath / self buildPathName) asFileReference ensureCreateDirectory
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> buildPathName [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> esopeSuffix [

	^ '.E'
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> exportAstFrom: astFile [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> exportToEsope [

	(self parserPath allChildrenMatching: self jsonFileRegex) do: [ 
		:astFile | self exportAstFrom: astFile ]
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> f77FileRegex [

	^ '*.f'
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> f77parser [

	^ 'fortran-src-extras serialize -t json -v77l encode'
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> fortranSuffix [

	^ '.f'
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> fromPath: srcPath [

	self subclassResponsibility
]

{ #category : #'instance creation' }
FortranAbstractImExporter class >> handleIncludedFiles [

	(self srcPath allChildrenMatching: '*.inc') do: [ :includedFile | 
		(self srcPath / ('' join: { 
				  includedFile basename.
				  '.E' })) pathString asFileReference writeStreamDo: [ :tmpStream | 
			tmpStream
				<< '      subroutine __$__';
				<< Character cr;
				<< includedFile contents;
				<< '      end';
				<< Character cr ] ]
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> jsonFileRegex [

	^ '*.json'
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> jsonSuffix [

	^ '.json'
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> parseAnnotatedFortranSources [

	(self rewriterPath allChildrenMatching: self f77FileRegex) do: [ 
		:annotatedFile | self parseToAst: annotatedFile ]
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> parseToAst: f77file [

	| outputFile |
	outputFile := self parserPath
	              / (f77file basename removeSuffix: self fortranSuffix).
	LibC runCommand: ('{1} "{2}" > "{3}.json" 2> "{3}.err"' format: { 
				 self f77parser.
				 f77file pathString.
				 outputFile pathString })
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> parserPath [

	^ (self buildPath / self parserPathName) asFileReference ensureCreateDirectory
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> parserPathName [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> rewritedEsopeSuffix [

	^ '.E'
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> rewriterPath [

	^ (self buildPath / self rewriterPathName) asFileReference ensureCreateDirectory
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> rewriterPathName [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> rootPath [

	^ self rootPathName asPath
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> rootPathName [

	self subclassResponsibility

]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> searchPaths [

	^ { self srcPath }
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> srcPath [

	^ (self rootPath / self srcPathName) asFileReference
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> srcPathName [

	self subclassResponsibility
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> targetPath [

	^ (self buildPath / self targetPathName) asFileReference ensureCreateDirectory
]

{ #category : #'private - accessing' }
FortranAbstractImExporter class >> targetPathName [

	self subclassResponsibility
]
