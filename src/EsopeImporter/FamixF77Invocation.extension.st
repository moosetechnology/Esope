Extension { #name : #FamixF77Invocation }

{ #category : #'*EsopeImporter' }
FamixF77Invocation >> famixImportSanityCheck [

	| sig |

	super famixImportSanityCheck.

	sig := sender
		ifNil: [ 'an invocation' ]
		ifNotNil: [ sender signature
			ifNil: [ 'an invocation' ]].
	self sanityCheck: sender isNotNil description: (sig , ' without sender').
	self sanityCheck: candidates isNotEmpty description: (sig , ' without candidates').
]
