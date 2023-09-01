"
Given a directory containing esope source files, this class rewrites the esope source files to be parsable by traditional fortran-77 parser. The resulting ASTs are used to build a moose model from which we regenerate ""original"" esope source files.

`BookstoreExporter export`
"
Class {
	#name : #BookstoreExporter,
	#superclass : #FortranAbstractImExporter,
	#category : #'EsopeImporter-demos'
}

{ #category : #'private - accessing' }
BookstoreExporter class >> buildPathName [

	^ 'build'
]

{ #category : #'private - accessing' }
BookstoreExporter class >> export [

	<script>
	self fromPath: self srcPath
]

{ #category : #'private - accessing' }
BookstoreExporter class >> exportAstFrom: astFile [

	| exporter outputFile |
	exporter := FASTFortranJsonExporterVisitor new.
	exporter visitProgramFile:
		(NeoJSONReader fromString: astFile contents).
	outputFile := self targetPath / ('' join: { 
			               (astFile basename removeSuffix: self jsonSuffix).
			               self rewritedEsopeSuffix }).
	outputFile asFileReference writeStreamDo: [ :stream | 
		stream truncate.
		stream
		<<
		(exporter output contents
			 replaceAll: Character cr
			 with: Character lf) ]
]

{ #category : #example }
BookstoreExporter class >> fromPath: srcPath [
	"
	1. #annotateEsopeSourcesFrom: Rewrite Esope source file by hidden ""all"" the esope constructs
	            +----------+
	==> *.E --> | ReWriter | --> *.E.f
	            +----------+
	
	2. #parseAnnotatedFortranSources: use a traditional fortran77 parser to parse to input source and produce an AST in json format.
	
	           +-----------+
	 *.E.f --> | F77Parser | --> AST (json)
	           +-----------+
	
	3. #exportToEsope: apply an visitor in AST and reproduce the original code
	
	                +-----------+
	 *.ast.json --> | Exporter  | --> *.E.copy
	                +-----------+
	"
	srcPath exists ifFalse: [ ^ self ].

	self handleIncludedFiles.
	self annotateEsopeSourcesFrom.
	self parseAnnotatedFortranSources.
	self exportToEsope
]

{ #category : #'private - accessing' }
BookstoreExporter class >> parserPathName [

	^ 'parser'
]

{ #category : #'private - accessing' }
BookstoreExporter class >> rewriterPathName [

	^ 'rewriter'
]

{ #category : #configuration }
BookstoreExporter class >> rootPathName [

	^ '/tmp/bookstore'
]

{ #category : #'private - accessing' }
BookstoreExporter class >> srcPathName [

	^ 'src'
]

{ #category : #'private - accessing' }
BookstoreExporter class >> targetPathName [

	^ 'target'
]
