"
An IASTVisitorF77Test is a test class for testing the behavior of IASTVisitorF77
"
Class {
	#name : #IASTToFamixVisitorTest,
	#superclass : #TestCase,
	#instVars : [
		'visitor',
		'programFile'
	],
	#category : #'EsopeImporter-Tests-Visitor'
}

{ #category : #running }
IASTToFamixVisitorTest >> anchorFrom: startPoint to: endPoint [

	^ IASTIndexedFileAnchor new
		  startLine: startPoint x;
		  startColumn: startPoint y;
		  endLine: endPoint x;
		  endColumn: endPoint y;
		  fileName: 'fortran77.f';
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultAnchor [

	^ self anchorFrom: 1 @ 7 to: 2 @ 10
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultEmptySegment: segmentName [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: {  };
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultImplicitNone [

	^ IASTImplicit new
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultNamedEntity: entityName for: aClassName [

	^ aClassName new
		  sourceAnchor: self defaultAnchor;
		  entityName: entityName;
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultParameter [

	^ IASTParameter new
		  entityName: 'var';
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultSegment: segmentName [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: {  };
		  yourself
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultSegment: segmentName with: dictDeclarations [

	^ IASTEsopeSegment new
		  sourceAnchor: self defaultAnchor;
		  entityName: segmentName;
		  declarations: (dictDeclarations collect: [ :assoc | 
					   self defaultVariable: assoc key withType: assoc value ]);
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultSegmentComand: commandName on: varName [

	^ IASTEsopeSegCommand new
		  esopeCommand: commandName;
		  entityName: varName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultType: typeName [

	^ IASTTypeRef new
		  entityName: typeName;
		  sourceAnchor: self defaultAnchor;
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultVarAccess: name [

	^ self defaultVarAccess: name isWrite: false
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultVarAccess: name isWrite: boolean [

	^ IASTVarAccess new
		  sourceAnchor: self defaultAnchor;
		  isWrite: boolean;
		  entityName: name;
		  yourself
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultVarEsoAt: entities [

	^ IASTVarEsoAt new
		  sourceAnchor: self defaultAnchor;
		  entities:
			  (entities collect: [ :entity | self defaultVarAccess: entity ]);
		  yourself
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultVarEsoSl: entities [

	^ IASTVarEsoSl new
		  sourceAnchor: self defaultAnchor;
		  entities:
			  (entities collect: [ :entity | self defaultVarAccess: entity ]);
		  yourself
]

{ #category : #'default values' }
IASTToFamixVisitorTest >> defaultVariable: assoc [

	^ IASTVariable new
		  sourceAnchor: self defaultAnchor;
		  entityName: assoc key;
		  typeSpec: (IASTTypeRef new
				   sourceAnchor: self defaultAnchor;
				   entityName: assoc value;
				   yourself);
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> defaultVariable: varName withType: typeName [

	^ IASTVariable new
		  sourceAnchor: self defaultAnchor;
		  entityName: varName;
		  typeSpec: (self defaultType: typeName);
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> implicitRule: typeName range: ranges [

	^ IASTImplicitTypingRule new
		  forType: (self defaultType: typeName);
		  ranges: ranges;
		  yourself
]

{ #category : #running }
IASTToFamixVisitorTest >> jsonToIAST: jsonCode [
	| jsonVisitor |
	jsonVisitor := JsonToIASTVisitor new.
	^jsonVisitor visitProgramFile: (NeoJSONReader fromString: jsonCode)
]

{ #category : #running }
IASTToFamixVisitorTest >> setUp [
	super setUp.
	
	programFile := IASTProgramFile new filename: 'fortran77.f' ; yourself.
	visitor := IASTToFamixFortranVisitor new.
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testComment [

	| entity comment |

	programFile progUnits: { IASTMainProgram new
			 entityName: 'main';
			 body: { IASTComment new
		           text: 'a normal comment';
		           yourself. };
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.
	self assert: entity programUnits first comments size equals: 1.

	comment := entity programUnits first comments first.
	self assert: comment class equals: FamixF77Comment.
	self assert: comment content equals: 'a normal comment'.
	self deny: comment isEsope.
	
	self assert: comment commentedEntity equals: entity programUnits first.
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateDummyFamixFortran77Subroutine [

	"
      subroutine _$aFile_inc
      integer l
c@_   segment point
      real abs, ord
c@_   end segment
      end
	"

	| l segment entity |
	l := self defaultVariable: 'l' withType: 'integer'.
	segment := self defaultSegment: 'point' with: { 
			           (#abs -> #real).
			           (#ord -> #real) }.

	programFile progUnits: { (IASTIncludedFile new
			 entityName: '_$aFile_inc';
			 sourceAnchor: self defaultAnchor;
			 body: { 
					 l.
					 segment };
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77IncludedFile.
	self assert: entity name equals: '_$aFile_inc'.

	self assert: entity programFile isNotNil.
	self assert: entity inclusions isEmpty.

	self assert: entity types size equals: 1.
	self assert: entity types first name equals: 'point'.
	self assert: entity types first attributes size equals: 2.
	self assert: entity types first attributes first name equals: 'abs'.
	self assert: entity types first attributes second name equals: 'ord'.


	self assert: entity localVariables size equals: 1.
	self assert: entity localVariables first name equals: 'l'
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeAccessors [

	"
	d__(ptr,attr)
	"

	| d__ entity access var |
	d__ := self defaultVarEsoAt: #( #ptr #attr ).

	entity := (FamixF77PUSubroutine new).
	visitor stack push: entity.

	d__ accept: visitor.

	self assert: entity accesses size equals: 2.

	access := entity accesses detect: [:acc | (acc attributeAt: #parentAccess ifAbsent: [ nil ]) isNil ].

	var := access attributeAt: #entity ifAbsent: [ nil ].
	self assert: var isNotNil.
	self assert: var entityName equals: 'ptr'.

	access := access attributeAt: #attributeAccess ifAbsent: [ nil ].
	self assert: access isNotNil.

	var := access attributeAt: #entity ifAbsent: [ nil ].
	self assert: var isNotNil.
	self assert: var entityName equals: 'attr'.
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeAccessorsWithArg [

	"
	d__(ptr,attr(i))
	"

	| d__ entity access var |
	d__ := (self defaultNamedEntity: 'd__' for: IASTVarEsoAt) entities:
		       { 
			       (self defaultNamedEntity: 'ptr' for: IASTVarAccess).
			       ((self defaultNamedEntity: 'attr' for: IASTInvocation) 
				        arguments:
				        { (self defaultNamedEntity: 'i' for: IASTParameter) }) }.

	entity := (FamixF77PUSubroutine new).
	visitor stack push: entity.

	d__ accept: visitor.

	self assert: entity accesses size equals: 3.

	access := entity accesses detect: [:acc | (acc attributeAt: #attributeAccess ifAbsent: [ nil ]) isNotNil ].
	
	var := access attributeAt: #entity ifAbsent: [ nil ].
	self assert: var entityName equals: 'ptr'.

	access := access attributeAt: #attributeAccess ifAbsent: [ nil ].
	self assert: access isNotNil.

	var := access attributeAt: #entity ifAbsent: [ nil ].
	self assert: var isNotNil.
	self assert: var entityName equals: 'attr'.

	access := entity accesses detect: [:acc |
		(acc attributeAt: #attributeAccess ifAbsent: [ nil ]) isNil and: 
		[ (acc attributeAt: #parentAccess ifAbsent: [ nil ]) isNil ] ].
	
	var := access attributeAt: #entity ifAbsent: [ nil ].
	self assert: var entityName equals: 'i'.

]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeAccessorsWithArgsWithDot [

	"
	d__(ptr,attr(i,d__(p,j)))
	"

	| d__ entity accesses var |
	d__ := (self defaultNamedEntity: 'd__' for: IASTVarEsoAt) entities:
		       { 
			       (self defaultNamedEntity: 'ptr' for: IASTVarAccess).
			       ((self defaultNamedEntity: 'attr' for: IASTInvocation) 
				        arguments: { 
						        (self defaultNamedEntity: 'i' for: IASTParameter).
						        ((self defaultNamedEntity: nil for: IASTVarEsoAt) 
							         entities: { 
									         (self defaultNamedEntity: 'p' for: IASTParameter).
									         (self defaultNamedEntity: 'j' for: IASTParameter) }) }) }.

	entity := (FamixF77PUSubroutine new).
	visitor stack push: entity.

	d__ accept: visitor.

	self assert: entity accesses size equals: 5.

	accesses := entity accesses select: [:acc | (acc attributeAt: #attributeAccess ifAbsent: [ nil ]) isNotNil ].

	self assert: accesses size equals: 2.
	accesses do: [ :acc |
		var := acc attributeAt: #entity ifAbsent: [ nil ].
		self assert: ((var entityName = 'ptr') or: (var entityName = 'p')).
		self assert: (acc attributeAt: #parentAccess ifAbsent: [ nil ]) isNil.
	].

	accesses := entity accesses select: [:acc | (acc attributeAt: #parentAccess ifAbsent: [ nil ]) isNotNil ].

	self assert: accesses size equals: 2.
	accesses do: [ :acc |
		var := acc attributeAt: #entity ifAbsent: [ nil ].
		self assert: ((var entityName = 'attr') or: (var entityName = 'j')).
		self assert: (acc attributeAt: #attributeAccess ifAbsent: [ nil ]) isNil.
	].

	accesses := entity accesses select: [:acc |
		(acc attributeAt: #attributeAccess ifAbsent: [ nil ]) isNil and: 
		[ (acc attributeAt: #parentAccess ifAbsent: [ nil ]) isNil ] ].
	
	self assert: accesses size equals: 1.
	var := accesses anyOne attributeAt: #entity ifAbsent: [ nil ].
	self assert: var isNotNil.
	self assert: var entityName equals: 'i'

]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeCommandSegini [

	"
	segini ptr
	"

	| famixSegini iastSegini progFile |
	iastSegini := self defaultSegmentComand: 'segini' on: 'ptr'.

	programFile progUnits: { IASTSubroutine new
			 entityName: 'sub';
			 body: { iastSegini };
			 yourself }.

	progFile := programFile accept: visitor.
	
	self assert: progFile programUnits size equals: 1.

	self assert: (visitor model allWithType: FamixEsopeCommand) size equals: 1.
	famixSegini := (visitor model allWithType: FamixEsopeCommand) first.
	self assert: famixSegini commandName equals: 'segini'.
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopePointerDeclaration [
"      program main
      segment, pers
      end segment
      pointeur p1.pers
      end
"

	| entity |
	programFile := self jsonToIAST: '{"meta":{"miVersion":"fortran77","miFilename":"/home/anquetil/Pharo/images/carrefourFortran-0901/Fortran/fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"comment":"@_   segment, pers","span":"(2:1)-(2:19)","tag":"comment"},{"anno":[],"comment":"@_   end segment","span":"(3:1)-(3:17)","tag":"comment"},{"anno":[],"comment":"@_   pointeur p1.pers","span":"(4:1)-(4:22)","tag":"comment"}],"name":"main","span":"(1:7)-(5:9)","subprograms":null,"tag":"main"}]}'.
	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self
		assert: (visitor model allWithType: FamixF77Variable) size
		equals: 1. "p1"

	entity := (visitor model allWithType: FamixF77Variable) first.
	self assert: entity isEsope.
	self assert: entity name equals: 'p1'.
	self assert: entity segment equals: 'pers'.

]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeSegment [

	"
	segment myseg
	 character uname
	 logical status
	 integer age
	end segment
	"

	| segment entity attribute |
	segment := self defaultSegment: 'myseg' with: { 
			           (#uname -> #character).
			           (#status -> #logical).
			           (#age -> #integer) }.

	programFile progUnits: { IASTSubroutine new
			 entityName: 'sub';
			 body: { segment };
			 yourself }.

	entity := programFile accept: visitor.
	
	self assert: entity programUnits size equals: 1.

	self assert: (visitor model allWithType: FamixEsopeSegment) size equals: 1.
	entity := (visitor model allWithType: FamixEsopeSegment) first.
	self assert: entity name equals: 'myseg'.
	self assert: entity isType.
	self assert: entity attributes size equals: 3.
	
	self assert: entity attributes size equals: 3.
	attribute := entity attributes first.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'uname'.
	self assert: attribute declaredType name equals: 'character'.
	
	attribute := entity attributes second.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'status'.
	self assert: attribute declaredType name equals: 'logical'.
	
	attribute := entity attributes third.
	self assert: attribute class equals: FamixFortranAttribute.
	self assert: attribute name equals: 'age'.
	self assert: attribute declaredType name equals: 'integer'.
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixEsopeSlashWithLitteralDim [

	"
c  ptr.attr(/1)
	s__(d__(ptr,attr),1)
	"

	| s__ entity access |
	self skip.
	self flag: #TODO.
	s__ := self defaultVarEsoSl: #( #ptr #attr ).

	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { s__ };
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	self assert: entity programUnits first accesses size equals: 2.

	access := entity programUnits first accesses first.
	self assert: access target isNil.
	self assert: (access attributeAt: #entity ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #entity ifAbsent: [  ]) entityName
		equals: 'ptr'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNil.


	access := entity programUnits first accesses second.
	self assert: access target isNil.
	self assert: (access attributeAt: #entity ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #entity ifAbsent: [  ]) entityName
		equals: 'attr'.
	self assert: (access attributeAt: #pointer ifAbsent: [  ]) isNotNil.
	self
		assert: (access attributeAt: #pointer ifAbsent: [  ]) entityName
		equals: 'ptr'
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77 [

	| entity |
	programFile progUnits: { IASTSubroutine new
		entityName: 'sub';
		body: #();
		yourself
	}.
	programFile accept: visitor.

	self assert: visitor model size equals: 7.
	
	entity := visitor model allWithType: FamixF77ProgramFile.
	self assert: entity size equals: 1.

	entity := visitor model detect: [:each | each class = FamixF77ProgramFile ].
	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUSubroutine.
	self assert: entity name equals: 'sub'.

]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateFamixFortran77ESOAtWithArrayArgument [
"Special case of a D__ function call with an array as argument

      subroutine hello
        integer arr(10)
> > >   x = D__(y,arr(z))  < < <
      end
"
	self skip.

	programFile := self jsonToIAST: '{"meta":{"miVersion":"fortran77","miFilename":"/tmp/tmp.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:23)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"dims":{"anno":[],"list":[{"anno":[],"lower":null,"span":"(2:21)-(2:22)","upper":{"anno":[],"span":"(2:21)-(2:22)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}}],"span":"(2:21)-(2:22)"},"initial":null,"length":null,"span":"(2:17)-(2:23)","type":"array","variable":{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"arr","tag":"variable"}}}],"span":"(2:17)-(2:23)"},"span":"(2:9)-(2:23)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:9)-(2:15)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:9)-(3:25)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(3:17)-(3:17)","tag":"value","value":{"contents":"y","tag":"variable"}},"tag":"expr"},"name":null,"span":"(3:17)-(3:17)"},{"anno":[],"expr":{"contents":{"anno":[],"expression":{"anno":[],"span":"(3:19)-(3:21)","tag":"value","value":{"contents":"arr","tag":"variable"}},"indices":{"anno":[],"list":[{"anno":[],"index":{"anno":[],"span":"(3:23)-(3:23)","tag":"value","value":{"contents":"z","tag":"variable"}},"name":null,"span":"(3:23)-(3:23)","tag":"single"}],"span":"(3:23)-(3:23)"},"span":"(3:19)-(3:24)","tag":"subscript"},"tag":"expr"},"name":null,"span":"(3:19)-(3:24)"}],"span":"(3:17)-(3:24)"},"function":{"anno":[],"span":"(3:13)-(3:15)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(3:13)-(3:25)","tag":"function_call"},"span":"(3:9)-(3:25)","tag":"assign_expression","target":{"anno":[],"span":"(3:9)-(3:9)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.
	programFile accept: visitor.

	self assert: (visitor model allWithType: FamixF77Variable) size equals: 1. "arr"
	self assert: (visitor model allWithType: FamixF77Access) size equals: 4. "x, y, arr, z"

]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77Invocation [
	| entity invocation caller callee |

	callee := IASTSubroutine new
		entityName: 'sub';
		yourself.

	caller := IASTMainProgram new
			entityName: 'main';
			body: { IASTInvocation new entityName: 'sub'; yourself };
			yourself.
	programFile progUnits: { callee . caller }.

	programFile accept: visitor.
	entity := visitor model detect: [:each | each class = FamixF77ProgramFile ].

	self assert: entity programUnits first class equals: FamixF77PUSubroutine.
	self assert: entity programUnits second class equals: FamixF77PUMain.

	self assert: entity programUnits second outgoingInvocations size equals: 1.
	invocation := entity programUnits second outgoingInvocations first.
	
	self assert: invocation class equals: FamixF77Invocation.
	self assert: invocation sender equals: entity programUnits second.
	self assert: (invocation attributeAt: #entity ifAbsent: [ nil ] ) isNotNil
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77LocalVariable [

	| entity var |
	programFile progUnits: { IASTSubroutine new
			 entityName: 'sub';
			 body: { (self defaultVariable: 'aVar' withType: 'integer') };
			 yourself }.
	programFile accept: visitor.

	entity := visitor model detect: [:each | each class = FamixF77ProgramFile ].

	self assert: entity programUnits first localVariables size equals: 1.

	var := entity programUnits first localVariables first.
	self assert: var class equals: FamixF77Variable.
	self assert: var name equals: 'aVar'.
	self assert: var declaredType class equals: FamixF77TypeIntrinsic.
	self assert: var declaredType name equals: 'integer'.
	self assert: var parentBehaviouralEntity isNotNil.
	self
		assert: var parentBehaviouralEntity
		equals: entity programUnits first
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUBlockdata [

	| entity |
	programFile progUnits: { IASTBlockData new
			 entityName: 'bdata';
			 yourself
	}.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUBlockdata.
	self assert: entity name equals: 'bdata'.
	self assert: entity programFile isNotNil.
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUComment [
	| entity |
	programFile progUnits: { IASTComment new
		text: ' a comment' ;
		isProgUnit: true ;
		yourself  
	}.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUComment.
	self assert: entity content equals: ' a comment'.
	self assert: entity programFile isNotNil.
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUFunction [

	| entity |
	programFile progUnits: { IASTFunction new
			 entityName: 'fct';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUFunction.
	self assert: entity name equals: 'fct'.
	self assert: entity programFile isNotNil.
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUFunctionWithParameter [

	| entity param |
	programFile progUnits: { IASTFunction new
			 entityName: 'fct';
			 parameters: { self defaultParameter };
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUFunction.
	self assert: entity name equals: 'fct'.
	self assert: entity programFile isNotNil.

	self assert: entity parameters size equals: 1.
	param := entity parameters first.
	self assert: param class equals: FamixF77Parameter.
	self assert: param name equals: 'var'.
	self assert: param parentBehaviouralEntity equals: entity.
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77PUMain [

	| entity |
	programFile progUnits: { IASTMainProgram new
			 entityName: 'main';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUMain.
	self assert: entity name equals: 'main'.
	self assert: entity programFile isNotNil.
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77ProgramFile [
	| entity |
	programFile accept: visitor.

	self assert: visitor model size equals: 6.

	entity := visitor model allWithType: FamixF77ProgramFile.
	self assert: entity size equals: 1.
	
	entity := entity first.
	self assert: entity class equals: FamixF77ProgramFile.
	self assert: entity filename equals: 'fortran77.f'.
	self assert: entity programUnits size equals: 0
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77SourceAnchor [
	| entity |
	entity := self defaultAnchor accept: visitor.
	
	self assert: entity class equals: FamixF77IndexedFileAnchor.
	self assert: entity fileName equals: 'fortran77.f'.
	self assert: entity startLine equals: 1.
	self assert: entity startColumn equals: 7.
	self assert: entity endLine equals: 2.
	self assert: entity endColumn equals: 10.
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testCreateFamixFortran77Subroutine [

	| entity |
	programFile progUnits: { IASTSubroutine new
			 entityName: 'sub';
			 yourself }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	entity := entity programUnits first.
	self assert: entity class equals: FamixF77PUSubroutine.
	self assert: entity name equals: 'sub'.
	self assert: entity programFile isNotNil.
	self assert: entity parameters size equals: 0
]

{ #category : #'tests-esope' }
IASTToFamixVisitorTest >> testCreateIncludeFamixFortran77Subroutine [

	"
      subroutine test
c@_#include ""point.seg""
      end
	"

	| pf sub include includeStmt |
	includeStmt := IASTInclude new
		               includeCommand: '#include';
		               entityName: 'point.seg';
		               yourself.
	programFile progUnits: { (IASTSubroutine new
			 entityName: 'test';
			 body: { includeStmt };
			 yourself) }.

	pf := programFile accept: visitor.

	self assert: pf programUnits size equals: 1.

	sub := pf programUnits first.
	self assert: sub class equals: FamixF77PUSubroutine.
	self assert: sub includes size equals: 1.

	include := sub includes first.
	self assert: include class equals: FamixF77Include.
	self assert: include filename equals: 'point.seg'.
	self assert: include includedBy equals: sub "
	self assert: include source equals: programFile."
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testImplicitWithRange [

	| entity sub |
	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { IASTImplicit new
				rules: { (self implicitRule: 'character' range: { #( $c $f ) }) }
			 };
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	sub := entity programUnits first.

	self assert: sub implicits size equals: 1.

	entity := sub implicits anyOne.
	self assert: entity class equals: IASTImplicitTypingRule.

	self assert: entity ranges size equals: 1.

	entity := entity ranges anyOne.
	self assert: entity size equals: 2.
	self assert: entity first equals: $c.
	self assert: entity second equals: $f
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testMultipleImplicit [

	| entity sub |
	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { IASTImplicit new
				rules: { (self implicitRule: 'character' range: #( #( $c ) #( $d $f ) )) }
			 } ;
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	sub := entity programUnits first.

	self assert: sub implicits size equals: 1.

	entity := sub implicits anyOne.
	self assert: entity class equals: IASTImplicitTypingRule.

	self assert: entity ranges size equals: 2.

	entity := entity ranges first.
	self assert: entity size equals: 1.
	self assert: entity anyOne equals: $c.

	entity := sub implicits anyOne ranges second.
	self assert: entity size equals: 2.
	self assert: entity first equals: $d.
	self assert: entity second equals: $f
]

{ #category : #'tests-fortran' }
IASTToFamixVisitorTest >> testSimpleImplicit [

	| entity sub |
	programFile progUnits: { (IASTSubroutine new
			 entityName: 'sub';
			 body: { IASTImplicit new
				rules: { (self implicitRule: 'character' range: { #( $c ) }) }
			};
			 yourself) }.

	entity := programFile accept: visitor.

	self assert: entity programUnits size equals: 1.

	sub := entity programUnits first.

	self assert: sub implicits size equals: 1.

	entity := sub implicits anyOne.
	self assert: entity class equals: IASTImplicitTypingRule.

	self assert: entity ranges size equals: 1.

	entity := entity ranges anyOne.
	self assert: entity size equals: 1.
	self assert: entity anyOne equals: $c.

	entity := sub implicits anyOne.
	self assert: entity forType class equals: IASTTypeRef.
	self assert: entity forType entityName equals: 'character'
]
