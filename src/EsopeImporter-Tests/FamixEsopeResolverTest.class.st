Class {
	#name : 'FamixEsopeResolverTest',
	#superclass : 'FamixEsopeUtilitiesTest',
	#instVars : [
		'resolver'
	],
	#category : 'EsopeImporter-Tests-Importer',
	#package : 'EsopeImporter-Tests',
	#tag : 'Importer'
}

{ #category : 'running' }
FamixEsopeResolverTest >> setUp [

	super setUp.

	resolver := FamixEsopeResolver on: mooseModel.
]

{ #category : 'tests' }
FamixEsopeResolverTest >> testFamixEsopeSegmentWithAccessToLocalVariable [

    "
    subroutine demo
    integer nb
    segment foo
     integer bar(nb) ! We only consider the 'nb' access in the model, the 'bar' variable declaration is not necessary for this test.
    end segment
    end subroutine
    "

    | access sub  variable |

    access := (self defaultAccess: 'nb').

    variable := self defaultVariable: 'nb' withType: #integer.
    sub := (self newPU: 'demo')
        addLocalVariable: variable;
        addType: ( (self defaultSegment: 'PSTR' with: #()) addAccess: access );
        yourself.

    resolver resolveAccesses.

    self assert: access variable equals: variable
]

{ #category : 'tests' }
FamixEsopeResolverTest >> testFamixEsopeSegmentWithAccessToUndeclaredVariable [

    "
    subroutine demo
    segment foo
     integer bar(nb) ! We only consider the 'nb' access in the model, the 'bar' variable declaration is not necessary for this test
    end segment
    end subroutine
    "

    | access sub |

    access := (self defaultAccess: 'nb').
    sub := (self newPU: 'demo')
         addType: ( (self defaultSegment: 'PSTR' with: #()) addAccess: access );
        yourself.

    resolver resolveAccesses.

    self assert: access variable isNotNil.
    self assert: access variable class equals: FamixF77Variable.
    self assert: access variable parentBehaviouralEntity equals: sub.
    self assert: access variable name equals: 'nb'
]

{ #category : 'tests' }
FamixEsopeResolverTest >> testMakePointerFromVariable [
	"We have a pointer variable and a normal variable with the same name
	 the 2nd should be merged into the 1st which keeps its declared type and
	 gets the accesses of the 2nd"

	| subroutine variable pointer esopeCommand |

	subroutine := self defaultSubroutine: 'sub'.

	variable := self defaultVariable: 'pointerForASegment' withType: FamixF77TypeIntrinsic new.
	variable parentBehaviouralEntity: subroutine.
	pointer  := self defaultVariable: 'pointerForASegment' withType: FamixEsopeSegment new.
	pointer parentBehaviouralEntity: subroutine.

	resolver model newAccess
		accessor: subroutine ;
		variable: variable.
	esopeCommand := resolver model newCommandSegini
		accessor: subroutine ;
		variable: pointer.

	self assert: subroutine accesses size equals: 2.
	self assert: subroutine localVariables size equals: 2.

	resolver makePointerVariableForEsopeCommand: esopeCommand.

	self assert: subroutine accesses size equals: 2.
	self assert: subroutine localVariables size equals: 1.
]

{ #category : 'tests' }
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

{ #category : 'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitDefault [

	"
	      subroutine rtn
	      end
	"

	| pu |

	pu := self defaultSubroutine: 'rtn'.

	pu registerImplicits.

	self assert: pu implicitDictionary size equals: 26.
	
	"testing a few of them"
	self assert: (pu implicitDictionary at: $a) equals: 'real'.
	self assert: (pu implicitDictionary at: $i) equals: 'integer'.
]

{ #category : 'test - implicit' }
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

	pu registerImplicits.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'real'.
	self assert: (pu implicitDictionary at: $c) equals: 'integer'.
	self assert: (pu implicitDictionary at: $d) equals: 'integer'.
	self assert: (pu implicitDictionary at: $e) equals: 'real'
]

{ #category : 'test - implicit' }
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

	pu registerImplicits.

	self assert: pu implicitDictionary isEmpty
]

{ #category : 'test - implicit' }
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

	pu registerImplicits.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'integer'.
	self assert: (pu implicitDictionary at: $c) equals: 'integer'.
	self assert: (pu implicitDictionary at: $d) equals: 'real'
]

{ #category : 'test - implicit' }
FamixEsopeResolverTest >> testRegisterImplicitSegment [

	"
      program main
      segment point
      end segment
      end
	"

	| typePoint main |
	typePoint := self newEntity: FamixEsopeSegment named: 'point'.
	typePoint attributes: #().

	main := (self defaultMain: 'main')
		addType: typePoint;
		yourself.

	main registerImplicits.

	self assert: main implicitDictionary size equals: 27.

	self assert: (main implicitDictionary at: 'point') equals: 'point'
]

{ #category : 'test - implicit' }
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

	pu registerImplicits.

	self assert: pu implicitDictionary size equals: 26.

	self assert: (pu implicitDictionary at: $a) equals: 'integer'.
	self assert: (pu implicitDictionary at: $b) equals: 'real'
]

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'test - resolveAccess' }
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

{ #category : 'test - resolveAccess' }
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

{ #category : 'test - resolveAccess' }
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

{ #category : 'test - resolveAccess' }
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

{ #category : 'test - resolveAccess' }
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

{ #category : 'test - resolveAccess' }
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

	resolver registerImplicitsDeclarations.
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

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesForAnAttribute [

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

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesFromStatementFunctionToParameter [
	"program main
	 identity(x) = x
	 end
	"

	| fct access  var |

	fct := self newEntity: FamixF77StatementFunction named: 'identity'.
	fct
		parentEntity: (self defaultMain: 'main') ;
		addParameter: (self newEntity: FamixF77Parameter named: 'x') ;
		addAccess: (self defaultAccess: 'x').

 	resolver resolveAccesses.

	self assert: fct parameters size equals: 1.
	var := fct parameters anyOne.
	self assert: var name equals: 'x'.

	self assert: fct accesses size equals: 1.

	access := fct accesses anyOne.
	self assert: access variable equals: var.

]

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesFromStatementFunctionToParentLocalVariable [
	"program main
	 var = 1
	 constant(x) = var
	 end
	"

	| main fct var |

	main := (self defaultMain: 'main')
		addLocalVariable: (self defaultVariable: 'var' withType: #integer);
		addAccess: (self defaultAccess: 'var');
		yourself.

	fct := self newEntity: FamixF77StatementFunction named: 'constant'.
	fct
		parentEntity: main ;
		addParameter: (self newEntity: FamixF77Parameter named: 'x') ;
		addAccess: (self defaultAccess: 'var').

 	resolver resolveAccesses.

	self assert: fct localVariables size equals: 0.

	var := fct parameters anyOne.
	self assert: var incomingAccesses size equals: 0.

	var := main localVariables anyOne.
	self assert: var incomingAccesses size equals: 2.
	self assert: fct accesses anyOne variable equals: var.
]

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesInIncludedFileToInside [
	"Resolve accesses from includedFile to variable declared in the same includedIile

      subroutine _$file_inc
      integer var
      var = 2
      end
	"

	| accessor access  |
	accessor := self newEntity: FamixF77IncludedFile named: 'file.inc'.
	accessor
		addLocalVariable: (self defaultVariable: 'var' withType: #integer);
		addAccess: (self defaultAccess: 'var').

 	resolver resolveAccesses.

	self assert: accessor accesses size equals: 1.
	access := accessor accesses first.

	self assert: access variable equals: accessor localVariables first.
]

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveAccessesInIncludedFileToOutside [
	"Do not resolve accesses from includedFile to variable declared outside the same includedIile
	 (because resolution depends on where the file is included)

      subroutine _$file_inc
      var = 2
      end
	"

	| accessor access  |
	accessor := self newEntity: FamixF77IncludedFile named: 'file.inc'.
	accessor
		addAccess: (self defaultAccess: 'var').

 	resolver resolveAccesses.

	self assert: accessor accesses size equals: 1.
	access := accessor accesses first.

	self assert: access variable class equals: FamixF77UnknownVariable.
	self assert: access variable name equals: 'var'.
]

{ #category : 'tests' }
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

{ #category : 'tests' }
FamixEsopeResolverTest >> testResolveDeclaredTypeOfPointersStubSegment [

	| sub entity var |
	"
      subroutine demo
      pointeur p.point
      end
	"
	var := self newEntity: FamixF77Variable named: 'p'.
	var segment: 'point'.
	var isEsope: true.

	sub := (self newPU: 'demo')
		addLocalVariable: var;
		yourself.

	resolver resolveDeclaredTypeOfPointers.

	self assert: sub localVariables size equals: 1.

	entity := sub localVariables anyOne.
	self assert: entity declaredType class equals: FamixEsopeSegment.
	self assert: entity declaredType name equals: 'point'.
	self assert: entity declaredType isStub
		
]

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveExternalDeclarationWhereProcedureIsInTheModel [
	"fct is defined in the model"

	"subroutine sub
	 external fct
	 end
	"

	| subroutine  externalFunction externalResolved |

	subroutine := (self defaultSubroutine: 'main')
		addExternalDeclaration: (self externalDeclaration: 'fct') ;
		yourself.

	self assert: subroutine localVariables size equals: 0.
	self assert: subroutine externalDeclarations size equals: 1.
	
	externalFunction := FamixF77PUFunction new 
		name: 'fct';
		mooseModel: resolver model;
		yourself.

 	resolver resolve.

	self assert: subroutine localVariables size equals: 0.
	self assert: (resolver model allWithType: FamixF77Variable) size equals: 0.

	self assert: subroutine externalDeclarations size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) size equals: 1.

	externalResolved := (resolver model allWithType: FamixF77ExternalDeclaration) anyOne.
	self assert: externalResolved class equals: FamixF77ExternalDeclaration.
	self assert: externalResolved name equals: 'fct'.
	self assert: externalResolved externalProcedure equals: externalFunction
]

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveExternalDeclarationWhereProcedureIsNotInTheModel [
	"fct is not defined in the model"

	"subroutine sub
	 external mypnt
	 end
	"

	| subroutine externalResolved |

	subroutine := (self defaultSubroutine: 'main')
		addExternalDeclaration: (self externalDeclaration: 'mypnt') ;
		yourself.

	self assert: subroutine localVariables size equals: 0.
	self assert: subroutine externalDeclarations size equals: 1.

 	resolver resolve.

	self assert: subroutine localVariables size equals: 0.
	self assert: (resolver model allWithType: FamixF77Variable) size equals: 0.

	self assert: subroutine externalDeclarations size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) size equals: 1.

	externalResolved := (resolver model allWithType: FamixF77ExternalDeclaration) anyOne.
	self assert: externalResolved class equals: FamixF77ExternalDeclaration.
	self assert: externalResolved name equals: 'mypnt'.

	self assert: externalResolved externalProcedure isNotNil.
	self assert: externalResolved externalProcedure class equals: FamixEsopeIntrinsicProcedure.
	self assert: externalResolved externalProcedure name equals: 'mypnt'
]

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveExternalFunction [
	"subroutine sub
	 integer n
	 external fct
	 integer fct
	 end
	"

	| subroutine  |

	subroutine := (self defaultSubroutine: 'main')
		addLocalVariable: (self defaultVariable: 'aVar' withType: #integer) ;
		addExternalDeclaration: (self externalDeclaration: 'fct') ;
		addLocalVariable: (self defaultVariable: 'fct' withType: #integer) ;
		yourself.

	self assert: subroutine localVariables size equals: 2.
	self assert: subroutine externalDeclarations size equals: 1.

 	resolver resolve.

	self assert: subroutine localVariables size equals: 1.
	self assert: (resolver model allWithType: FamixF77Variable) size equals: 1.
	self assert: subroutine localVariables anyOne name equals: 'aVar'.

	self assert: subroutine externalDeclarations size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) anyOne name equals: 'fct'.
]

{ #category : 'test - resolveAccess' }
FamixEsopeResolverTest >> testResolveExternalFunctionWithoutVariableDeclaration [
	"subroutine sub
	 external fct
	 end
	"

	| subroutine  |

	subroutine := (self defaultSubroutine: 'main')
		addExternalDeclaration: (self externalDeclaration: 'fct') ;
		yourself.

	self assert: subroutine localVariables size equals: 0.
	self assert: subroutine externalDeclarations size equals: 1.

 	resolver resolve.

	self assert: subroutine localVariables size equals: 0.
	self assert: (resolver model allWithType: FamixF77Variable) size equals: 0.

	self assert: subroutine externalDeclarations size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) size equals: 1.
	self assert: (resolver model allWithType: FamixF77ExternalDeclaration) anyOne name equals: 'fct'.
]

{ #category : 'test - implicit' }
FamixEsopeResolverTest >> testResolveFunctionNameAsNonLocalVariable [

	| fct access |
	
	access := self newEntity: FamixF77Access.
	access attributeAt: #entity put: (self defaultIASTVarAccess: 'f').
	fct := self defaultFunction: 'f'.
	fct addAccess: access.

	resolver resolveAccesses.

	self assert: fct localVariables size equals: 0
]

{ #category : 'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitFunctionType [

	| fct |
	fct := self defaultFunction: 'f'.

	resolver resolveImplicitFunctionType: fct.

	self assert: fct declaredType class equals: FamixF77TypeIntrinsic.
	self assert: fct declaredType name equals: 'real'
]

{ #category : 'test - implicit' }
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

{ #category : 'test - implicit' }
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

{ #category : 'test - implicit' }
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

{ #category : 'tests' }
FamixEsopeResolverTest >> testResolveImplicitPointer [

	| sub type var |
	"
      subroutine demo
      segment point
      end segment
      segini point
      end
	"
	type := self newEntity: FamixEsopeSegment named: 'point'.
	type attributes: #().

	sub := (self newPU: 'demo')
		addType: type;
		yourself.

	var := self defaultVariable: 'point' withType: (self defaultType: 'real').
	(self newEntity: FamixEsopeCommandSegini)
		accessor: sub ;
		variable: var.

	resolver resolveDeclaredTypeOfPointers.

	self assert: var declaredType equals: type
]

{ #category : 'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitType [

	| sub |
	sub := self defaultSubroutine: 'sub'.

	sub registerImplicitSegment: (self defaultSegment: 'point' with: #()).

	self assert: (sub implicitTypeFor: 'aVar') equals: 'real'.
	self assert: (sub implicitTypeFor: 'i') equals: 'integer'.
	self assert: (sub implicitTypeFor: 'x') equals: 'real'.
	self assert: (sub implicitTypeFor: 'point') equals: 'point'.

]

{ #category : 'test - implicit' }
FamixEsopeResolverTest >> testResolveImplicitTypeInStatementFunction [

	| sub f |
	sub := self defaultSubroutine: 'sub'.
	sub registerImplicitSegment: (self defaultSegment: 'point' with: #()).

	f := self newEntity: FamixF77StatementFunction named: 'f'.
	f parentEntity: sub.

	self assert: (f implicitTypeFor: 'aVar') equals: 'real'.
	self assert: (f implicitTypeFor: 'i') equals: 'integer'.
	self assert: (f implicitTypeFor: 'x') equals: 'real'.
	self assert: (f implicitTypeFor: 'point') equals: 'point'.

]

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'tests' }
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

{ #category : 'test - implicit' }
FamixEsopeResolverTest >> testResolveIntegerFunctionType [

	| fct |
	fct := self defaultFunction: 'f'.
	fct declaredType: (FamixF77TypeIntrinsic new name: #integer).

	resolver resolveImplicitFunctionType: fct.

	self assert: fct declaredType class equals: FamixF77TypeIntrinsic.
	self assert: fct declaredType name equals: #integer
]

{ #category : 'tests' }
FamixEsopeResolverTest >> testResolveInvocationToIntrinsic [
	| invocation caller |
	
	caller := (self defaultMain: 'main')
		addOutgoingInvocation: (self defaultInvocation: 'cos');
		yourself.

 	resolver resolve.

	self assert: caller outgoingInvocations size equals: 1.
	invocation := caller outgoingInvocations first.
	
	self assert: invocation class equals: FamixF77Invocation.
	self assert: invocation sender equals: caller.
	
	self assert: invocation candidates size equals: 1.
	self assert: invocation candidates first class equals: FamixF77IntrinsicRoutine.
]

{ #category : 'tests' }
FamixEsopeResolverTest >> testResolveInvocationToWrite [
	| invocation caller |
	
	caller := (self defaultMain: 'main')
		addOutgoingInvocation: (self defaultInvocation: 'write');
		yourself.

 	resolver resolve.

	self assert: caller outgoingInvocations size equals: 1.
	invocation := caller outgoingInvocations first.
	
	self assert: invocation class equals: FamixF77Invocation.
	self assert: invocation sender equals: caller.
	
	self assert: invocation candidates size equals: 1.
	self assert: invocation candidates first class equals: FamixF77IntrinsicRoutine.
]

{ #category : 'tests' }
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

{ #category : 'tests' }
FamixEsopeResolverTest >> testResolveInvocationsWrongArgumentNumber [
	| invocation callee caller |
	
	self skip: 'Famix does not model arguments, so we cannot resolve based on their number'.
	
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

{ #category : 'tests' }
FamixEsopeResolverTest >> testResolveSegmentWithAttributes [

	| sub entity segment attribute |
	"
      subroutine demo
      SEGMENT , PSTR
        CHARACTER*8 NOMCOD, DATE
      ENDSEGMENT
      end
	"
	segment := self defaultSegment: 'PSTR' with: { 
			           (#NOMCOD -> #character).
			           (#DATE -> #character) }.

	sub := (self newPU: 'demo')
		addType: segment;
		yourself.

	resolver resolve.

	self assert: sub localVariables size equals: 0.
	self assert: sub types size equals: 1.

	entity := sub types anyOne.
	self assert: entity class equals: FamixEsopeSegment.
	self assert: entity name equals: 'PSTR'.
	self assert: entity attributes size equals: 2.
	
	attribute := entity attributes first.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute declaredType class equals: FamixF77TypeIntrinsic.
	self assert: attribute name equals: 'NOMCOD'.
	
	attribute := entity attributes second.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute declaredType class equals: FamixF77TypeIntrinsic.
	self assert: attribute name equals: 'DATE'.
		
]
