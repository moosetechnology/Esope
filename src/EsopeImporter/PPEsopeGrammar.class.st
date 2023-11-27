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
		'pointerName',
		'segact',
		'segadj',
		'segdes',
		'segini',
		'segsup',
		'notEndLine',
		'lines',
		'identifier',
		'endOfLine',
		'beginOfLine',
		'segIdentifier',
		'fortranLine',
		'emptyLine',
		'optionalBlanks',
		'endToken',
		'segmentToken',
		'dotToken',
		'pointerKeyWord',
		'endSegment',
		'segment',
		'segprt',
		'commentLine'
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

{ #category : #tokens }
PPEsopeGrammar >> dotToken [

	^ self symbol: $.
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

{ #category : #tokens }
PPEsopeGrammar >> endToken [

	^ (self terminal: 'end') flatten
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

{ #category : #tokens }
PPEsopeGrammar >> identifier [

	^ (#letter asPParser , #word asPParser star) flatten
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

{ #category : #grammar }
PPEsopeGrammar >> lines [

	^ notEndLine star
]

{ #category : #grammar }
PPEsopeGrammar >> notEndLine [

	^ beginOfLine 
	 , optionalBlanks
	  , (self terminal: 'end') not 
	  , endOfLine negate plus flatten
	  , endOfLine
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

{ #category : #tokens }
PPEsopeGrammar >> pointerKeyWord [

	^ (self terminal: 'pointeur') flatten
]

{ #category : #tokens }
PPEsopeGrammar >> pointerName [

	^ (identifier , dotToken , identifier) flatten
]

{ #category : #tokens }
PPEsopeGrammar >> segIdentifier [

	^ endOfLine negate plus flatten
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

{ #category : #tokens }
PPEsopeGrammar >> segmentToken [

	^ (self terminal: 'segment') flatten
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
PPEsopeGrammar >> symbol: aLetter [

	^ aLetter asPParser caseInsensitive
]

{ #category : #'grammar-helper' }
PPEsopeGrammar >> terminal: aString [
	^ aString asPParser caseInsensitive
]
