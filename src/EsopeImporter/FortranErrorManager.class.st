"
I register errors during the import process and allow to proceed, ignoring them
"
Class {
	#name : #FortranErrorManager,
	#superclass : #Object,
	#instVars : [
		'contexts',
		'errors',
		'stop'
	],
	#category : #'EsopeImporter-Importer'
}

{ #category : #accessing }
FortranErrorManager >> enterContext: aString [

	contexts addLast: aString
]

{ #category : #accessing }
FortranErrorManager >> enterFile: aFilename [

	self enterContext: 'file:' , aFilename
]

{ #category : #accessing }
FortranErrorManager >> error: anException [

	stop ifTrue: [ anException pass ].

	errors add: (
		(String streamContents: [ :stream |
			contexts do: [ :context | stream << context ] separatedBy: [ stream << ' / ' ]
		])
		-> 	anException)
]

{ #category : #accessing }
FortranErrorManager >> errors [

	^ errors
]

{ #category : #api }
FortranErrorManager >> handleErrorsFor: context running: runningBlock [
	"1. register the context
	 2. executes the runningBlock
	 3. in case of Error register it"

	| value |

	self enterContext: context.

	[ value := runningBlock value ]
		on: Exception
		do: [ :err |
			self error: err.
			err resume
		].

	self leaveContext.

	^value

]

{ #category : #initialization }
FortranErrorManager >> initialize [ 

	super initialize.

	errors := OrderedCollection new.
	contexts := OrderedCollection new.
	stop := false
]

{ #category : #testing }
FortranErrorManager >> isEmpty [

	^errors isEmpty
]

{ #category : #testing }
FortranErrorManager >> isNotEmpty [

	^errors isNotEmpty
]

{ #category : #accessing }
FortranErrorManager >> leaveContext [

	contexts removeLast
]

{ #category : #accessing }
FortranErrorManager >> leaveFile [

	self leaveContext
]

{ #category : #'error management' }
FortranErrorManager >> resumeOnError [

	self stopOnError: false
]

{ #category : #'error management' }
FortranErrorManager >> stop [

	^stop
]

{ #category : #'error management' }
FortranErrorManager >> stopOnError [

	self stopOnError: true
]

{ #category : #'error management' }
FortranErrorManager >> stopOnError: aBoolean [

	stop := aBoolean
]
