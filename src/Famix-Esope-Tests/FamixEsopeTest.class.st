Class {
	#name : #FamixEsopeTest,
	#superclass : #TestCase,
	#instVars : [
		'model'
	],
	#category : #'Famix-Esope-Tests'
}

{ #category : #running }
FamixEsopeTest >> defaultAnchorFrom: startPoint to: endPoint [

	^ (self newEntity: FamixFortran77IndexedFileAnchor)
		  startLine: startPoint x;
		  startColumn: startPoint y;
		  endLine: endPoint x;
		  endColumn: endPoint y;
		  fileName: 'fortran77.f';
		  yourself
]

{ #category : #running }
FamixEsopeTest >> defaultAttribute: varName withType: typeName [

	^ (self newEntity: FamixEsopeAttribute)
		  sourceAnchor: (self defaultAnchorFrom: 2 @ 7 to: 2 @ 19);
		  name: varName;
		  declaredType: (self defaultType: typeName)
]

{ #category : #running }
FamixEsopeTest >> defaultSegment: segmentName with: dictDeclarations [

	^ (self newEntity: FamixEsopeSegment)
		  name: segmentName;
		  sourceAnchor: (self defaultAnchorFrom: 2 @ 7 to: 2 @ 8);
		  attributes: (dictDeclarations collect: [ :assoc | 
					   self defaultAttribute: assoc key withType: assoc value ]);
		  yourself
]

{ #category : #tests }
FamixEsopeTest >> defaultSegmentComand: commandName [

	^ (self newEntity: FamixEsopeCommand)
		  name: commandName;
		  sourceAnchor: (self defaultAnchorFrom: 2 @ 7 to: 2 @ 19);
		  target: (self defaultVariable: 'attr' withType: 'integer');
		  yourself
]

{ #category : #tests }
FamixEsopeTest >> defaultSegmentComand: commandName on: varPointer [

	^ (self newEntity: FamixEsopeSegini)
		  sourceAnchor: (self defaultAnchorFrom: 2 @ 7 to: 2 @ 19);
		  target: (self defaultVariable: varPointer withType: 'pointeur');
		  yourself
]

{ #category : #running }
FamixEsopeTest >> defaultType: typeName [

	^ (self newEntity: FamixFortran77Type)
		  sourceAnchor: (self defaultAnchorFrom: 2 @ 7 to: 2 @ 19);
		  name: typeName
]

{ #category : #running }
FamixEsopeTest >> defaultVariable: varName withType: typeName [

	^ (self newEntity: FamixFortran77Variable)
		  sourceAnchor: (self defaultAnchorFrom: 2 @ 7 to: 2 @ 19);
		  name: varName;
		  declaredType: (self defaultType: typeName)
]

{ #category : #running }
FamixEsopeTest >> newEntity: aFamixClass [

	^ aFamixClass new
		  mooseModel: model;
		  yourself
]

{ #category : #running }
FamixEsopeTest >> setUp [

	super setUp.

	model := FamixEsopeModel new
]

{ #category : #tests }
FamixEsopeTest >> testCreateSegmentCommandSegini [

	"
	segini ptr
	"

	| segini |
	segini := self defaultSegmentComand: 'segini' on: 'ptr'.

	self assert: segini class equals: FamixEsopeSegini.

	self assert: segini variable class equals: FamixFortran77Variable.
	self assert: segini variable name equals: 'ptr'.
	self assert: segini variable declaredType name equals: 'pointeur'
]

{ #category : #tests }
FamixEsopeTest >> testCreateSegmentWithMultipleAttributes [
	"
	segment myseg
	 character*40 uname
	 integer age
	end segment
	"
	
	| segment |
	
	segment := self defaultSegment: 'myseg' with: { 
			           (#uname -> #character).
			           (#status -> #logical).
			           (#age -> #integer) }.
	
	self assert: segment name equals: 'myseg'.
	self assert: segment attributes size equals: 3.
	self assert: segment attributes first class equals: FamixEsopeAttribute.
	self assert: segment attributes first name equals: 'uname'.
	self assert: segment attributes first declaredType class equals: FamixFortran77Type.
	self assert: segment attributes first declaredType name equals: 'character'.
]

{ #category : #tests }
FamixEsopeTest >> testCreateVariablePointeur [

	"
	pointeur ptr.book
	"

	| pointeur |
	pointeur := self defaultVariable: 'ptr' withType:  'book'.

	self assert: pointeur class equals: FamixFortran77Variable.
	self assert: pointeur name equals: 'ptr'.
	self assert: pointeur declaredType name equals: 'book'
]
