"
Extracts Esope constructs from an fortran-77 file without having grammar for the whole fortran-77. 

Try can try with:

`PPEsopeGrammar example`

The example starts take a Esope source file and hide then either in comment or in function invocations.
"
Class {
	#name : #PPEsopeGrammar,
	#superclass : #PP2CompositeNode,
	#instVars : [
		'file',
		'include',
		'includeName',
		'pointer',
		'segact',
		'segadj',
		'segdes',
		'segini',
		'segsup',
		'endOfLine',
		'beginOfLine',
		'fortranLine',
		'emptyLine',
		'optionalBlanks',
		'endSegment',
		'segment',
		'segprt',
		'commentLine',
		'anyLine'
	],
	#category : #'EsopeImporter-Rewriter'
}

{ #category : #utility }
PPEsopeGrammar class >> getSourceFromFile: filename [
	^ filename asFileReference contents asText
]

{ #category : #tokens }
PPEsopeGrammar >> beginOfLine [

	^( '      ' asPParser / Character tab asPParser) flatten
]

{ #category : #grammar }
PPEsopeGrammar >> commentLine [
	^((self terminal: 'C') / (self terminal: '*')) flatten
	, endOfLine negate plus flatten
	, endOfLine
	
]

{ #category : #accessing }
PPEsopeGrammar >> emptyLine [

	^ optionalBlanks , endOfLine
]

{ #category : #tokens }
PPEsopeGrammar >> endOfLine [

	^ (Character cr asPParser / Character lf asPParser) plus flatten
]

{ #category : #'grammar-helper' }
PPEsopeGrammar >> endSegment [

	^ beginOfLine , optionalBlanks , endToken , optionalBlanks
	  , segmentToken , optionalBlanks , endOfLine
]

{ #category : #'grammar-helper' }
PPEsopeGrammar >> esopeLine: esopeKeyword [

	^ beginOfLine , optionalBlanks
	  , (self terminal: esopeKeyword) flatten , segIdentifier
	  , optionalBlanks , endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> file [

	^ (segment / segact / segadj / segdes / segini / segprt / segsup / pointer
	   / include / fortranLine / emptyLine) plus
]

{ #category : #grammar }
PPEsopeGrammar >> fortranLine [

	^ endOfLine negate star flatten , endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> include [

	self flag: #FIXME. "Not Esope/Fortran, `c/c++` preprocessor directive. But used to include segment definition, ..."

	^ (self terminal: '#include') flatten , optionalBlanks , includeName
	  , optionalBlanks , endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> includeName [

	^ ((self symbol: $") , identifier , dotToken , identifier
	   , (self symbol: $")) flatten
	  / ((self symbol: $<) , identifier , dotToken , identifier
		   , (self symbol: $>)) flatten
]

{ #category : #tokens }
PPEsopeGrammar >> optionalBlanks [

	^ #blank asPParser star flatten
]

{ #category : #grammar }
PPEsopeGrammar >> pointer [

	"^ beginOfLine
	, optionalBlanks 
	, pointerKeyWord
	, optionalBlanks
	, pointerName
	, optionalBlanks
	, endOfLine"
	
	^beginOfLine
	, optionalBlanks
	, pointerKeyWord
	, optionalBlanks
	, endOfLine negate plus flatten
	, endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> segact [

	^ self esopeLine: 'segact'
]

{ #category : #grammar }
PPEsopeGrammar >> segadj [

	^ self esopeLine: 'segadj'
]

{ #category : #grammar }
PPEsopeGrammar >> segdes [

	^ self esopeLine: 'segdes'
]

{ #category : #grammar }
PPEsopeGrammar >> segini [

	^ self esopeLine: 'segini'
]

{ #category : #grammar }
PPEsopeGrammar >> segment [

	^ (self esopeLine: 'segment') 
	, (commentLine / notEndLine ) star
	, endSegment
]

{ #category : #grammar }
PPEsopeGrammar >> segprt [

	^ self esopeLine: 'segprt'
]

{ #category : #grammar }
PPEsopeGrammar >> segsup [

	" ^ beginOfLine , optionalBlanks , self terminal:
		  'segsup' , segIdentifier , endOfLine"
	^ self esopeLine: 'segsup'
]

{ #category : #grammar }
PPEsopeGrammar >> start [
	^ file end
]

{ #category : #'grammar-helper' }
PPEsopeGrammar >> terminal: aString [
	^ aString asPParser caseInsensitive
]
