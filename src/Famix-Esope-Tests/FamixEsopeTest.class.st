Class {
	#name : #FamixEsopeTest,
	#superclass : #TestCase,
	#instVars : [
		'model',
		'segini',
		'segact',
		'pointer',
		'segdes',
		'segsup',
		'segadj'
	],
	#category : #'Famix-Esope-Tests'
}

{ #category : #running }
FamixEsopeTest >> defaultEsopeComment: comment [
	^(self newEntity: FamixFortran77EComment)
		content: comment
]

{ #category : #running }
FamixEsopeTest >> newEntity: aFamixClass [
	^aFamixClass new
		mooseModel: model;
		yourself
]

{ #category : #running }
FamixEsopeTest >> sampleAttribute [
	^FamixEsopeAttribute new
		name: '';
		declaredType: (self sampleType: 'integer');
		yourself
]

{ #category : #running }
FamixEsopeTest >> sampleAttribute: attributeName [
	^FamixEsopeAttribute new
		name: attributeName;
		declaredType: (self sampleType: 'integer');
		yourself
]

{ #category : #running }
FamixEsopeTest >> sampleParameter: parameterName [
	
]

{ #category : #running }
FamixEsopeTest >> samplePointerRef [
	^FamixEsopePointer new
		name: '';
		segment: self sampleSegment;
		yourself
]

{ #category : #running }
FamixEsopeTest >> sampleSegini [
	^FamixEsopeSegini new
		pointer: self samplePointerRef;
		yourself
]

{ #category : #running }
FamixEsopeTest >> sampleSegment: segmentName [
	^FamixEsopeSegment new
		name: segmentName;
		attributes: { self sampleAttribute: 'var' };
		parameters: { self sampleParameter: 'i' };
		yourself
]

{ #category : #running }
FamixEsopeTest >> sampleType: typeName [
	^FamixFortran77Type new
		name: typeName;
		yourself
		
]

{ #category : #running }
FamixEsopeTest >> sampleVariable [
	^FamixFortran77Variable new
		name: '';
		declaredType: (self sampleType: 'integer');
		yourself
]

{ #category : #running }
FamixEsopeTest >> sampleVariable: variableName [
	^FamixFortran77Variable new
		name: variableName;
		declaredType: (self sampleType: 'integer');
		yourself
]

{ #category : #running }
FamixEsopeTest >> setUp [
	super setUp.

	model := FamixEsopeModel new.

	segact := self defaultEsopeComment: 'eso  segact,xs'.
	segadj := self defaultEsopeComment: 'eso  segadj xs'.
	segdes := self defaultEsopeComment: 'eso  segdes,xs'.
	segini := self defaultEsopeComment: 'eso  segini,xs'.
	segsup := self defaultEsopeComment: 'eso  segsup,xs'.

	pointer := self defaultEsopeComment: 'eso  pointeur ptr.myseg'.
]

{ #category : #tests }
FamixEsopeTest >> testCreationEsopeEntityFromFortranEComment [

	| result |
	result := FamixEsopeSegdes newEntity: segdes.
	self assert: result pointer notNil.
	self assert: result pointer name equals: pointer name.
	self assert: result pointer name equals: 'xs'.

	result := FamixEsopeSegini newEntity: segini.
	self assert: result pointer notNil.
	self assert: result pointer name equals: pointer name.
	self assert: result pointer name equals: 'xs'.

	result := FamixEsopeSegact newEntity: segact.
	self assert: result pointer notNil.
	self assert: result pointer name equals: pointer name.
	self assert: result pointer name equals: 'xs'.

	result := FamixEsopeSegsup newEntity: segsup.
	self assert: result pointer notNil.
	self assert: result pointer name equals: pointer name.
	self assert: result pointer name equals: 'xs'.
	
	result := FamixEsopeSegadj newEntity: segadj.
	self assert: result pointer notNil.
	self assert: result pointer name equals: pointer name.
	self assert: result pointer name equals: 'xs'
]

{ #category : #tests }
FamixEsopeTest >> testCreationFamixEsopeSegment [

	| result |
	self skip.
	self flag: #TODO. ""

	result := FamixEsopeSegment newEntity: segment.
	self assert: result pointers size equals: 0.
	self assert: result attributes size equals: 3.
	self assert: result attributes first name equals: 'valtyp'.
	self assert: result name equals: 'values'.
	self assert: result parameters size equals: 0.
	
	"self assert: result attributes first type equals: 'character*8'"
]

{ #category : #tests }
FamixEsopeTest >> testCreationOfSegment [

	| segment |
	segment := self sampleSegment: 'myseg'.
	1halt
	
]

{ #category : #tests }
FamixEsopeTest >> testSegment [

	| result |
	self skip.
	self flag: #TODO. ""

	result := FamixEsopeSegment newEntity: segment.
	self assert: result pointers size equals: 0.
	self assert: result attributes size equals: 3.
	self assert: result attributes first name equals: 'valtyp'.
	self assert: result name equals: 'values'.
	
	
	"self assert: result attributes first type equals: 'character*8'"
]
