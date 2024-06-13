Class {
	#name : #FamixEsopeResolverTest,
	#superclass : #TestCase,
	#instVars : [
		'mooseModel',
		'resolver',
		'famixProgFile'
	],
	#category : #'EsopeImporter-Tests-Importer'
}

{ #category : #'default values' }
FamixEsopeResolverTest >> anchorFrom: startPoint to: endPoint [

	^ FamixF77IndexedFileAnchor new
		  mooseModel: mooseModel;
		  startLine: startPoint x;
		  startColumn: startPoint y;
		  endLine: endPoint x;
		  endColumn: endPoint y;
		  fileName: 'fortran77.f';
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultAccess: varName [

	^ FamixF77Access new
		  mooseModel: mooseModel ;
		  attributeAt: #entity put: ((self defaultIASTVarAccess: varName) isWrite: false ; yourself) ;
		  isWrite: false ;
		  sourceAnchor: self defaultAnchor ;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultAnchor [

	^ self anchorFrom: 1 @ 7 to: 2 @ 10
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultAttribute: varName withType: typeName [

	^ (self newEntity: FamixFortranAttribute)
		  sourceAnchor: (self anchorFrom: 2 @ 7 to: 2 @ 19);
		  name: varName;
		  declaredType: (self defaultType: typeName)
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultFunction: name [

	^ (self newEntity: FamixF77PUFunction named: name) programFile:
		  famixProgFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultIASTEsopeCommand: commandName name: entityName [

	^ IASTEsopeSegCommand new
		  esopeCommand: commandName;
		  entityName: entityName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultIASTInvocation: name [

	^ IASTInvocation new
		  entityName: name;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultIASTVarAccess: name [

	^ IASTVarAccess new
		  entityName: name ;
		  isWrite: true ;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultImplicitNone [

	^ IASTImplicitTypingRule new
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultInvocation: name [

	^ FamixF77Invocation new
		  mooseModel: mooseModel;
		  attributeAt: #entity put: (self defaultIASTInvocation: name);
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultMain: name [

	^ (self newEntity: FamixF77PUMain named: name) programFile:
		  famixProgFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultParameter: name [

	^ self newEntity: FamixF77Parameter named: name
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultProgramFile: aFilename [

	^ (self newEntity: FamixF77ProgramFile named: aFilename)
		  filename: aFilename;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultProgramUnit: name forType: aFamixClass belongsTo: aFamixProgramFile [

	^ (self newEntity: aFamixClass named: name) programFile:
		  aFamixProgramFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultSegment: segmentName with: dictDeclarations [

	^ (self newEntity: FamixEsopeSegment)
		  name: segmentName;
		  sourceAnchor: (self anchorFrom: 2 @ 7 to: 2 @ 8);
		  attributes: (dictDeclarations collect: [ :assoc | 
					   self defaultAttribute: assoc key withType: assoc value ]);
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultSubroutine: name [

	^ (self newEntity: FamixF77PUSubroutine named: name) programFile:
		  famixProgFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultSubroutine: name belongsTo: aFamixProgramFile [

	^ (self newEntity: FamixF77PUSubroutine named: name) programFile:
		  aFamixProgramFile
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultType: anIntrinsicFortranType [

	^FamixF77TypeIntrinsic new
		  name: anIntrinsicFortranType;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> defaultVariable: name withType: type [

	^ (self newEntity: FamixF77Variable named: name) declaredType:
		  (self defaultType: type)
]

{ #category : #'default values' }
FamixEsopeResolverTest >> externalDeclaration: name [

	^ self newEntity: FamixF77ExternalDeclaration named: name
]

{ #category : #'default values' }
FamixEsopeResolverTest >> iastTypeRef: typeName [

	^ IASTTypeRef new
		  entityName: typeName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixEsopeResolverTest >> implicitRule: typeName range: ranges [

	^ IASTImplicitTypingRule new
		  forType: (self iastTypeRef: typeName);
		  ranges: ranges;
		  yourself
]

{ #category : #running }
FamixEsopeResolverTest >> newEntity: aFamixClass [

	^ aFamixClass new
		  mooseModel: mooseModel;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #running }
FamixEsopeResolverTest >> newEntity: aFamixClass named: aName [

	^ (self newEntity: aFamixClass)
		name: aName
]

{ #category : #running }
FamixEsopeResolverTest >> newPU: aName [

	^ (self newEntity: FamixF77PUSubroutine named: aName)
		  programFile: famixProgFile;
		  yourself
]

{ #category : #running }
FamixEsopeResolverTest >> setUp [

	super setUp.

	mooseModel := FamixEsopeModel new.
	resolver := FamixEsopeResolver on: mooseModel.
	famixProgFile  := self defaultProgramFile: './main.f'.
]

{ #category : #tests }
FamixEsopeResolverTest >> testMergeVariableInto [
	"We have 2 variables with the same name one should be merged into the other which keeps its
	 declared type and	gets the accesses of the 1st"

	| variable1 variable2 sub1 sub2 |

	sub1 := self defaultSubroutine: 'sub1'.
	sub2 := self defaultSubroutine: 'sub2'.

	variable1 := (self defaultVariable: 'var1' withType: 'INTEGER')
		parentBehaviouralEntity: sub1.
	variable2 := (self defaultVariable: 'var1' withType: 'REAL')
		parentBehaviouralEntity: sub2.

	resolver model newAccess
		accessor: sub1 ;
		variable: variable1.
	resolver model newAccess
		accessor: sub2 ;
		variable: variable2.

	self assert: variable1 incomingAccesses size equals: 1.
	self assert: sub1 localVariables size equals: 1.
	self assert: variable2 incomingAccesses size equals: 1.
	self assert: sub2 localVariables size equals: 1.

	resolver mergeVariable: variable2 into: variable1.

	self assert: variable1 incomingAccesses size equals: 2.
	self assert: sub1 localVariables size equals: 1.
	self assert: variable2 incomingAccesses size equals: 0.
	self assert: sub2 localVariables size equals: 0.

	self assert: variable1 declaredType name equals: 'INTEGER'
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitDefault [

	"
	      subroutine rtn
	      end
	"

	| pu |

	pu := self defaultSubroutine: 'rtn'.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary size equals: 26.
	
	"testing a few of them"
	self assert: (pu implicitDictionary at: $a) equals: 'real'.
	self assert: (pu implicitDictionary at: $i) equals: 'integer'.
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitMultiple [
	"
      subroutine rtn
      implicit integer(a,d-e)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		      attributeAt: #implicits
		      put:
			      { (self
				       implicitRule: 'integer'
				       range: #( #( $a ) #( $c $d ) )) };
		      yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'real'.
	self assert: (pu implicitDictionary at: $c) equals: 'integer'.
	self assert: (pu implicitDictionary at: $d) equals: 'integer'.
	self assert: (pu implicitDictionary at: $e) equals: 'real'
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitNone [

	"
	      subroutine rtn
	      implicit none
	      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		attributeAt: #implicits put: { self defaultImplicitNone } ;
		yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary isEmpty
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitRange [
	"
      subroutine rtn
      implicit integer(a-c)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		      attributeAt: #implicits
		      put: { (self implicitRule: 'integer' range: #( #( $a $c ) )) };
		      yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'integer'.
	self assert: (pu implicitDictionary at: $c) equals: 'integer'.
	self assert: (pu implicitDictionary at: $d) equals: 'real'
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitSimple [
	"
      subroutine rtn
      implicit integer(a)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		      attributeAt: #implicits
		      put: { (self implicitRule: 'integer' range: #( #( $a ) )) };
		      yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'real'
]

{ #category : #tests }
FamixEsopeResolverTest >> testRequalifyFunctionDeclarations [

	"
      subroutine sub
       external fct
      integer fct
      end
	"

	| sub |

	sub := (self defaultSubroutine: 'sub')
		addExternalDeclaration: (self externalDeclaration: 'fct') ;
		addLocalVariable: (self defaultVariable: 'fct' withType: #integer) ;
		yourself.

 	resolver requalifyFunctionDeclarations.

	self assert: sub localVariables isEmpty.
	self assert: (resolver model allWithType: FamixF77Variable) isEmpty.

	self assert: sub externalDeclarations size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) size equals: 1.

]

{ #category : #tests }
FamixEsopeResolverTest >> testRequalifyParameterDeclarations [

	"
      subroutine sub(var)
      integer var
      end
	"

	| sub entity |

	sub := (self newPU: 'sub')
		addParameter: (self defaultParameter: 'var') ;
		addLocalVariable: (self defaultVariable: 'var' withType: #integer) ;
		yourself.

 	resolver requalifyParameterDeclarations.

	self assert: sub localVariables isEmpty.
	self assert: (resolver model allWithType: FamixF77Variable) isEmpty.

	self assert: sub parameters size equals: 1.
	entity := sub parameters anyOne.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'integer'.


]

{ #category : #'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccesses [
	"program main
	 integer var
	 var
	 end
	"

	| main access  |

	main := (self defaultMain: 'main')
		addLocalVariable: (self defaultVariable: 'var' withType: #integer);
		addAccess: (self defaultAccess: 'var');
		yourself.

 	resolver resolveAccesses.

	self assert: main accesses size equals: 1.
	access := main accesses first.

	self assert: access variable equals: main localVariables first.
]

{ #category : #'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesForALocalVariableImplicit [
	"program main
	 var
	 end
	"

	| main access  var |

	main := (self defaultMain: 'main')
		addAccess: (self defaultAccess: 'var');
		yourself.

	self assert: main localVariables size equals: 0.

 	resolver resolveAccesses.

	self assert: main localVariables size equals: 1.
	var := main localVariables anyOne.
	self assert: var name equals: 'var'.
	self assert: var declaredType class equals: FamixF77TypeIntrinsic.
	self assert: var declaredType name equals: 'real'.

	self assert: main accesses size equals: 1.

	access := main accesses anyOne.
	self assert: access variable equals: var.
	self assert: access accessor equals: main.

]

{ #category : #'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesForAParameter [

	| subrtn access |
	"
      subroutine demo(x)
        integer x
      x
      end
	"
	access := self newEntity: FamixF77Access.
	access attributeAt: #entity put: (self defaultIASTVarAccess: 'x').

	subrtn := (self defaultSubroutine: 'demo')
		          addParameter:
			          (self newEntity: FamixF77Parameter named: 'x');
		          addAccess: access;
		          yourself.

	resolver resolveAccesses.

	self assert: subrtn accesses size equals: 1.

	self assert: access variable class equals: FamixF77Parameter.
	self assert: access accessor equals: subrtn
]

{ #category : #'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesForAPointerDotAttribute [

	| main access access2 varP typePoint |
	"
      subroutine demo
      segment point
        integer x
      end segment
	   pointeur p.point
      p.x
      end
	"
	typePoint := self newEntity: FamixEsopeSegment named: 'point'.
	typePoint addAttribute:
		(self newEntity: FamixFortranAttribute named: 'x').

	varP := self newEntity: FamixF77Variable named: 'p'.
	varP declaredType: typePoint.

	access := self newEntity: FamixF77Access.
	access attributeAt: #entity put: (self defaultIASTVarAccess: 'p').

	access2 := self newEntity: FamixF77Access.
	access2 attributeAt: #entity put: (self defaultIASTVarAccess: 'x').

	access attributeAt: #attributeAccess put: access2.
	access2 attributeAt: #parentAccess put: access.

	main := (self defaultMain: 'main')
		        addType: typePoint;
		        addLocalVariable: varP;
		        accesses: {
				        access.
				        access2 };
		        yourself.

	self assert: main localVariables size equals: 1.

	resolver resolveAccesses.

	self assert: main accesses size equals: 2.

	self assert: access variable equals: varP.
	self assert: access accessor equals: main.

	self assert: access2 variable class equals: FamixFortranAttribute.
	self assert: access2 variable parentType equals: typePoint.
	self assert: access2 accessor equals: main
]

{ #category : #'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesForAPointerVariableDeclared [

	| main access var |
	"
      subroutine demo
      segment point
      end segment
	   pointeur p.point
      p
      end
	"
	var := self newEntity: FamixF77Variable named: 'p'.
	var declaredType: (self newEntity: FamixF77Type named: 'point').

	main := (self defaultMain: 'main')
		        addType: (self newEntity: FamixEsopeSegment named: 'point');
		        addLocalVariable: var;
		        addAccess: ((self newEntity: FamixF77Access)
				         attributeAt: #entity
				         put: (self defaultIASTVarAccess: 'p');
				         yourself);
		        yourself.

	self assert: main localVariables size equals: 1.

	resolver resolveAccesses.

	var := main localVariables anyOne.

	self assert: main accesses size equals: 1.

	access := main accesses anyOne.
	self assert: access variable equals: var.
	self assert: access accessor equals: main
]

{ #category : #'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesForAPointerVariableImplicit [

	| subrtn access var |
	"
      subroutine demo
      segment point
      end segment
      point
      end
	"
	subrtn := (self defaultSubroutine: 'demo')
		          addType:
			          (self newEntity: FamixEsopeSegment named: 'point');
		          addAccess: ((self newEntity: FamixF77Access)
				           attributeAt: #entity
				           put: (self defaultIASTVarAccess: 'point');
				           yourself);
		          yourself.

	self assert: subrtn localVariables size equals: 0.

	resolver resolveAccesses.

	self assert: subrtn localVariables size equals: 1.
	var := subrtn localVariables anyOne.
	self assert: var name equals: 'point'.
	self assert: var declaredType class equals: FamixEsopeSegment.
	self assert: var declaredType name equals: 'point'.

	self assert: subrtn accesses size equals: 1.

	access := subrtn accesses anyOne.
	self assert: access variable equals: var.
	self assert: access accessor equals: subrtn
]

{ #category : #'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesforAnAttribute [

	| subrtn access type |
	"
      subroutine demo
      segment point
        integer x
      end segment
      x
      end
	"
	type := self newEntity: FamixEsopeSegment named: 'point'.
	type attributes:
		{ (self newEntity: FamixFortranAttribute named: 'x') }.

	access := self newEntity: FamixF77Access.
	access attributeAt: #entity put: (self defaultIASTVarAccess: 'x').

	subrtn := (self defaultSubroutine: 'demo')
		          addType: type;
		          addAccess: access;
		          yourself.

	resolver resolveAccesses.

	self assert: subrtn accesses size equals: 1.

	self assert: access variable class equals: FamixFortranAttribute.
	self assert: access variable parentType equals: type.
	self assert: access accessor equals: subrtn
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveDeclaredTypeOfPointers [

	| sub entity type var |
	"
      subroutine demo
      segment point
      end segment
      pointeur p.point
      end
	"
	type := self newEntity: FamixEsopeSegment named: 'point'.
	type attributes: #().

	var := self newEntity: FamixF77Variable named: 'p'.
	var segment: 'point'.
	var isEsope: true.

	sub := (self newPU: 'demo')
		addType: type;
		addLocalVariable: var;
		yourself.

	resolver resolveDeclaredTypeOfPointers.

	self assert: sub localVariables size equals: 1.

	entity := sub localVariables anyOne.
	self assert: entity declaredType equals: type
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitParameter [

	"
	      function fct(iparam)
	      end
	"

	| function |

	function := (self defaultFunction: 'fct')
		parameters: { (self defaultParameter: 'iparam') } ;
		yourself.

	self assert: function parameters first declaredType isNil.
	
	resolver resolve.

	self
		assert: function parameters first declaredType name
		equals: 'integer'
]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitParameterNone [

	"
	      subroutine sub(param)
	      implicit none
	      end
	"

		| entity |

	(self defaultSubroutine: 'sub')
		attributeAt: #implicits put: { self defaultImplicitNone } ;
		addParameter: (self defaultParameter: 'var').

 	resolver resolve.

	self assert: (resolver model allWithSubTypesOf: FamixF77ProgramUnit) size equals: 1.
	
	entity := (resolver model allWithSubTypesOf: FamixF77ProgramUnit) first parameters first.
	self assert: entity declaredType class equals: FamixF77TypeUnknown

]

{ #category : #'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitParameterRange [
	"
      subroutine sub(var)
      implicit charcater(u-w)
      end
	"

	| entity |

	(self defaultSubroutine: 'sub')
		attributeAt: #implicits
		put: { (self implicitRule: 'character' range: #( #( $u $w ) )) };
		addParameter: (self defaultParameter: 'var').

	resolver resolve.

	self
		assert: (resolver model allWithSubTypesOf: FamixF77ProgramUnit) size
		equals: 1.

	entity := (resolver model allWithSubTypesOf: FamixF77ProgramUnit)
		          first parameters first.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'character'
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveImplicits [

	"
      subroutine sub(var)
      end
	"

	| sub entity |

	sub := (self newPU: 'sub')
		addParameter: (self defaultParameter: 'var') ;
		yourself.

 	resolver resolveImplicits.

	self assert: sub parameters size equals: 1.
	entity := sub parameters anyOne.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'real'.


]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveImplicitsDeclared [

	"
      subroutine sub(var)
      implicit character(v) 
      end
	"

	| sub entity |

	sub := (self newPU: 'sub')
		addParameter: (self defaultParameter: 'var') ;
		attributeAt: #implicits put: { (self implicitRule: 'character' range: #( 'v' ) ) };
		yourself.

	resolver registerImplicitsDeclarations.
 	resolver resolveImplicits.

	self assert: sub parameters size equals: 1.
	entity := sub parameters anyOne.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'character'.


]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveImplicitsForFunction [
	"
      function fct()
      end
	"

	| fct |

	fct := self defaultFunction: 'fct'.

	resolver registerImplicitsDeclarations.
	resolver resolveImplicits.

	self assert: fct declaredType class equals: FamixF77TypeIntrinsic.
	self assert: fct declaredType name equals: 'real'
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveImplicitsForStatementFunction [
	"
      function fct()
      implicit character(f)
      end
	"

	| fct |

	fct := self newEntity: FamixF77StatementFunction named: 'f'.
	(self defaultFunction: 'fct')
		addStatementFunction: fct.

	resolver registerImplicitsDeclarations.
	resolver resolveImplicits.

	self assert: fct declaredType class equals: FamixF77TypeIntrinsic.
	self assert: fct declaredType name equals: 'real'
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveImplicitsNone [

	"
      subroutine sub(var)
		implicit none
      end
	"

	| sub entity |

	sub := (self newPU: 'sub')
		addParameter: (self defaultParameter: 'var') ;
		attributeAt: #implicits put: { self implicitRule: nil range: nil };
		yourself.

	resolver registerImplicitsDeclarations.
 	resolver resolveImplicits.

	self assert: sub parameters size equals: 1.
	entity := sub parameters anyOne.
	self assert: entity declaredType class equals: FamixF77TypeUnknown.


]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveIncludeDirective [
	"
+------ point.seg ----------------------------------+
|      subroutine @point_seg@                       |
|      segment point                                |
|      end segment                                  |
|      end                                          |
+---------------------------------------------------+
+------ main.E -------------------------------------+
|      program main                                 |
|#include ""point.seg""                             |
|      end                                          |
+---------------------------------------------------+
"

	| sub main includedFile mainFile |
	includedFile := self defaultProgramFile: 'point.seg.f'.
	mainFile := self defaultProgramFile: 'main.f'.

	sub := (self newEntity: FamixF77IncludedFile named: '@point_seg@')
		       programFile: includedFile;
		       types: { (self newEntity: FamixEsopeSegment named: 'point') };
		       yourself.

	main := (self newEntity: FamixF77PUMain named: 'main')
		        programFile: mainFile;
		        includes:
			        { ((self newEntity: FamixF77Include) filename: 'point.seg') };
		        yourself.

	resolver resolve.

	self
		assert: (resolver model allWithType: FamixF77IncludedFile) size
		equals: 1.
	self
		assert: (resolver model allWithType: FamixF77IncludedFile) first
		equals: sub.

	self assert: main includes size equals: 1.
	self assert: main includes anyOne included equals: sub.

	self assert: sub inclusions size equals: 1.
	self assert: sub inclusions anyOne includedBy equals: main
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveInvocations [
	| invocation callee caller |
	
	caller := (self defaultMain: 'main')
		addOutgoingInvocation: (self defaultInvocation: 'sub');
		yourself.
		
	callee := self defaultSubroutine: 'sub'.

 	resolver resolve.

	self assert: caller outgoingInvocations size equals: 1.
	invocation := caller outgoingInvocations first.
	
	self assert: invocation class equals: FamixF77Invocation.
	self assert: invocation sender equals: caller.
	
	self assert: invocation candidates size equals: 1.
	self assert: invocation candidates first equals: callee.
]

{ #category : #tests }
FamixEsopeResolverTest >> testResolveInvocationsWrongArgumentNumber [
	| invocation callee caller |
	
	caller := (self defaultMain: 'main')
		addOutgoingInvocation: (self defaultInvocation: 'sub');
		yourself.
		
	callee := self defaultSubroutine: 'sub'.
	callee parameters: { self defaultParameter: 'var' }.

 	resolver resolve.

	self assert: caller outgoingInvocations size equals: 1.
	invocation := caller outgoingInvocations first.

	self assert: invocation candidates size equals: 0
]
