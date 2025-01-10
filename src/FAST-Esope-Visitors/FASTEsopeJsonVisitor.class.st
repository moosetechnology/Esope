Class {
	#name : 'FASTEsopeJsonVisitor',
	#superclass : 'FASTFortranJsonVisitor',
	#category : 'FAST-Esope-Visitors',
	#package : 'FAST-Esope-Visitors'
}

{ #category : 'private - helpers' }
FASTEsopeJsonVisitor >> esopeCommand: anEsopeCommentString [
	"returns a collection of 2 words: {'command' . 'argument'}
	first word after Esope marker is the 'command', after comes the 'argument'"

	| wordBoundaries |
	wordBoundaries := self findWordBoundaries: anEsopeCommentString.

	^(wordBoundaries size > 2)
		ifTrue: [
			{ (anEsopeCommentString copyFrom: wordBoundaries first to: wordBoundaries second) .
			  (anEsopeCommentString copyFrom: wordBoundaries third to: wordBoundaries last) }
		]
		ifFalse: [ { anEsopeCommentString copyFrom: wordBoundaries first to: wordBoundaries second } ]
]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> esopeExtraSpan: commentSpan comment: commentText command: esopeCommand [
	"Compute the span of just the Esope command (without 'C@_  ')
	 - same start line
	 - start column must ignore 'C@_  '
	 - same end point"

	| commandStart |
	commandStart := (commentText indexOfSubCollection: (esopeCommand first)).

	^{ (commentSpan first x @ (commentSpan first y + commandStart))
		. commentSpan second }.

]

{ #category : 'testing' }
FASTEsopeJsonVisitor >> isEsopeComment: aCommentString [
	^aCommentString asLowercase beginsWith: '@_' 
]

{ #category : 'testing' }
FASTEsopeJsonVisitor >> isEsopeTransformation: aString [

	aString isString ifFalse: [ ^ false ].
	^ #( #d__ #s__ ) includes: aString
]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> processEsopeComment: anEsopeCommentNode [
	"For Esope comments the treatment is similar for most of them
	 We also return 2 spans:
	- the usual one which is the span of the entire comment
	- the span of just the Esope statement (without 'C@_  ')"

	| esopeCommand commentSpan |
	esopeCommand := self esopeCommand: (anEsopeCommentNode at: 'comment').
	commentSpan := self visitSpan: (anEsopeCommentNode at: 'span').

	^{ commentSpan .
		self
			esopeExtraSpan: commentSpan
			comment: (anEsopeCommentNode at: 'comment')
			command: esopeCommand
	}
	, esopeCommand
]

{ #category : 'helpers' }
FASTEsopeJsonVisitor >> processEsopeIfComment: anEsopeIfCommentNode [ 
	self shouldBeImplemented.
]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitComment: aCommentNode [
	"Separates comments that are genuine fortran comments and the one that contain Esope commands"
	| content |
	content := aCommentNode at: 'comment'.

	^(self isEsopeComment: content)
		ifTrue: [  self visitEsopeComment: aCommentNode ]
		ifFalse: [ self visitFortranComment: aCommentNode ]
	
]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeComment: anEsopeCommentNode [
	"we separate each Esope command in a different visit method to give opportunity to
	 concrete visitors (subclasses) to treat them differently.
	 But here, they are pretty much all the same, so they come down to the same treatment"

	| key esopeCommand |
	esopeCommand := self esopeCommand: (anEsopeCommentNode at: 'comment').
	key := 'Esope' , esopeCommand first asLowercase capitalized
	       , 'Comment'.

	^ self visitKey: key value: anEsopeCommentNode
]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeEndComment: anEsopeCommentNode [
	"delegate to a method with a more explicit name
		subclasses should override #visitEsopeEndSegmentComment: not this method"

	^self visitEsopeEndsegmentComment: anEsopeCommentNode 
]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeEndsegmentComment: anEsopeCommentNode [

	inSegmentDeclaration := false.
	^nil

]

{ #category : 'visiting' }
FASTEsopeJsonVisitor >> visitEsopeIfComment: anEsopeIfCommentNode [ 
	^self processEsopeIfComment: anEsopeIfCommentNode
]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeIncludeComment: anEsopeIncludeCommentNode [

	^self processEsopeComment: anEsopeIncludeCommentNode

]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopePointeurComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeSegactComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeSegadjComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeSegdesComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeSeginiComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : 'visiting' }
FASTEsopeJsonVisitor >> visitEsopeSegmentComment: anEsopeCommentNode [
	"Source anchor for the segment is wrong,
	 endLine/endColumn will be updated in #visitEsopeEndsegmentComment:"

	| data |
	data := self processEsopeComment: anEsopeCommentNode.

	inSegmentDeclaration := true.
	segmentDeclarations add: ((self newEntity: FASTEsopeSegment atPosition: data second)
		name: data fourth ;
		yourself).
	
	^nil
	
]

{ #category : 'visiting esope' }
FASTEsopeJsonVisitor >> visitEsopeSegsupComment: anEsopeCommentNode [

	^self processEsopeComment: anEsopeCommentNode

]

{ #category : 'visiting statement' }
FASTEsopeJsonVisitor >> visitFortranComment: aFortranCommentNode [
	"A real Fortran comment as opposed to a comment that contains an Esope command
	cannot call visitJsonMap: because contains a key 'comment' that would recursively loop on this method"

	^{ self visitSpan: (aFortranCommentNode at: 'span') .
	  aFortranCommentNode at: 'comment' }
	
]
