"
I am a ""de-esopifier"", I make Fortran source code from Esope source by ""removing"" Esope specific constructs
"
Class {
	#name : 'PPEsopeRewriter',
	#superclass : 'PPEsopeGrammar',
	#instVars : [
		'stream'
	],
	#category : 'EsopeImporter-Importer',
	#package : 'EsopeImporter',
	#tag : 'Importer'
}

{ #category : 'accessing' }
PPEsopeRewriter class >> ignoredNames [
	^ super ignoredNames , #(stream)
]

{ #category : 'utilities' }
PPEsopeRewriter class >> rewriteFrom: esopeFile to: annotatedFile [
	self new
		rewriteFrom: esopeFile to: annotatedFile
	
]

{ #category : 'transformations' }
PPEsopeRewriter >> applySlashTransformation: inputSource [

	^String new writeStreamDo: [ :oStream |  | regex index |

		regex := '\(\s?(\/)[^/]' asRegexIgnoringCase.
		index := 1.
		(regex matchingRangesIn: inputSource)
		do: [ :interval | "1halt".
			oStream << (inputSource copyFrom: index to: interval first);
				  	  << 'S__';
				     << (inputSource copyFrom: interval first + 1 to: interval last).
			index := interval last + 1 
		].
	   oStream << (inputSource copyFrom: index to: inputSource size).
		oStream contents
	]
]

{ #category : 'transformations' }
PPEsopeRewriter >> applyTransformation: inputSource [

	^(self isFormatStatement: inputSource) 
		ifTrue:  [ inputSource ]
		ifFalse: [ 
			(self isIfLogicalStatementFollowedBySegmentCommand: inputSource)
				ifTrue:  [ 'c@_   ' , (inputSource allButFirst: 6) ]
				ifFalse: [ self applySlashTransformation: inputSource ] 
		]
]

{ #category : 'rules' }
PPEsopeRewriter >> canBeProcessed: aText [
	 ^('Cc*' includes: aText first) or: [ self contains: aText keyword: 'FORMAT']
]

{ #category : 'annotations' }
PPEsopeRewriter >> commentAnnotation [

	^ 'c@_'
]

{ #category : 'transformations' }
PPEsopeRewriter >> commentLine [
	"	^((self terminal: 'C') / (self terminal: '*')) flatten
	, endOfLine negate plus flatten
	, endOfLine"

	^ super commentLine
	==> [ :nodes | 
		self copyTokens: nodes from: 1 to: nodes size
	]
	
]

{ #category : 'utilities' }
PPEsopeRewriter >> contains: text keyword: word [
	^(text asString asUppercase indexOfSubCollection: word asUppercase)
	  ~= 0
]

{ #category : 'transformations' }
PPEsopeRewriter >> containsSegmentCommand: textLine [ 
	
	^{ 'segact'. 'segadj'. 'segdes'. 'segini'. 'segprt'. 'segsup' }
		detect: [ :each | textLine includesSubstring: each caseSensitive: false ]
		ifFound: [ true ]
		ifNone:  [ false ] 
]

{ #category : 'utilities' }
PPEsopeRewriter >> copyLine: nodes from: start to: end [

	start to: end do: [ :i | stream << (nodes at: i) value ]
]

{ #category : 'utilities' }
PPEsopeRewriter >> copyTokens: nodes from: start to: end [

	start to: end do: [ :i | stream << (nodes at: i) ]
]

{ #category : 'annotations' }
PPEsopeRewriter >> dotAnnotation [

	^ 'D__('
]

{ #category : 'transformations' }
PPEsopeRewriter >> dotTransformation: inputSource [

	"The regex we're using treats everything inside the outer parentheses as an index and therefore doesn't apply a transformation to it.
	So it won't work for examples like this: `a.b(c.d)`. 
	Make sure you test (#testEsopeTransformationInsideInvocationOrArraySubscript) and add other situations to cover special cases that may arise."

	^ String new writeStreamDo: [ :outputStream | 
		  | regex index |
		  index := 1.
		  regex := '([a-zA-Z][a-zA-Z0-9_]*)(\.)([a-zA-Z][a-zA-Z0-9_]*)\s?((\([^)]+\))*)'
			           asRegexIgnoringCase.
		  (regex matchingRangesIn: inputSource) do: [ :interval | 
			  | subText indexOfDot |
			  (self
				   fortranOperator: inputSource
				   from: interval first
				   to: interval last) ifFalse: [ 
				  outputStream
				  << (inputSource copyFrom: index to: interval first - 1).
				  index := interval first.
				  subText := inputSource copyFrom: index to: interval last.
				  outputStream << self dotAnnotation.
				  indexOfDot := subText indexOf: $..
				  outputStream
					  << (subText copyFrom: 1 to: indexOfDot - 1);
					  << $,.
				  index := index + indexOfDot.
				  outputStream
					  << (subText copyFrom: indexOfDot + 1 to: subText size);
					  << $).
				  index := interval last + 1 ] ].
		  outputStream << (inputSource copyFrom: index to: inputSource size).
		  outputStream contents ]
]

{ #category : 'accessing' }
PPEsopeRewriter >> endOfLine [
	"(Character cr asPParser / Character lf asPParser) plus flatten"
	
	^ super endOfLine
	==> [ :nodes | String streamContents: [ :str | nodes do: [ :c | str nextPut: c ] ] ]
]

{ #category : 'rules' }
PPEsopeRewriter >> endSegment [

	" beginOfLine
	, optionalBlanks
	, (self terminal: 'end') flatten
	, optionalBlanks
	, (self terminal: 'segment') flatten
	, optionalBlanks
	, endOfLine"

	^ super endSegment
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'rules' }
PPEsopeRewriter >> fortranLine [
	" endOfLine negate star flatten
	, endOfLine"

	^ super fortranLine
	==> [ :nodes |  | line | 
	  line := self sanitize: nodes first.
	  stream
		  << ((self isCommentStatement: line)
				   ifTrue:  [ line ]
				   ifFalse: [ self applyTransformation: line ]);
		  << nodes allButFirst 
	]
]

{ #category : 'utilities' }
PPEsopeRewriter >> fortranOperator: esopeAtIdentifier [

	| uppercaseIdentifier |
	uppercaseIdentifier := esopeAtIdentifier asUppercase.
	^ self logicalOperators anySatisfy: [ :operator | 
		  (uppercaseIdentifier beginsWith: operator) or: [ 
			  uppercaseIdentifier endsWith: operator ] ]
]

{ #category : 'utilities' }
PPEsopeRewriter >> fortranOperator: esopeAtIdentifier from: start to: end [

	| uppercaseIdentifier |
	(start <= 1 or: [ end >= esopeAtIdentifier size ]) ifTrue: [ ^ false ].

	uppercaseIdentifier := (esopeAtIdentifier
		                        copyFrom: start - 1
		                        to: end + 1) asUppercase.
	^ self logicalOperators anySatisfy: [ :operator | 
		  (uppercaseIdentifier beginsWith: operator) or: [ 
			  uppercaseIdentifier endsWith: operator ] ]
]

{ #category : 'private - for tests' }
PPEsopeRewriter >> generatedCode [
	^stream contents
]

{ #category : 'initialization' }
PPEsopeRewriter >> include [
	" (self terminal: '#include') flatten 
	, optionalBlanks
	, includeName
	, optionalBlanks
	, endOfLine"

	^ super include ==> [ :nodes | 
	  stream << 'c@_'.
	  self copyTokens: nodes from: 1 to: nodes size ]
]

{ #category : 'initialization' }
PPEsopeRewriter >> initStream [

	stream := String new writeStream
]

{ #category : 'initialization' }
PPEsopeRewriter >> initialize [
	super initialize.
	
	self initStream
]

{ #category : 'rules' }
PPEsopeRewriter >> isCommentStatement: aText [

	aText ifEmpty: [ ^false ].
	^ 'Cc*' includes: aText first
]

{ #category : 'rules' }
PPEsopeRewriter >> isFormatOrCommentStatement: aText [

	^('Cc*' includes: aText first) 
	or: [ self contains: aText keyword: 'FORMAT' ]
]

{ #category : 'rules' }
PPEsopeRewriter >> isFormatStatement: aText [

	^ self contains: aText keyword: 'FORMAT'
]

{ #category : 'transformations' }
PPEsopeRewriter >> isIfLogicalStatementFollowedBySegmentCommand: textLine [

	^ (textLine trimLeft beginsWith: 'if' caseSensitive: false)
		ifTrue:  [ self containsSegmentCommand: textLine ]
		ifFalse: [ false ]
]

{ #category : 'utilities' }
PPEsopeRewriter >> logicalOperators [

	^ #( '.EQ.' '.LT.' '.LE.' '.GT.' '.GE.' '.NE.' '.OR.' '.AND.' '.NOT.'
	     '.TRUE.' '.FALSE.' '.EQV.' '.NEQV.' )
]

{ #category : 'rules' }
PPEsopeRewriter >> optionalBlanks [
	"#blank asPParser star flatten"

	^ super optionalBlanks
	  ==> [ :nodes | nodes ifNil: [ '' token ] ifNotNil: [ :tk | tk ] ]
]

{ #category : 'rules' }
PPEsopeRewriter >> pointer [

	" beginOfLine
	, optionalBlanks
	, (self terminal: 'pointeur') flatten
	, optionalBlanks
	, endOfLine negate plus flatten
	, endOfLine"

	^ super pointer
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'rules' }
PPEsopeRewriter >> process: line [
	^line
]

{ #category : 'utilities' }
PPEsopeRewriter >> processLinesInsideSegment: anOrderedCollection [

	"  (beginOfLine, 'end' asPParser not, endOfLine negate plus, endOfLine) star"

	" #processLinesInsideSegment 
	There are several ways of handling the components of a segment:
	- option1: let a fortran77 parser handle them for us at this stage. this means not annotating them and having to process them later when parsing the AST obtained by the fortran77 parser by using the position of the token.
	- option2: modify our grammars to handle the components correctly
	- option3: Annotate them, and be a master of regular expressions during ESOPE comment processing.
	"

	"option1: implemented but need to take an account a `pointeur` attribute and hide it"

	"option2: not yet implemented"

	"option3: tested and not approuved.
		""self annotateByEsopePrefix.
		stream << (line at: 3) value.
		self addLineSeparator"""

	anOrderedCollection do: [ :line | "option1"
		line at: 1 put: (self sanitize: line first).
		(self contains: line keyword: 'pointeur') ifTrue: [ line at: 1 put: self commentAnnotation , '   ' ].
		line do: [ :part | part ifNotNil: [ stream << part value ] ] ]
]

{ #category : 'rules' }
PPEsopeRewriter >> processNodes: nodes [
	"Esope line with label need to be treated in a special way:
	 put the Esope comment marker, then put the label, then complete with spaces up to 6th column
	 with 1 space mandatory"
	
	| i |
	stream << self commentAnnotation.

	nodes first first isDigit
	ifFalse: [ stream << '   ' ]
	ifTrue: [
		i := 0.
		nodes first do: [ :c |
			c isDigit
				ifTrue: [
					i := i + 1.
					stream << c
				]
		].
		stream << ' '.
		(6 - self commentAnnotation size - i - 1) timesRepeat: [ stream << ' ' ]].

	^ self copyTokens: nodes from: 2 to: nodes size
]

{ #category : 'utilities' }
PPEsopeRewriter >> replaceCrByLf: aText [
	
	^aText
		copyReplaceAll: String cr
		with: String lf
]

{ #category : 'utilities' }
PPEsopeRewriter >> rewriteFrom: esopeFile to: annotatedFile [
	"Note: end-of-line character may be an issue on none Linux computers
	 Could use `OSPlatform current lineEnding` to get the 'correct line-ending'"

	self parse: esopeFile contents.
	
	annotatedFile writeStreamDo: [ :fileStream |  fileStream << self generatedCode ]
]

{ #category : 'utilities' }
PPEsopeRewriter >> sanitize: aString [

	| firstSixChars index |
	firstSixChars := aString size < 6 
		ifTrue: [ aString ]
		ifFalse: [ aString copyFrom: 1 to: 6 ].

	index := firstSixChars indexOf: (Character tab) ifAbsent: [ 0 ].
	^index > 0
		ifTrue:  [  aString copyReplaceFrom: index to: index with: '        ' ]
		ifFalse: [ aString   ]
]

{ #category : 'rules' }
PPEsopeRewriter >> segact [

	" self esopeLine: 'segact'"

	^ super segact
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'rules' }
PPEsopeRewriter >> segadj [

	"self esopeLine: 'segadj'"

	^ super segadj
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'rules' }
PPEsopeRewriter >> segdes [

	"self esopeLine: 'segdes'"

	^ super segdes
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'rules' }
PPEsopeRewriter >> segini [

	"self esopeLine: 'segini'"

	^ super segini
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'rules' }
PPEsopeRewriter >> segment [

	"self esopeLine: 'segment'"

	^ super segment
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'rules' }
PPEsopeRewriter >> segprt [

	"self esopeLine: 'segprt'"

	^ super segprt
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'rules' }
PPEsopeRewriter >> segsup [

	"self esopeLine: 'segsup'"

	^ super segsup
	==> [ :nodes | self processNodes: nodes ]
]

{ #category : 'annotations' }
PPEsopeRewriter >> slashAnnotation [

	^ 'S__('
]

{ #category : 'transformations' }
PPEsopeRewriter >> slashTransformation: inputSource [

	^ String new writeStreamDo: [ :outputStream | 
		  | regex index |
		  index := 1.
		  regex := '(([a-zA-Z][a-zA-Z0-9_]*)(\.))*([a-zA-Z][a-zA-Z0-9_]*)\s?(\(\/[^)]+\))'
			           asRegexIgnoringCase.
		  (regex matchingRangesIn: inputSource) do: [ :interval | 
			  | subText indexOfDot |
			  (self
				   fortranOperator: inputSource
				   from: interval first
				   to: interval last) ifFalse: [ 
				  | attrPart dimsPart |
				  outputStream
				  << (inputSource copyFrom: index to: interval first - 1).
				  index := interval first.
				  subText := inputSource copyFrom: index to: interval last.
				  indexOfDot := subText indexOf: $..
				  attrPart := subText copyUpToSubstring: '(/'.
				  dimsPart := subText
					              copyFrom: attrPart size + 3
					              to: subText size - 1.
				  indexOfDot = 0 ifFalse: [ 
					  attrPart := String new writeStreamDo: [ :dotPartStream | 
						              dotPartStream
							              << self dotAnnotation;
							              << (attrPart copyFrom: 1 to: indexOfDot - 1);
							              << $,;
							              <<
								              (attrPart
									               copyFrom: indexOfDot + 1
									               to: attrPart size);
							              << ')'.
						              dotPartStream contents ] ].
				  outputStream
					  << self slashAnnotation;
					  << attrPart trim;
					  << $,;
					  << dimsPart trim;
					  << $).
				  index := interval last + 1 ] ].
		  outputStream << (inputSource copyFrom: index to: inputSource size).
		  outputStream contents ]
]
