Class {
	#name : #IASTAbstractFamixVisitorTest,
	#superclass : #TestCase,
	#instVars : [
		'visitor'
	],
	#category : #'EsopeImporter-Tests-Visitor'
}

{ #category : #running }
IASTAbstractFamixVisitorTest >> setUp [

	super setUp.

	"Put here a common initialization logic for tests"
	visitor := IASTToFortranVisitor new
]

{ #category : #tests }
IASTAbstractFamixVisitorTest >> testIntrinsicTypes [

	| types |
	types := visitor intrinsicTypes.
	self assert: types isDictionary.
	self assert: types size equals: 5.
	self assert: (types at: #integer) class equals: FamixF77TypeIntrinsic.
	self assert: (types at: #integer) name equals: 'integer'.
	self assert: (types at: #real) class equals: FamixF77TypeIntrinsic.
	self assert: (types at: #real) name equals: 'real'.
	self assert: (types at: #complex) class equals: FamixF77TypeIntrinsic.
	self assert: (types at: #complex) name equals: 'complex'.
	self assert: (types at: #logical) class equals: FamixF77TypeIntrinsic.
	self assert: (types at: #logical) name equals: 'logical'.
	self assert: (types at: #character) class equals: FamixF77TypeIntrinsic.
	self assert: (types at: #character) name equals: 'character'.
]

{ #category : #tests }
IASTAbstractFamixVisitorTest >> testRetrieveTypeFrom [

	self
		assert: (visitor retrieveTypeFrom: 'integer') class
		equals: FamixF77TypeIntrinsic.
	self
		assert: (visitor retrieveTypeFrom: 'integer') name
		equals: 'integer'.
	self
		assert: (visitor retrieveTypeFrom: 'unknown') class
		equals: FamixF77TypeUnknown
]
