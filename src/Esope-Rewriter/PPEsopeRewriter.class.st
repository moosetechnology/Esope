Class {
	#name : #PPEsopeRewriter,
	#superclass : #PPEsopeGrammar,
	#instVars : [
		'stream'
	],
	#category : #'Esope-Rewriter-Parser'
}

{ #category : #accessing }
PPEsopeRewriter class >> ignoredNames [
	^ super ignoredNames , #(stream)
]

{ #category : #regex }
PPEsopeRewriter class >> regexForEsopeWithArray [

	self flag: #FIXME. "how to deal with: ur.ubb(jr + 1).
	By now, we have ESOat(ur, ubb)(jr+1) instead of ESOar(ESOat(ub, ubb), jr + 1).
	By now we are not able to process this kind of statement when the subscript is an expression and not a litteral integer"
	"Using PetitParser2 instead of regex"

	^ '([a-zA-Z][a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z0-9]+)\(([^)]+)\)'
		  asRegexIgnoringCase
]

{ #category : #regex }
PPEsopeRewriter class >> regexForEsopeWithDot [

	^ '[a-zA-Z][a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z0-9]+' asRegexIgnoringCase
]

{ #category : #regex }
PPEsopeRewriter class >> regexForEsopeWithSlash [

	^ '([a-zA-Z][a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z0-9]+)\(/[^)]+\)'
		  asRegexIgnoringCase
]

{ #category : #utilities }
PPEsopeRewriter class >> rewriteFrom: esopeFile to: annotatedFile [

	| rewriter |
	rewriter := self new.
	rewriter parse: esopeFile.
	annotatedFile asFileReference writeStreamDo: [ :stream | 
		stream truncate.
		stream << (rewriter output
			 replaceAll: Character cr
			 with: Character lf) ]
]

{ #category : #rules }
PPEsopeRewriter >> addLineSeparator [

	stream << Character cr
]

{ #category : #rules }
PPEsopeRewriter >> annotateByEsopePrefix [

	stream << 'cESO  '
]

{ #category : #transformations }
PPEsopeRewriter >> applyTransformation: inputSource [

	^ self dotTransformation: (self slashTransformation: inputSource)
]

{ #category : #utilities }
PPEsopeRewriter >> copyLine: nodes from: start to: end [

	start to: end do: [ :i | stream << (nodes at: i) value ]
]

{ #category : #utilities }
PPEsopeRewriter >> copyTokens: nodes from: start to: end [

	start to: end do: [ :i | stream << (nodes at: i) ]
]

{ #category : #annotations }
PPEsopeRewriter >> dotAnnotation [

	^ 'D__('
]

{ #category : #transformations }
PPEsopeRewriter >> dotTransformation: inputSource [

	^ String new writeStreamDo: [ :outputStream | 
		  | regex index |
		  index := 1.
		  regex := '([a-zA-Z][a-zA-Z0-9_]*)(\.)([a-zA-Z][a-zA-Z0-9_]*)((\([^)]+\))*)'
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

{ #category : #accessing }
PPEsopeRewriter >> endOfLine [
	"(Character cr asPParser / Character lf asPParser)  plus"
	
	^ super endOfLine
	==> [ :nodes | String streamContents: [ :str | nodes do: [ :c | str nextPut: c ] ] ]
]

{ #category : #rules }
PPEsopeRewriter >> fortranLine [
	"'Cc*' indicates that a line is a comment. So we check that the first letter of the line starts with one of these characters"
	"endOfLine negate star flatten , endOfLine"

	^ super fortranLine
		==> [ :nodes | 
			| line |
			line := ''
				writeStreamDo: [ :str | 
					nodes do: [ :node | str << node value ].
					str contents ].
			('Cc*' includes: line first)
				ifTrue: [ stream << line ]
				ifFalse: [ stream
					<< (self
							translateEsopeAt: (self translateEsopeArray: (self translateEsopeSlash: line))) ] ]
				
]

{ #category : #utilities }
PPEsopeRewriter >> fortranOperator: esopeAtIdentifier [

	| uppercaseIdentifier |
	uppercaseIdentifier := esopeAtIdentifier asUppercase.
	^ self logicalOperators anySatisfy: [ :operator | 
		  (uppercaseIdentifier beginsWith: operator) or: [ 
			  uppercaseIdentifier endsWith: operator ] ]
]

{ #category : #utilities }
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

{ #category : #initialization }
PPEsopeRewriter >> initStream [
	stream := '' writeStream
]

{ #category : #initialization }
PPEsopeRewriter >> initialize [
	super initialize.
	
	self initStream.
]

{ #category : #utilities }
PPEsopeRewriter >> logicalOperators [

	^ #( '.EQ.' '.LT.' '.LE.' '.GT.' '.GE.' '.NE.' '.OR.' '.AND.' '.NOT.'
	     '.TRUE.' '.FALSE.' '.EQV.' '.NEQV.' )
]

{ #category : #rules }
PPEsopeRewriter >> optionalBlanks [

	^ super optionalBlanks
	  ==> [ :nodes | nodes ifNil: [ '' token ] ifNotNil: [ :tk | tk ] ]
]

{ #category : #accessing }
PPEsopeRewriter >> output [

	^ stream contents
]

{ #category : #accessing }
PPEsopeRewriter >> outputForSegment [

	^ stream contents replaceAll: Character tab  with: Character cr
]

{ #category : #rules }
PPEsopeRewriter >> pointer [

	"beginOfLine , optionalBlanks , pointerKeyWord
	  , optionalBlanks , pointerName , optionalBlanks , endOfLine"

	^ super pointer ==> [ :nodes | self processNodes: nodes ]
]

{ #category : #utilities }
PPEsopeRewriter >> processLinesInsideSegment: anOrderedCollection [

	"  (beginOfLine, 'end' asPParser not, endOfLine negate plus, endOfLine) star"

	self flag: #TODO.
	" #processLinesInsideSegment 
	There are several ways of handling the components of a segment:
	- let a fortran77 parser handle them for us at this stage. this means not annotating them and having to process them later when parsing the AST obtained by the fortran77 parser by using the position of the token.
	- modify our grammars to handle the components correctly
	- Annotate them, and be a master of regular expressions during ESOPE comment processing."

	"option2: not yet implemented"
	"option3: tested and not approuved.
		""self annotateByEsopePrefix.
		stream << (line at: 3) value.
		self addLineSeparator"""

	anOrderedCollection do: [ :line | "option1" 
		line do: [ :part | part ifNotNil: [ stream << part value ] ] ]
]

{ #category : #rules }
PPEsopeRewriter >> processNodes: nodes [

	self annotateByEsopePrefix.
	^ self copyTokens: nodes from: 2 to: nodes size
]

{ #category : #rules }
PPEsopeRewriter >> segact [

	"beginOfLine, spaces, 'segact' asPParser, segIdentifier, endOfLine"

	^ super segact ==> [ :nodes | self processNodes: nodes ]
]

{ #category : #rules }
PPEsopeRewriter >> segadj [

	"beginOfLine, spaces, 'segadj' asPParser, segIdentifier, endOfLine"

	^ super segadj ==> [ :nodes | self processNodes: nodes ]
]

{ #category : #rules }
PPEsopeRewriter >> segdef [

	"(self esopeLine: 'segment') , lines , beginOfLine , optionalBlanks
	  , endToken , optionalBlanks , segmentToken , optionalBlanks
	  , endOfLine"

	" #processLinesInsideSegment 
	There are several ways of handling the components of a segment:
	- let a fortran77 parser handle them for us at this stage. this means not annotating them and having to process them later when parsing the AST obtained by the fortran77 parser.
	- modify our grammars to handle the components correctly
	- Annotate them, and be a master of regular expressions during ESOPE comment processing."

	^ super segdef ==> [ :nodes | 
	  self annotateByEsopePrefix.
	  self copyTokens: nodes from: 2 to: 6.
	  self processLinesInsideSegment: (nodes at: 7).
	  self annotateByEsopePrefix.
	  self copyTokens: nodes from: 10 to: nodes size ]
]

{ #category : #rules }
PPEsopeRewriter >> segdes [

	" beginOfLine, spaces, 'segdes' asPParser, segIdentifier, endOfLine"

	^ super segdes ==> [ :nodes | self processNodes: nodes ]
]

{ #category : #rules }
PPEsopeRewriter >> segini [

	" beginOfLine, spaces, 'segini' asPParser, segIdentifier, endOfLine"

	^ super segini ==> [ :nodes | self processNodes: nodes ]
]

{ #category : #rules }
PPEsopeRewriter >> segsup [

	" beginOfLine , spaces, 'segsup' asPParser, segIdentifier, endOfLine"

	^ super segsup ==> [ :nodes | self processNodes: nodes ]
]

{ #category : #annotations }
PPEsopeRewriter >> slashAnnotation [

	^ 'S__('
]

{ #category : #transformations }
PPEsopeRewriter >> slashTransformation: inputSource [

	^ String new writeStreamDo: [ :outputStream | 
		  | regex index |
		  index := 1.
		  regex := '(([a-zA-Z][a-zA-Z0-9_]*)(\.)*)([a-zA-Z][a-zA-Z0-9_]*)(\(\/[^)]+\))'
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
					  << attrPart;
					  << $,;
					  << dimsPart;
					  << $).
				  index := interval last + 1 ] ].
		  outputStream << (inputSource copyFrom: index to: inputSource size).
		  outputStream contents ]
]

{ #category : #utilities }
PPEsopeRewriter >> translateEsopeArray: inputStream [

	| regex i |
	i := 1.
	'' writeStreamDo: [ :outputStream | 
		regex := self class regexForEsopeWithArray.
		(regex matchingRangesIn: inputStream) do: [ :interval | 
			(self
				 fortranOperator: inputStream
				 from: interval first
				 to: interval last) ifFalse: [ 
				i to: interval first - 1 do: [ :idx | 
				outputStream nextPut: (inputStream at: idx) ].
				outputStream << 'ESOar('.
				i := interval first.
				[ (inputStream at: i) == $( ] whileFalse: [ 
					outputStream nextPut: (inputStream at: i).
					i := i + 1 ].
				outputStream nextPut: $,.
				[ (inputStream at: i) == $) ] whileFalse: [ 
					outputStream nextPut: (inputStream at: i + 1).
					i := i + 1 ].
				i + 1 to: interval last do: [ :idx | 
				outputStream nextPut: (inputStream at: idx) ].
				i := interval last + 1 ] ].
		i to: inputStream size do: [ :idx | 
		outputStream nextPut: (inputStream at: idx) ].
		^ outputStream contents ]
]

{ #category : #utilities }
PPEsopeRewriter >> translateEsopeAt: inputStream [

	| regex i |
	i := 1.
	'' writeStreamDo: [ :outputStream | 
		regex := self class regexForEsopeWithDot.
		(regex matchingRangesIn: inputStream) do: [ :interval | 
			(self
				 fortranOperator: inputStream
				 from: interval first
				 to: interval last) ifFalse: [ 
				i to: interval first - 1 do: [ :idx | 
				outputStream nextPut: (inputStream at: idx) ].
				outputStream << 'ESOat('.
				i := interval first.
				[ (inputStream at: i) == $. ] whileFalse: [ 
					outputStream nextPut: (inputStream at: i).
					i := i + 1 ].
				outputStream nextPut: $,.
				i + 1 to: interval last do: [ :idx | 
				outputStream nextPut: (inputStream at: idx) ].
				outputStream nextPut: $).
				i := interval last + 1 ] ].
		i to: inputStream size do: [ :idx | 
		outputStream nextPut: (inputStream at: idx) ].
		^ outputStream contents ]
]

{ #category : #utilities }
PPEsopeRewriter >> translateEsopeSlash: inputStream [

	| regex i |
	i := 1.
	'' writeStreamDo: [ :outputStream | 
		regex := self class regexForEsopeWithSlash.
		(regex matchingRangesIn: inputStream) do: [ :interval | 
			i to: interval first - 1 do: [ :idx | 
			outputStream nextPut: (inputStream at: idx) ].
			outputStream << 'ESOsl('.
			i := interval first.
			[ (inputStream at: i) == $( ] whileFalse: [ 
				outputStream nextPut: (inputStream at: i).
				i := i + 1 ].
			outputStream nextPut: $,.
			i + 2 to: interval last do: [ :idx | 
			outputStream nextPut: (inputStream at: idx) ].
			i := interval last + 1 ].
		i to: inputStream size do: [ :idx | 
		outputStream nextPut: (inputStream at: idx) ].
		^ outputStream contents ]
]
