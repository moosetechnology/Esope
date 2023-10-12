Class {
	#name : #FamixFortran77ResolverTest,
	#superclass : #TestCase,
	#instVars : [
		'mooseModel',
		'resolver',
		'famixProgFile'
	],
	#category : #'EsopeImporter-Tests-Resolver'
}

{ #category : #'default values' }
FamixFortran77ResolverTest >> anchorFrom: startPoint to: endPoint [

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
FamixFortran77ResolverTest >> defaultAccess: varName [

	^ FamixF77Access new
		  mooseModel: mooseModel ;
		  attributeAt: #entity put: ((self defaultIASTVarAccess: varName) isWrite: false ; yourself) ;
		  isWrite: false ;
		  sourceAnchor: self defaultAnchor ;
		  yourself
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultAnchor [

	^ self anchorFrom: 1 @ 7 to: 2 @ 10
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultAttribute: varName withType: typeName [

	^ (self newEntity: FamixFortranAttribute)
		  sourceAnchor: (self anchorFrom: 2 @ 7 to: 2 @ 19);
		  name: varName;
		  declaredType: (self defaultType: typeName)
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultFunction: name [

	^ (self newNamedEntity: name toFamix: FamixF77PUFunction) 
		  programFile: famixProgFile
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultIASTEsopeCommand: commandName name: entityName [

	^ IASTEsopeSegCommand new
		  esopeCommand: commandName;
		  entityName: entityName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultIASTInvocation: name [

	^ IASTInvocation new
		  entityName: name;
		  yourself
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultIASTVarAccess: name [

	^ IASTVarAccess new
		  entityName: name ;
		  isWrite: true ;
		  yourself
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultImplicitNone [

	^ IASTImplicit new
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultInvocation: name [

	^ FamixF77Invocation new
		  mooseModel: mooseModel;
		  attributeAt: #entity put: (self defaultIASTInvocation: name);
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultMain: name [

	^ (self newNamedEntity: name toFamix: FamixF77PUMain) 
		  programFile: famixProgFile
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultParameter: name [

	^ self newNamedEntity: name toFamix: FamixF77Parameter
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultProgramFile: aFilename [

	^ (self newNamedEntity: aFilename toFamix: FamixF77ProgramFile)
		  filename: aFilename;
		  yourself
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultProgramUnit: name forType: aFamixClass belongsTo: aFamixProgramFile [

	^ (self newNamedEntity: name toFamix: aFamixClass) programFile:
		  aFamixProgramFile
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultSegment: segmentName with: dictDeclarations [

	^ (self newEntity: FamixEsopeSegment)
		  name: segmentName;
		  sourceAnchor: (self anchorFrom: 2 @ 7 to: 2 @ 8);
		  attributes: (dictDeclarations collect: [ :assoc | 
					   self defaultAttribute: assoc key withType: assoc value ]);
		  yourself
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultSubroutine: name [

	^ (self newNamedEntity: name toFamix: FamixF77PUSubroutine) 
		  programFile: famixProgFile
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultSubroutine: name belongsTo: aFamixProgramFile [

	^ (self newNamedEntity: name toFamix: FamixF77PUSubroutine) 
		  programFile: aFamixProgramFile
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultType: anIntrinsicFortranType [

	^FamixF77TypeIntrinsic new
		  name: anIntrinsicFortranType;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> defaultVariable: name withType: type [

	^ (self newNamedEntity: name toFamix: FamixF77Variable) 
		  declaredType: (self defaultType: type)
]

{ #category : #'default values' }
FamixFortran77ResolverTest >> implicitRange: ranges forType: typeName [

	^ IASTImplicit new
		  forType: (self defaultType: typeName);
		  ranges: ranges;
		  yourself
]

{ #category : #running }
FamixFortran77ResolverTest >> newEntity: aFamixClass [

	^ aFamixClass new
		  mooseModel: mooseModel;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #running }
FamixFortran77ResolverTest >> newNamedEntity: aName toFamix: aFamixClass [

	^ (self newEntity: aFamixClass)
		name: aName
]

{ #category : #running }
FamixFortran77ResolverTest >> newPU: aName [
	^(self newNamedEntity: aName toFamix: FamixF77PUSubroutine)
		programFile: famixProgFile ;
		yourself
]

{ #category : #running }
FamixFortran77ResolverTest >> setUp [

	super setUp.

	mooseModel := FamixEsopeModel new.
	resolver := FamixFortran77Resolver on: mooseModel.
	famixProgFile  := self defaultProgramFile: './main.f'.
]

{ #category : #'test-todo' }
FamixFortran77ResolverTest >> testCreateFamixFortran77Access [
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

 	resolver resolve.

	self assert: main accesses size equals: 1.
	access := main accesses first.

	self assert: access variable equals: main localVariables first.
]

{ #category : #'test-todo' }
FamixFortran77ResolverTest >> testCreateFamixFortran77AccessNonDeclaredVariable [
	| main access accessor |
	"
      program main
      var
      end
	"

	accessor := (self defaultMain: 'main')
		addAccess: (self defaultAccess: 'var');
		yourself.

	main := (resolver model allWithType: FamixF77PUMain) first.

	self assert: main localVariables size equals: 0.

 	resolver resolve.
	
	self assert: main localVariables size equals: 1.

	self assert: main accesses size equals: 1.
	access := main accesses first.

	self assert: access variable equals: main localVariables first.
	self assert: access variable declaredType name equals: 'real'.
]

{ #category : #'test - implicit' }
FamixFortran77ResolverTest >> testRegisterImplicitDefault [

	"
	      subroutine rtn
	      end
	"

	| pu |

	pu := self defaultSubroutine: 'rtn'.

	resolver registerImplicitsForPU: pu.

	self assert: pu dicImplicit size equals: 26.
	
	"testing a few of them"
	self assert: (pu dicImplicit at: $a) equals: 'real'.
	self assert: (pu dicImplicit at: $i) equals: 'integer'.
]

{ #category : #'test - implicit' }
FamixFortran77ResolverTest >> testRegisterImplicitMultiple [

	"
      subroutine rtn
      implicit integer(a,d-e)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		attributeAt: #implicits put: { (self implicitRange: #( #($a) #($c $d) ) forType: 'integer') };
		yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu dicImplicit size equals: 26.

	self assert: (pu dicImplicit at: $a) equals: 'integer'.
	self assert: (pu dicImplicit at: $b) equals: 'real'.
	self assert: (pu dicImplicit at: $c) equals: 'integer'.
	self assert: (pu dicImplicit at: $d) equals: 'integer'.
	self assert: (pu dicImplicit at: $e) equals: 'real'.
]

{ #category : #'test - implicit' }
FamixFortran77ResolverTest >> testRegisterImplicitNone [

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

	self assert: pu dicImplicit isEmpty
]

{ #category : #'test - implicit' }
FamixFortran77ResolverTest >> testRegisterImplicitRange [

	"
      subroutine rtn
      implicit integer(a-c)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		attributeAt: #implicits put: { (self implicitRange: #( #($a $c) ) forType: 'integer') };
		yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu dicImplicit size equals: 26.

	self assert: (pu dicImplicit at: $a) equals: 'integer'.
	self assert: (pu dicImplicit at: $b) equals: 'integer'.
	self assert: (pu dicImplicit at: $c) equals: 'integer'.
	self assert: (pu dicImplicit at: $d) equals: 'real'.
]

{ #category : #'test - implicit' }
FamixFortran77ResolverTest >> testRegisterImplicitSimple [

	"
      subroutine rtn
      implicit integer(a)
      end
	"

	| pu |

	pu := (self defaultSubroutine: 'rtn')
		attributeAt: #implicits put: { (self implicitRange: #( #($a) ) forType: 'integer') };
		yourself.

	resolver registerImplicitsForPU: pu.

	self assert: pu dicImplicit size equals: 26.

	self assert: (pu dicImplicit at: $a) equals: 'integer'.
	self assert: (pu dicImplicit at: $b) equals: 'real'.
]

{ #category : #tests }
FamixFortran77ResolverTest >> testRequalifyParameterNoVariableDeclaration [

	"
      subroutine sub(var)
      end
	"

	| sub entity |

	sub := (self newPU: 'sub')
		addParameter: (self defaultParameter: 'var') ;
		yourself.

 	resolver resolve.

	self assert: sub parameters size equals: 1.
	entity := sub parameters anyOne.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'real'.


]

{ #category : #tests }
FamixFortran77ResolverTest >> testRequalifyVariableDeclarationAsFunction [

	"
      subroutine sub
       external fct
      integer fct
      end
	"

	| sub |

	self skip: 'see issue #32'.

	sub := (self defaultSubroutine: 'sub')
		addExternalDeclaration: (self externalDeclaration: 'fct') ;
		addLocalVariable: (self defaultVariable: 'fct' withType: #integer) ;
		yourself.

 	resolver resolve.

	self assert: sub localVariables isEmpty.
	self assert: (resolver model allWithType: FamixF77Variable) isEmpty.

	self assert: sub externalDeclarations size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) size equals: 1.

]

{ #category : #tests }
FamixFortran77ResolverTest >> testRequalifyVariableDeclarationAsParameter [

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

 	resolver resolve.

	self assert: sub localVariables isEmpty.
	self assert: (resolver model allWithType: FamixF77Variable) isEmpty.

	self assert: sub parameters size equals: 1.
	entity := sub parameters anyOne.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'integer'.


]

{ #category : #tests }
FamixFortran77ResolverTest >> testResolveEsopeVariables [

	| sub entity type var |
	"
      subroutine demo
      segment point
      end segment
      pointeur p.point
      end
	"
	type := self newNamedEntity: 'point' toFamix: FamixEsopeSegment.
	type attributes: #(  ).

	var := self newNamedEntity: 'p' toFamix: FamixF77Variable.
	var segment: 'point'.
	var isEsope: true.

	sub := (self newPU: 'demo')
		       addType: type;
		       addLocalVariable: var;
		       yourself.

	resolver resolve.

	self assert: sub localVariables size equals: 1.

	entity := sub localVariables anyOne.
	self assert: entity declaredType equals: type
]

{ #category : #tests }
FamixFortran77ResolverTest >> testResolveFunctionImplicit [

	"
      function fct()
      implicit charcater(f)
      end
	"

	| sub |

	sub := (self defaultFunction: 'fct')
		attributeAt: #implicits put: { (self implicitRange: #( #($f) ) forType: 'character') };
		yourself.

 	resolver resolve.

	self assert: sub declaredType class equals: FamixF77TypeIntrinsic.
	self assert: sub declaredType name equals: 'character'.


]

{ #category : #tests }
FamixFortran77ResolverTest >> testResolveFunctionImplicitWrongParameters [

	"
      function fct()
      implicit character(f)
      end
	"

	| sub |

	sub := self defaultFunction: 'fct'.
	sub addParameter: (self defaultParameter: 'param').
	sub attributeAt: #implicits put: { (self implicitRange: #( #($f) ) forType: 'character') }.

 	resolver resolve.

	self assert: sub declaredType class equals: FamixF77TypeIntrinsic.
	self assert: sub declaredType name equals: 'character'.


]

{ #category : #'test - implicit' }
FamixFortran77ResolverTest >> testResolveImplicitParameter [

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
FamixFortran77ResolverTest >> testResolveImplicitParameterNone [

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
FamixFortran77ResolverTest >> testResolveImplicitParameterRange [

	"
      subroutine sub(var)
      implicit charcater(u-w)
      end
	"

	| entity |

	(self defaultSubroutine: 'sub')
		attributeAt: #implicits put: { self implicitRange: #( #($u $w) ) forType: 'character' } ;
		addParameter: (self defaultParameter: 'var').

 	resolver resolve.

	self assert: (resolver model allWithSubTypesOf: FamixF77ProgramUnit) size equals: 1.
	
	entity := (resolver model allWithSubTypesOf: FamixF77ProgramUnit) first parameters first.
	self assert: entity declaredType class equals: FamixF77TypeIntrinsic.
	self assert: entity declaredType name equals: 'character'.


]

{ #category : #'test-todo' }
FamixFortran77ResolverTest >> testResolveIncludeDirective [

	"
+------ point.seg ----------------------------------+
|      subroutine __$__                             |
|      integer l                                    |
|      segment point                                |
|      real x, y                                    |
|      end segment                                  |
|      end                                          |
+---------------------------------------------------+
+------ main.E -------------------------------------+
|      program main                                 |
|#include ""point.seg""                             |
|      end                                          |
+---------------------------------------------------+
+------ mpoint.E -----------------------------------+
|      subroutine init(p)                           |
|#include ""point.seg""                             |
|      end                                          |
|      subroutine print(p)                          |
|#include ""point.seg""                             |
|      end                                          |
+---------------------------------------------------+
	"

	| dummySub main initSub printSub includedFile mainFile mpointFile pUnits puIncFile puMain puSubs |
	includedFile := self defaultProgramFile: 'point.seg.E'.
	mainFile := self defaultProgramFile: 'main.E'.
	mpointFile := self defaultProgramFile: 'mpoint.E'.

	dummySub := (self
		             defaultProgramUnit: 'point.seg'
		             forType: FamixF77IncludedFile
		             belongsTo: includedFile)
		            types: { (self defaultSegment: 'point' with: { 
						             (#x -> #real).
						             (#y -> #real) }) };
		            localVariables:
			            { (self defaultVariable: 'l' withType: 'integer') };
		            yourself.

	main := (self
		         defaultProgramUnit: 'main'
		         forType: FamixF77PUMain
		         belongsTo: mainFile)
		        includes: { ((self newEntity: FamixF77Include)
				         filename: 'point.seg';
				         yourself) };
		        yourself.

	initSub := (self
		            defaultProgramUnit: 'init'
		            forType: FamixF77PUSubroutine
		            belongsTo: mpointFile)
		           includes: { ((self newEntity: FamixF77Include)
				            filename: 'point.seg';
				            yourself) };
		           yourself.
	printSub := (self
		             defaultProgramUnit: 'print'
		             forType: FamixF77PUSubroutine
		             belongsTo: mpointFile)
		            includes: { ((self newEntity: FamixF77Include)
				             filename: 'point.seg';
				             yourself) };
		            yourself.

	resolver resolve.

	pUnits := resolver model allWithSubTypesOf: FamixF77ProgramUnit.
	self assert: pUnits size equals: 4.

	puIncFile := resolver model allWithType: FamixF77IncludedFile.
	self assert: puIncFile size equals: 1.

	puSubs := resolver model allWithType: FamixF77PUSubroutine.
	self assert: puSubs size equals: 2.

	puMain := resolver model allWithType: FamixF77PUMain.
	self assert: puMain size equals: 1.

	self assert: puMain first includes size equals: 1.
	self
		assert: puMain first includes first included
		equals: puIncFile first.
	"self assert: puMain first localVariables size equals: 1."

	self assert: puSubs first includes size equals: 1.
	self
		assert: puSubs first includes first included
		equals: puIncFile first.
	self assert: puSubs first allLocalVariables size equals: 1.
	self assert: puSubs first allTypes size equals: 1.

	self assert: puSubs second includes size equals: 1.
	self
		assert: puSubs second includes first included
		equals: puIncFile first.
	self assert: puSubs first allLocalVariables size equals: 1.
	self assert: puSubs first allTypes size equals: 1.

	self assert: puIncFile first inclusions size equals: 3
]

{ #category : #tests }
FamixFortran77ResolverTest >> testResolveInvocations [
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
FamixFortran77ResolverTest >> testResolveInvocationsWrongArgumentNumber [
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

{ #category : #'test-todo' }
FamixFortran77ResolverTest >> testResolveSegment [

	| sub access accessor |
	"
      subroutine demo
      segment point
      integer x,y
      end segment
      pointeur p.point
      segini p
      p.x = 1
      p.y = p.x + 1
      end
	"
	accessor := (self
		             newNamedEntity: 'demo'
		             toFamix: FamixF77PUSubroutine)
		            programFile: famixProgFile;
		            addType:
			            ((self
				              newNamedEntity: 'point'
				              toFamix: FamixEsopeSegment) attributes: { 
						             ((self
							               newNamedEntity: 'x'
							               toFamix: FamixFortranAttribute)
							              declaredType:
								              (self
									               newNamedEntity: 'integer'
									               toFamix: FamixF77Type);
							              isEsope: true;
							              yourself).
						             ((self
							               newNamedEntity: 'y'
							               toFamix: FamixFortranAttribute)
							              declaredType:
								              (self
									               newNamedEntity: 'integer'
									               toFamix: FamixF77Type);
							              isEsope: true;
							              yourself) });
		            addLocalVariable:
			            ((self
				              newNamedEntity: 'p'
				              toFamix: FamixF77Variable) declaredType:
				             (self
					              newNamedEntity: 'point'
					              toFamix: FamixF77Type));
		            accesses: { 
				            ((self newEntity: FamixEsopeSegini)
					             attributeAt: #entity
					             put:
						             (self defaultIASTEsopeCommand: 'segini' name: 'p');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'p');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'x');
					             attributeAt: #pointer
					             put: (self defaultIASTVarAccess: 'p');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'p');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'y');
					             attributeAt: #pointer
					             put: (self defaultIASTVarAccess: 'p');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'p');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'x');
					             attributeAt: #pointer
					             put: (self defaultIASTVarAccess: 'p');
					             yourself) }.


	sub := (resolver model allWithSubTypesOf: FamixF77ProgramUnit)
		       first.

	resolver resolve.

	self assert: sub accesses size equals: 7.

	access := sub accesses at: 1.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 2.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 4.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 6.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 3.
	self assert: access variable equals: sub types first attributes first.

	access := sub accesses at: 5.
	self
		assert: access variable
		equals: sub types first attributes second.

	access := sub accesses at: 7.
	self assert: access variable equals: sub types first attributes first
]

{ #category : #'test-todo' }
FamixFortran77ResolverTest >> testResolveSegmentWithImplicitPointer [

	| sub access accessor |
	"
      subroutine demo
      segment point
      integer x,y
      end segment
      segini point
      point.x = 1
      point.y = point.x + 1
      end
	"
	accessor := (self
		             newNamedEntity: 'demo'
		             toFamix: FamixF77PUSubroutine)
		            programFile: famixProgFile;
		            addType:
			            ((self
				              newNamedEntity: 'point'
				              toFamix: FamixEsopeSegment) attributes: { 
						             ((self
							               newNamedEntity: 'x'
							               toFamix: FamixFortranAttribute)
							              declaredType:
								              (self
									               newNamedEntity: 'integer'
									               toFamix: FamixF77Type);
							              isEsope: true;
							              yourself).
						             ((self
							               newNamedEntity: 'y'
							               toFamix: FamixFortranAttribute)
							              declaredType:
								              (self
									               newNamedEntity: 'integer'
									               toFamix: FamixF77Type);
							              isEsope: true;
							              yourself) });
		            accesses: { 
				            ((self newEntity: FamixEsopeSegini)
					             attributeAt: #entity
					             put:
						             (self
							              defaultIASTEsopeCommand: 'segini'
							              name: 'point');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put:
						             (self defaultIASTVarAccess: 'point');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'x');
					             attributeAt: #pointer
					             put:
						             (self defaultIASTVarAccess: 'point');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put:
						             (self defaultIASTVarAccess: 'point');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'y');
					             attributeAt: #pointer
					             put:
						             (self defaultIASTVarAccess: 'point');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put:
						             (self defaultIASTVarAccess: 'point');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'x');
					             attributeAt: #pointer
					             put:
						             (self defaultIASTVarAccess: 'point');
					             yourself) }.


	sub := (resolver model allWithSubTypesOf: FamixF77ProgramUnit)
		       first.

	self assert: sub localVariables size equals: 0.

	resolver resolve.

	self assert: sub accesses size equals: 7.

	self assert: sub localVariables size equals: 1.
	self
		assert: sub localVariables first declaredType class
		equals: FamixEsopeSegment.
	self
		assert: sub localVariables first declaredType name
		equals: 'point'.

	access := sub accesses at: 1.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 2.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 4.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 6.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 3.
	self assert: access variable equals: sub types first attributes first.

	access := sub accesses at: 5.
	self
		assert: access variable
		equals: sub types first attributes second.

	access := sub accesses at: 7.
	self assert: access variable equals: sub types first attributes first
]

{ #category : #'test-todo' }
FamixFortran77ResolverTest >> testResolveSegmentWithImplicitPointerAndNoPrefix [

	| sub access accessor |
	"
      subroutine demo
      segment point
      integer x,y
      end segment
      segini point
      x = 1
      y = x + 1
      end
	"
	accessor := (self
		             newNamedEntity: 'demo'
		             toFamix: FamixF77PUSubroutine)
		            programFile: famixProgFile;
		            addType:
			            ((self
				              newNamedEntity: 'point'
				              toFamix: FamixEsopeSegment) attributes: { 
						             ((self
							               newNamedEntity: 'x'
							               toFamix: FamixFortranAttribute)
							              declaredType:
								              (self
									               newNamedEntity: 'integer'
									               toFamix: FamixF77Type);
							              isEsope: true;
							              yourself).
						             ((self
							               newNamedEntity: 'y'
							               toFamix: FamixFortranAttribute)
							              declaredType:
								              (self
									               newNamedEntity: 'integer'
									               toFamix: FamixF77Type);
							              isEsope: true;
							              yourself) });
		            accesses: { 
				            ((self newEntity: FamixEsopeSegini)
					             attributeAt: #entity
					             put:
						             (self
							              defaultIASTEsopeCommand: 'segini'
							              name: 'point');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'x');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'y');
					             yourself).
				            ((self newEntity: FamixF77Access)
					             attributeAt: #entity
					             put: (self defaultIASTVarAccess: 'x');
					             yourself) }.


	sub := (resolver model allWithSubTypesOf: FamixF77ProgramUnit)
		       first.

	self assert: sub localVariables size equals: 0.

	resolver resolve.

	self assert: sub accesses size equals: 4.

	self assert: sub localVariables size equals: 1.
	self
		assert: sub localVariables first declaredType class
		equals: FamixEsopeSegment.
	self
		assert: sub localVariables first declaredType name
		equals: 'point'.

	access := sub accesses at: 1.
	self assert: access variable equals: sub localVariables first.

	access := sub accesses at: 2.
	self assert: access variable equals: sub types first attributes first.

	access := sub accesses at: 3.
	self
		assert: access variable
		equals: sub types first attributes second.

	access := sub accesses at: 4.
	self assert: access variable equals: sub types first attributes first
]
