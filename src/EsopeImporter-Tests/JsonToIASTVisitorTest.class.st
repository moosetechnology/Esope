Class {
	#name : #JsonToIASTVisitorTest,
	#superclass : #TestCase,
	#category : #'EsopeImporter-Tests-Visitor'
}

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testAccessArrayWithIndices [
	"subroutine hello
	  integer arr(10)
      someVar = arr(i)
      end
"
	| programFile var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:21)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"dims":{"anno":[],"list":[{"anno":[],"lower":null,"span":"(2:19)-(2:20)","upper":{"anno":[],"span":"(2:19)-(2:20)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}}],"span":"(2:19)-(2:20)"},"initial":null,"length":null,"span":"(2:15)-(2:21)","type":"array","variable":{"anno":[],"span":"(2:15)-(2:17)","tag":"value","value":{"contents":"arr","tag":"variable"}}}],"span":"(2:15)-(2:21)"},"span":"(2:7)-(2:21)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:22)","statement":{"anno":[],"expression":{"anno":[],"expression":{"anno":[],"span":"(3:17)-(3:19)","tag":"value","value":{"contents":"arr","tag":"variable"}},"indices":{"anno":[],"list":[{"anno":[],"index":{"anno":[],"span":"(3:21)-(3:21)","tag":"value","value":{"contents":"i","tag":"variable"}},"name":null,"span":"(3:21)-(3:21)","tag":"single"}],"span":"(3:21)-(3:21)"},"span":"(3:17)-(3:22)","tag":"subscript"},"span":"(3:7)-(3:22)","tag":"assign_expression","target":{"anno":[],"span":"(3:7)-(3:13)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.

	"body of 1st program-unit has 2 statements"
	self assert: programFile progUnits first body size equals: 2.
	"2nd statement has 2 expressions"
	self assert: programFile progUnits first body second size equals: 2.

	"array access is seond expression of second statement"
	var := programFile progUnits first body second second.
	self assert: var class equals: IASTVarAccess.
	self assert: var entityName equals: 'arr'.
	self assert: var indices size equals: 1.

	var := var indices first.
	self assert: var class equals: IASTVarAccess.
	self deny: var isWrite.
	self assert: var entityName equals: 'i'.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testAccessArrayWithIndicesLiteral [
	"subroutine hello
	  integer arr(10)
      someVar = arr(5)
      end
"
	| programFile var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:21)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"dims":{"anno":[],"list":[{"anno":[],"lower":null,"span":"(2:19)-(2:20)","upper":{"anno":[],"span":"(2:19)-(2:20)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}}],"span":"(2:19)-(2:20)"},"initial":null,"length":null,"span":"(2:15)-(2:21)","type":"array","variable":{"anno":[],"span":"(2:15)-(2:17)","tag":"value","value":{"contents":"arr","tag":"variable"}}}],"span":"(2:15)-(2:21)"},"span":"(2:7)-(2:21)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:22)","statement":{"anno":[],"expression":{"anno":[],"expression":{"anno":[],"span":"(3:17)-(3:19)","tag":"value","value":{"contents":"arr","tag":"variable"}},"indices":{"anno":[],"list":[{"anno":[],"index":{"anno":[],"span":"(3:21)-(3:21)","tag":"value","value":{"contents":["5",null],"tag":"integer"}},"name":null,"span":"(3:21)-(3:21)","tag":"single"}],"span":"(3:21)-(3:21)"},"span":"(3:17)-(3:22)","tag":"subscript"},"span":"(3:7)-(3:22)","tag":"assign_expression","target":{"anno":[],"span":"(3:7)-(3:13)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.

	"body of 1st program-unit has 2 statements"
	self assert: programFile progUnits first body size equals: 2.
	"2nd statement has 2 expressions"
	self assert: programFile progUnits first body second size equals: 2.

	"array access is seond expression of second statement"
	var := programFile progUnits first body second second.
	self assert: var class equals: IASTVarAccess.
	self assert: var entityName equals: 'arr'.
	self assert: var indices size equals: 1.
	"note: keep 'nil' indice to indicate that this is an array"
	self assert: var indices first isNil.
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testAccessArrayWithSeveralIndices [
	"subroutine hello
	  integer arr(10, 10, 10)
      someVar = arr(x, 2, y)
      end
"
	| programFile var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:29)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"dims":{"anno":[],"list":[{"anno":[],"lower":null,"span":"(2:19)-(2:20)","upper":{"anno":[],"span":"(2:19)-(2:20)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}},{"anno":[],"lower":null,"span":"(2:23)-(2:24)","upper":{"anno":[],"span":"(2:23)-(2:24)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}},{"anno":[],"lower":null,"span":"(2:27)-(2:28)","upper":{"anno":[],"span":"(2:27)-(2:28)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}}],"span":"(2:19)-(2:28)"},"initial":null,"length":null,"span":"(2:15)-(2:29)","type":"array","variable":{"anno":[],"span":"(2:15)-(2:17)","tag":"value","value":{"contents":"arr","tag":"variable"}}}],"span":"(2:15)-(2:29)"},"span":"(2:7)-(2:29)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:28)","statement":{"anno":[],"expression":{"anno":[],"expression":{"anno":[],"span":"(3:17)-(3:19)","tag":"value","value":{"contents":"arr","tag":"variable"}},"indices":{"anno":[],"list":[{"anno":[],"index":{"anno":[],"span":"(3:21)-(3:21)","tag":"value","value":{"contents":"x","tag":"variable"}},"name":null,"span":"(3:21)-(3:21)","tag":"single"},{"anno":[],"index":{"anno":[],"span":"(3:24)-(3:24)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"name":null,"span":"(3:24)-(3:24)","tag":"single"},{"anno":[],"index":{"anno":[],"span":"(3:27)-(3:27)","tag":"value","value":{"contents":"y","tag":"variable"}},"name":null,"span":"(3:27)-(3:27)","tag":"single"}],"span":"(3:21)-(3:27)"},"span":"(3:17)-(3:28)","tag":"subscript"},"span":"(3:7)-(3:28)","tag":"assign_expression","target":{"anno":[],"span":"(3:7)-(3:13)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.

	"body of 1st program-unit has 2 statements"
	self assert: programFile progUnits first body size equals: 2.
	"2nd statement has 2 expressions"
	self assert: programFile progUnits first body second size equals: 2.

	"array access is 2nd expression of 2nd statement"
	var := programFile progUnits first body second second.
	self assert: var class equals: IASTVarAccess.
	self assert: var entityName equals: 'arr'.
	self assert: var indices size equals: 3.

	self assert: var indices first class equals: IASTVarAccess.
	self assert: var indices first entityName equals: 'x'.

	self assert: var indices second isNil.

	self assert: var indices third class equals: IASTVarAccess.
	self assert: var indices third entityName equals: 'y'.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testAssignementStatement [
	"subroutine hello
      someVar = otherVar
      end
"
	| programFile var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:24)","statement":{"anno":[],"expression":{"anno":[],"span":"(2:17)-(2:24)","tag":"value","value":{"contents":"othervar","tag":"variable"}},"span":"(2:7)-(2:24)","tag":"assign_expression","target":{"anno":[],"span":"(2:7)-(2:13)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 2.

	var := programFile progUnits first body first first.
	self assert: var class equals: IASTVarAccess.
	self assert: var isWrite.
	self assert: var entityName equals: 'somevar'.

	var := programFile progUnits first body first second.
	self assert: var class equals: IASTVarAccess.
	self deny: var isWrite.
	self assert: var entityName equals: 'othervar'.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testAssignementStatementWithComplexRHS [
	"subroutine hello
      someVar = otherVar + thirdVar
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:35)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(2:17)-(2:24)","tag":"value","value":{"contents":"othervar","tag":"variable"}},"op":{"tag":"addition"},"right":{"anno":[],"span":"(2:28)-(2:35)","tag":"value","value":{"contents":"thirdvar","tag":"variable"}},"span":"(2:17)-(2:35)","tag":"binary"},"span":"(2:7)-(2:35)","tag":"assign_expression","target":{"anno":[],"span":"(2:7)-(2:13)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 3.

	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTVarAccess.
	self assert: stmt entityName equals: 'somevar'.

	stmt := programFile progUnits first body first second.
	self assert: stmt class equals: IASTVarAccess.
	self assert: stmt entityName equals: 'othervar'.

	stmt := programFile progUnits first body first third.
	self assert: stmt class equals: IASTVarAccess.
	self assert: stmt entityName equals: 'thirdvar'.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testAssignementStatementWithEsoAt [
	"subroutine hello
      someVar = D__(var,1)
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:28)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:23)-(2:25)","tag":"value","value":{"contents":"var","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:23)-(2:25)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:27)-(2:27)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"tag":"expr"},"name":null,"span":"(2:27)-(2:27)"}],"span":"(2:23)-(2:27)"},"function":{"anno":[],"span":"(2:17)-(2:21)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:17)-(2:28)","tag":"function_call"},"span":"(2:7)-(2:28)","tag":"assign_expression","target":{"anno":[],"span":"(2:7)-(2:13)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	"first statement in body"
	stmt := programFile progUnits first body first.
	self assert: stmt size equals: 2.

	self assert: stmt first class equals: IASTVarAccess.
	self assert: stmt first entityName equals: 'somevar'.

	self assert: stmt second class equals: IASTVarEsoAt.
	self assert: stmt second entityName equals: 'd__'.

]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testBlockDataWithOneCommon [
	"blockdata hello
      common /mycom/ i
      end
"
	| programFile blockdata var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:22)","statement":{"anno":[],"common_groups":{"anno":[],"list":[{"anno":[],"name":{"anno":[],"span":"(2:14)-(2:20)","tag":"value","value":{"contents":"mycom","tag":"variable"}},"span":"(2:14)-(2:22)","vars":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:22)-(2:22)","type":"scalar","variable":{"anno":[],"span":"(2:22)-(2:22)","tag":"value","value":{"contents":"i","tag":"variable"}}}],"span":"(2:22)-(2:22)"}}],"span":"(2:14)-(2:22)"},"span":"(2:7)-(2:22)","tag":"common"},"tag":"statement"}],"name":"hello","span":"(1:7)-(3:9)","tag":"block_data"}]}'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.

	blockdata := programFile progUnits first.
	self assert: blockdata entityName equals: 'hello'.
	self assert: blockdata body size equals: 1.
	
	var := blockdata body first first.
	self assert: var class equals: IASTVariable.
	self assert: var entityName equals: 'mycom'

]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testBlockDataWithOneCommonOneData [
	"block data hello
      common /mycom/ i
      data i /12345/
      end
"
	| programFile blockdata |
	self flag: 'not dealing with COMMON for now'.
	self skip.

	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:22)","statement":{"anno":[],"common_groups":{"anno":[],"list":[{"anno":[],"name":{"anno":[],"span":"(2:14)-(2:20)","tag":"value","value":{"contents":"mycom","tag":"variable"}},"span":"(2:14)-(2:22)","vars":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:22)-(2:22)","type":"scalar","variable":{"anno":[],"span":"(2:22)-(2:22)","tag":"value","value":{"contents":"i","tag":"variable"}}}],"span":"(2:22)-(2:22)"}}],"span":"(2:14)-(2:22)"},"span":"(2:7)-(2:22)","tag":"common"},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:20)","statement":{"anno":[],"data_groups":{"anno":[],"list":[{"anno":[],"initializers":{"anno":[],"list":[{"anno":[],"span":"(3:15)-(3:19)","tag":"value","value":{"contents":["12345",null],"tag":"integer"}}],"span":"(3:15)-(3:19)"},"names":{"anno":[],"list":[{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":"i","tag":"variable"}}],"span":"(3:12)-(3:12)"},"span":"(3:12)-(3:20)"}],"span":"(3:12)-(3:20)"},"span":"(3:7)-(3:20)","tag":"data"},"tag":"statement"}],"name":"hello","span":"(1:7)-(4:9)","tag":"block_data"}]}'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTBlockData.

	blockdata := programFile progUnits first.
	self assert: blockdata entityName equals: 'hello'.
	self assert: blockdata body size equals: 3.
	self assert: blockdata comments isEmpty.
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testCallToWrite [
	"subroutine mysub (msg)
      write(*,*) msg
      end
"

	| programFile stmt arg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(1:25)-(1:27)","tag":"value","value":{"contents":"msg","tag":"variable"}}],"span":"(1:25)-(1:27)"},"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:20)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:18)-(2:20)","tag":"value","value":{"contents":"msg","tag":"variable"}}],"span":"(2:18)-(2:20)"},"format":{"anno":[],"list":[{"anno":[],"expr":{"anno":[],"span":"(2:13)-(2:13)","tag":"value","value":{"tag":"star"}},"name":null,"span":"(2:13)-(2:13)"},{"anno":[],"expr":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"tag":"star"}},"name":null,"span":"(2:15)-(2:15)"}],"span":"(2:12)-(2:16)"},"span":"(2:7)-(2:20)","tag":"write"},"tag":"statement"}],"name":"mysub","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt first class equals: IASTInvocation.
	self assert: stmt first entityName equals: 'write'.
	self assert: stmt first arguments size equals: 1.
	self assert: stmt first sourceAnchor isNotNil.

	arg := stmt first arguments first.
	self assert: arg class equals: IASTVarAccess.
	self assert: arg entityName equals: 'msg'.
	self deny: arg isWrite

]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testComment [
	"c     blah"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"comment":"     blah","span":"(1:1)-(1:10)","tag":"comment"}]}'.

	self assert: programFile progUnits size equals: 1.
	stmt := programFile progUnits first.
	self assert: stmt class equals: IASTComment.
	self assert: stmt text equals: '     blah'.

	self assert: stmt sourceAnchor notNil.
	self assert: stmt sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: stmt sourceAnchor fileName equals: './fortran77.f'.
	self assert: stmt sourceAnchor startLine equals: 1.
	self assert: stmt sourceAnchor startColumn equals: 1.
	self assert: stmt sourceAnchor endLine equals: 1.
	self assert: stmt sourceAnchor endColumn equals: 11.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testCommentInside [
	"integer function hello()
c     blah
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"     blah","span":"(2:1)-(2:10)","tag":"comment"}],"name":"hello","result":null,"span":"(1:7)-(3:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(1:7)-(1:13)"}}]}'.


	self assert: programFile progUnits first body size equals: 1.
	stmt := programFile progUnits first body first.

	self assert: stmt class equals: IASTComment.
	self assert: stmt text equals: '     blah'.

]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testCommentOutside [
	"c     blah
      integer function hello()
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"comment":"     blah","span":"(1:1)-(1:10)","tag":"comment"},{"anno":[],"arguments":null,"blocks":[],"name":"hello","result":null,"span":"(2:7)-(3:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}}]}'.


	self assert: programFile progUnits size equals: 2.
	stmt := programFile progUnits first.
	self assert: stmt class equals: IASTComment.
	self assert: stmt text equals: '     blah'.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testContinueStatement [
"      PROGRAM MYPROG
      continue
      END
"
	
	| programFile |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:14)","statement":{"anno":[],"span":"(2:7)-(2:14)","tag":"continue"},"tag":"statement"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.


	self assert: programFile progUnits first body isEmpty
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testESOAtWithArrayArgument [
"Special case of a D__ function call with an array as argument

      subroutine hello
        integer arr(10)
        x = D__(y,arr(z))
      end
"

	| programFile d__ arg |
	self skip.

	programFile := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:23)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"dims":{"anno":[],"list":[{"anno":[],"lower":null,"span":"(2:21)-(2:22)","upper":{"anno":[],"span":"(2:21)-(2:22)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}}],"span":"(2:21)-(2:22)"},"initial":null,"length":null,"span":"(2:17)-(2:23)","type":"array","variable":{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"arr","tag":"variable"}}}],"span":"(2:17)-(2:23)"},"span":"(2:9)-(2:23)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:9)-(2:15)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:9)-(3:25)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(3:17)-(3:17)","tag":"value","value":{"contents":"y","tag":"variable"}},"tag":"expr"},"name":null,"span":"(3:17)-(3:17)"},{"anno":[],"expr":{"contents":{"anno":[],"expression":{"anno":[],"span":"(3:19)-(3:21)","tag":"value","value":{"contents":"arr","tag":"variable"}},"indices":{"anno":[],"list":[{"anno":[],"index":{"anno":[],"span":"(3:23)-(3:23)","tag":"value","value":{"contents":"z","tag":"variable"}},"name":null,"span":"(3:23)-(3:23)","tag":"single"}],"span":"(3:23)-(3:23)"},"span":"(3:19)-(3:24)","tag":"subscript"},"tag":"expr"},"name":null,"span":"(3:19)-(3:24)"}],"span":"(3:17)-(3:24)"},"function":{"anno":[],"span":"(3:13)-(3:15)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(3:13)-(3:25)","tag":"function_call"},"span":"(3:9)-(3:25)","tag":"assign_expression","target":{"anno":[],"span":"(3:9)-(3:9)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.

	"body of 1st program-unit, then second statement"
	self assert: programFile progUnits first body second size equals: 2.
	"2nd expression of the 2nd statement"
	d__ := programFile progUnits first body second second.

	self assert: d__ class equals: IASTVarEsoAt.
	self assert: d__ entities size equals: 2.

	arg := d__ entities first.
	self assert: arg class equals: IASTVarAccess.
	self assert: arg entityName equals: 'y'.


	arg := d__ entities second.
	self assert: arg class equals: IASTVarAccess.
	self assert: arg entityName equals: 'arr'.
	self assert: arg indices size equals: 1.
	self assert: arg indices first entityName equals: 'z'.

]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testEmptyBlockData [
	"BLOCK data hello
      end
"
	| programFile block |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[],"name":"hello","span":"(1:7)-(2:9)","tag":"block_data"}]}'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTBlockData.
	block := programFile progUnits first.
	self assert: block entityName equals: 'hello'.
	self assert: block body isEmpty.
	self assert: block comments isEmpty.
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testEmptyExitStatement [
"      PROGRAM MYPROG
      exit
      END
"
	
	| programFile |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:11)","statement":{"anno":[],"span":"(2:8)-(2:11)","tag":"exit","var":null},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body isEmpty
]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testEmptyFunction [
	"integer function hello()
      end
"
	| programFile fct |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[],"name":"hello","result":null,"span":"(1:7)-(2:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(1:7)-(1:13)"}}]}'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTFunction.
	fct := programFile progUnits first.
	self assert: fct entityName equals: 'hello'.
	self assert: fct parameters isEmpty.
	self assert: fct returnType class equals: IASTTypeRef.
	self assert: fct returnType entityName equals: 'integer'.
	self assert: fct body isEmpty.

	self assert: fct sourceAnchor notNil.
	self assert: fct sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: fct sourceAnchor fileName equals: './fortran77.f'.
	self assert: fct sourceAnchor startLine equals: 1.
	self assert: fct sourceAnchor startColumn equals: 7.
	self assert: fct sourceAnchor endLine equals: 2.
	self assert: fct sourceAnchor endColumn equals: 10.

]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testEmptyFunctionWithArguments [
	"integer function hello(i,j)
      end
"
	| programFile fct param |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(1:30)-(1:30)","tag":"value","value":{"contents":"i","tag":"variable"}},{"anno":[],"span":"(1:32)-(1:32)","tag":"value","value":{"contents":"j","tag":"variable"}}],"span":"(1:30)-(1:32)"},"blocks":[],"name":"hello","result":null,"span":"(1:7)-(2:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(1:7)-(1:13)"}}]}'.


	fct := programFile progUnits first.
	self assert: fct entityName equals: 'hello'.
	self assert: fct parameters size equals: 2.

	param := fct parameters first.
	self assert: param class equals: IASTParameter.
	self assert: param entityName equals: 'i'.

	param := fct parameters second.
	self assert: param class equals: IASTParameter.
	self assert: param entityName equals: 'j'.

]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testEmptyProgram [
	"program hello
      end
"
	| programFile prog |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[],"name":"hello","span":"(1:7)-(2:9)","subprograms":null,"tag":"main"}]}'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTMainProgram.
	prog := programFile progUnits first.
	self assert: prog entityName equals: 'hello'.
	self assert: prog body isEmpty.
	self assert: prog comments isEmpty.

	self assert: prog sourceAnchor notNil.
	self assert: prog sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: prog sourceAnchor fileName equals: './fortran77.f'.
	self assert: prog sourceAnchor startLine equals: 1.
	self assert: prog sourceAnchor startColumn equals: 7.
	self assert: prog sourceAnchor endLine equals: 2.
	self assert: prog sourceAnchor endColumn equals: 10.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testEmptyReturnStatement [
"      subroutine hello
      return
      end
"
	| programFile fct |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:12)","statement":{"anno":[],"span":"(2:7)-(2:12)","tag":"return","target":null},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: programFile progUnits size equals: 1.
	
	fct := programFile progUnits first.
	self assert: fct body isEmpty
]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testEmptySubroutine [
	"subroutine hello
      end
"
	| programFile sub |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[],"name":"hello","options":[null,null],"span":"(1:7)-(2:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTSubroutine.
	sub := programFile progUnits first.
	self assert: sub entityName equals: 'hello'.
	self assert: sub parameters isEmpty.
	self assert: sub body isEmpty.

	self assert: sub sourceAnchor notNil.
	self assert: sub sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: sub sourceAnchor fileName equals: './fortran77.f'.
	self assert: sub sourceAnchor startLine equals: 1.
	self assert: sub sourceAnchor startColumn equals: 7.
	self assert: sub sourceAnchor endLine equals: 2.
	self assert: sub sourceAnchor endColumn equals: 10.
]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testEmptySubroutineOneParam [
	"subroutine hello( name )
      end
"
	| programFile sub |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(1:25)-(1:28)","tag":"value","value":{"contents":"name","tag":"variable"}}],"span":"(1:25)-(1:28)"},"blocks":[],"name":"hello","options":[null,null],"span":"(1:7)-(2:9)","subprograms":null,"tag":"subroutine"}]}'.


	sub := programFile progUnits first.
	self assert: sub entityName equals: 'hello'.
	self assert: sub parameters size equals: 1.
	self assert: sub parameters first class equals: IASTParameter.
	self assert: sub parameters first entityName equals: 'name'.
	self assert: sub body isEmpty.
]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testEmptySubroutineTwoParams [
	"subroutine hello( param1, param2 )
      end
"
	| programFile sub |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(1:25)-(1:30)","tag":"value","value":{"contents":"param1","tag":"variable"}},{"anno":[],"span":"(1:33)-(1:38)","tag":"value","value":{"contents":"param2","tag":"variable"}}],"span":"(1:25)-(1:38)"},"blocks":[],"name":"hello","options":[null,null],"span":"(1:7)-(2:9)","subprograms":null,"tag":"subroutine"}]}'.


	sub := programFile progUnits first.
	self assert: sub entityName equals: 'hello'.
	self assert: sub parameters size equals: 2.
	self assert: sub parameters first class equals: IASTParameter.
	self assert: sub parameters first entityName equals: 'param1'.
	self assert: sub parameters second class equals: IASTParameter.
	self assert: sub parameters second entityName equals: 'param2'.
	self assert: sub body isEmpty.
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoArTwoArgs [
	"subroutine hello()
        d__(baz,bar) = 5
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:26)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:15)-(2:17)","tag":"value","value":{"contents":"baz","tag":"variable"}},{"anno":[],"span":"(2:19)-(2:21)","tag":"value","value":{"contents":"bar","tag":"variable"}}],"span":"(2:15)-(2:21)"},"body":{"anno":[],"span":"(2:26)-(2:26)","tag":"value","value":{"contents":["5",null],"tag":"integer"}},"name":{"anno":[],"span":"(2:9)-(2:13)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:9)-(2:26)","tag":"function"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 1.
	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTVarEsoAt.
	self assert: stmt isWrite.
	self assert: stmt entities size equals: 2.

]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoArWithDotArg [

"      subroutine hello( )
	     d__(p,a(d__(p,i))) = 5
      end
"

	| programFile d__ arg |
	programFile := self visitJsonCode:
		               '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:30)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:13)-(2:13)","tag":"value","value":{"contents":"p","tag":"variable"}},{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:21)-(2:21)","tag":"value","value":{"contents":"p","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:21)-(2:21)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:23)-(2:23)","tag":"value","value":{"contents":"i","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:23)-(2:23)"}],"span":"(2:21)-(2:23)"},"function":{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:17)-(2:24)","tag":"function_call"},"tag":"expr"},"name":null,"span":"(2:17)-(2:24)"}],"span":"(2:17)-(2:24)"},"function":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"a","tag":"variable"}},"span":"(2:15)-(2:25)","tag":"function_call"}],"span":"(2:13)-(2:25)"},"body":{"anno":[],"span":"(2:30)-(2:30)","tag":"value","value":{"contents":["5",null],"tag":"integer"}},"name":{"anno":[],"span":"(2:9)-(2:11)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:9)-(2:30)","tag":"function"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 1.

	"first statement in body, first entity in statement"
	d__ := programFile progUnits first body first first.
	self assert: d__ class equals: IASTVarEsoAt.
	self assert: d__ entities size equals: 2.
	self assert: d__ isWrite.

	arg := d__ entities first.
	self assert: arg class equals: IASTVarAccess.
	self assert: arg entityName equals: 'p'.
	self deny: arg isWrite.


	arg := d__ entities second.
	self assert: arg class equals: IASTInvocation.
	self assert: arg entityName equals: 'a'.
	self assert: arg arguments size equals: 1.
	
	d__ := arg arguments first.
	self assert: d__ class equals: IASTVarEsoAt.

	self assert: d__ entities size equals: 2.
	self assert: d__ entities first class equals: IASTVarAccess.
	self assert: d__ entities first entityName equals: 'p'.
	self assert: d__ entities second class equals: IASTVarAccess.
	self assert: d__ entities second entityName equals: 'i'.

]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoArWithEsoAtArg [
	"      subroutine hello( )
	     d__(baz,bar(2)) = 5
      end
"
	| programFile d__ arg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:10)-(2:28)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:14)-(2:16)","tag":"value","value":{"contents":"baz","tag":"variable"}},{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:22)-(2:22)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"tag":"expr"},"name":null,"span":"(2:22)-(2:22)"}],"span":"(2:22)-(2:22)"},"function":{"anno":[],"span":"(2:18)-(2:20)","tag":"value","value":{"contents":"bar","tag":"variable"}},"span":"(2:18)-(2:23)","tag":"function_call"}],"span":"(2:14)-(2:23)"},"body":{"anno":[],"span":"(2:28)-(2:28)","tag":"value","value":{"contents":["5",null],"tag":"integer"}},"name":{"anno":[],"span":"(2:10)-(2:12)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:10)-(2:28)","tag":"function"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 1.
	d__ := programFile progUnits first body first first.

	self assert: d__ class equals: IASTVarEsoAt.
	self assert: d__ isWrite.
	self assert: d__ entities size equals: 2.

	arg := d__ entities first.
	self assert: arg class equals: IASTVarAccess.
	self deny: arg isWrite.
	self assert: arg entityName equals: 'baz'.


	arg := d__ entities second.
	self assert: arg class equals: IASTInvocation.
	self assert: arg arguments size equals: 0.
	self assert: arg entityName equals: 'bar'.

]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoArWithVarArg [

	"      subroutine hello( )
	     d__(baz,bar(i)) = 5
      end
"

	| programFile d__ arg |
	programFile := self visitJsonCode:
		               '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:27)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:13)-(2:15)","tag":"value","value":{"contents":"baz","tag":"variable"}},{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:21)-(2:21)","tag":"value","value":{"contents":"i","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:21)-(2:21)"}],"span":"(2:21)-(2:21)"},"function":{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"bar","tag":"variable"}},"span":"(2:17)-(2:22)","tag":"function_call"}],"span":"(2:13)-(2:22)"},"body":{"anno":[],"span":"(2:27)-(2:27)","tag":"value","value":{"contents":["5",null],"tag":"integer"}},"name":{"anno":[],"span":"(2:9)-(2:11)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:9)-(2:27)","tag":"function"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 1.
	d__ := programFile progUnits first body first first.

	self assert: d__ class equals: IASTVarEsoAt.
	self assert: d__ isWrite.
	self assert: d__ entities size equals: 2.

	arg := d__ entities first.
	self assert: arg class equals: IASTVarAccess.
	self deny: arg isWrite.
	self assert: arg entityName equals: 'baz'.


	arg := d__ entities second.
	self assert: arg class equals: IASTInvocation.
	self assert: arg entityName equals: 'bar'.
	self assert: arg arguments size equals: 1.
	self assert: arg arguments first entityName equals: 'i'
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoAtOneArg [
	"      subroutine hello( )
        d__(baz,2) = 5.3
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:24)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:13)-(2:15)","tag":"value","value":{"contents":"baz","tag":"variable"}},{"anno":[],"span":"(2:17)-(2:17)","tag":"value","value":{"contents":["2",null],"tag":"integer"}}],"span":"(2:13)-(2:17)"},"body":{"anno":[],"span":"(2:22)-(2:24)","tag":"value","value":{"contents":[{"exponent":{"letter":"e","num":"0"},"significand":"5.3"},null],"tag":"real"}},"name":{"anno":[],"span":"(2:9)-(2:11)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:9)-(2:24)","tag":"function"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 1.
	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTVarEsoAt.
	self assert: stmt isWrite.
	self assert: stmt entities size equals: 1.
	self assert: stmt entities first class equals: IASTVarAccess.
	self assert: stmt entities first entityName equals: 'baz'.
	self deny: stmt entities first isWrite
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoAtTwoArgs [
	"      subroutine hello( )
        d__(baz,bar) = 5
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:24)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:13)-(2:15)","tag":"value","value":{"contents":"baz","tag":"variable"}},{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"bar","tag":"variable"}}],"span":"(2:13)-(2:19)"},"body":{"anno":[],"span":"(2:24)-(2:24)","tag":"value","value":{"contents":["5",null],"tag":"integer"}},"name":{"anno":[],"span":"(2:9)-(2:11)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:9)-(2:24)","tag":"function"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 1.
	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTVarEsoAt.
	self assert: stmt isWrite.
	self assert: stmt entities size equals: 2.
	stmt entities do: [ :ent |
		self assert: ent class equals: IASTVarAccess.
		self assert: (#(baz bar) includes: ent entityName asSymbol).
		self deny: ent isWrite
	]
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoAtTwoArgsReceivesVar [
	"      subroutine hello( )
        d__(baz,bar) = otherVar
      end
"
	| programFile var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:31)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:13)-(2:15)","tag":"value","value":{"contents":"baz","tag":"variable"}},{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"bar","tag":"variable"}}],"span":"(2:13)-(2:19)"},"body":{"anno":[],"span":"(2:24)-(2:31)","tag":"value","value":{"contents":"othervar","tag":"variable"}},"name":{"anno":[],"span":"(2:9)-(2:11)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:9)-(2:31)","tag":"function"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 2.

	var := programFile progUnits first body first first.
	self assert: var class equals: IASTVarEsoAt.

	var := programFile progUnits first body first second.
	self assert: var class equals: IASTVarAccess.
	self assert: var entityName equals: 'othervar'.
	self deny: var isWrite.
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoSl [
	"      subroutine hello( )
        n = s__(a,i)
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:20)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:17)-(2:17)","tag":"value","value":{"contents":"a","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:17)-(2:17)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:19)-(2:19)","tag":"value","value":{"contents":"i","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:19)-(2:19)"}],"span":"(2:17)-(2:19)"},"function":{"anno":[],"span":"(2:13)-(2:15)","tag":"value","value":{"contents":"s__","tag":"variable"}},"span":"(2:13)-(2:20)","tag":"function_call"},"span":"(2:9)-(2:20)","tag":"assign_expression","target":{"anno":[],"span":"(2:9)-(2:9)","tag":"value","value":{"contents":"n","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 2.
	stmt := programFile progUnits first body first second.
	self assert: stmt class equals: IASTVarEsoSl.
	self assert: stmt entities size equals: 2.
	
	self assert: stmt entities first class equals: IASTVarAccess.
	self assert: stmt entities first entityName equals: 'a'.
	
	self assert: stmt entities second class equals: IASTVarAccess.
	self assert: stmt entities second entityName equals: 'i'
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoSlWithDot [
	"      subroutine hello( )
        n = s__(d__(p,a),i)
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:27)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:21)-(2:21)","tag":"value","value":{"contents":"p","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:21)-(2:21)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:23)-(2:23)","tag":"value","value":{"contents":"a","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:23)-(2:23)"}],"span":"(2:21)-(2:23)"},"function":{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:17)-(2:24)","tag":"function_call"},"tag":"expr"},"name":null,"span":"(2:17)-(2:24)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:26)-(2:26)","tag":"value","value":{"contents":"i","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:26)-(2:26)"}],"span":"(2:17)-(2:26)"},"function":{"anno":[],"span":"(2:13)-(2:15)","tag":"value","value":{"contents":"s__","tag":"variable"}},"span":"(2:13)-(2:27)","tag":"function_call"},"span":"(2:9)-(2:27)","tag":"assign_expression","target":{"anno":[],"span":"(2:9)-(2:9)","tag":"value","value":{"contents":"n","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 2.
	stmt := programFile progUnits first body first second.
	self assert: stmt class equals: IASTVarEsoSl.
	self assert: stmt entities size equals: 2.
	
	self assert: stmt entities first class equals: IASTVarEsoAt.
	self assert: stmt entities first entities size equals: 2.
	self assert: stmt entities first entities first class equals: IASTVarAccess.
	self assert: stmt entities first entities first entityName equals: 'p'.
	self assert: stmt entities first entities second class equals: IASTVarAccess.
	self assert: stmt entities first entities second entityName equals: 'a'.
	
	self assert: stmt entities second class equals: IASTVarAccess.
	self assert: stmt entities second entityName equals: 'i'
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testEsoSlWithTwoDot [
	"      subroutine hello( )
        n = s__(d__(p,a),d__(p,i))
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:9)-(2:34)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:21)-(2:21)","tag":"value","value":{"contents":"p","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:21)-(2:21)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:23)-(2:23)","tag":"value","value":{"contents":"a","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:23)-(2:23)"}],"span":"(2:21)-(2:23)"},"function":{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:17)-(2:24)","tag":"function_call"},"tag":"expr"},"name":null,"span":"(2:17)-(2:24)"},{"anno":[],"expr":{"contents":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:30)-(2:30)","tag":"value","value":{"contents":"p","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:30)-(2:30)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:32)-(2:32)","tag":"value","value":{"contents":"i","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:32)-(2:32)"}],"span":"(2:30)-(2:32)"},"function":{"anno":[],"span":"(2:26)-(2:28)","tag":"value","value":{"contents":"d__","tag":"variable"}},"span":"(2:26)-(2:33)","tag":"function_call"},"tag":"expr"},"name":null,"span":"(2:26)-(2:33)"}],"span":"(2:17)-(2:33)"},"function":{"anno":[],"span":"(2:13)-(2:15)","tag":"value","value":{"contents":"s__","tag":"variable"}},"span":"(2:13)-(2:34)","tag":"function_call"},"span":"(2:9)-(2:34)","tag":"assign_expression","target":{"anno":[],"span":"(2:9)-(2:9)","tag":"value","value":{"contents":"n","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 2.
	stmt := programFile progUnits first body first second.
	self assert: stmt class equals: IASTVarEsoSl.
	self assert: stmt entities size equals: 2.
	self assert: stmt entities first class equals: IASTVarEsoAt.
	self assert: stmt entities first entities size equals: 2.
	self assert: stmt entities first entities first class equals: IASTVarAccess.
	self assert: stmt entities first entities first entityName equals: 'p'.
	self assert: stmt entities first entities second class equals: IASTVarAccess.
	self assert: stmt entities first entities second entityName equals: 'a'.
	
	self assert: stmt entities second class equals: IASTVarEsoAt.
	self assert: stmt entities second entities size equals: 2.
	self assert: stmt entities second entities first class equals: IASTVarAccess.
	self assert: stmt entities second entities first entityName equals: 'p'.
	self assert: stmt entities second entities second class equals: IASTVarAccess.
	self assert: stmt entities second entities second entityName equals: 'i'.
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testFunctionWithFunctionInvocation [
"      integer function efunc()
      i = ifunc (i, j)
      end
"

	| programFile fct |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:22)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:18)-(2:18)","tag":"value","value":{"contents":"i","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:18)-(2:18)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:21)-(2:21)","tag":"value","value":{"contents":"j","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:21)-(2:21)"}],"span":"(2:18)-(2:21)"},"function":{"anno":[],"span":"(2:11)-(2:15)","tag":"value","value":{"contents":"ifunc","tag":"variable"}},"span":"(2:11)-(2:22)","tag":"function_call"},"span":"(2:7)-(2:22)","tag":"assign_expression","target":{"anno":[],"span":"(2:7)-(2:7)","tag":"value","value":{"contents":"i","tag":"variable"}}},"tag":"statement"}],"name":"efunc","result":null,"span":"(1:7)-(3:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(1:7)-(1:13)"}}]}'.


	self assert: programFile progUnits size equals: 1.
	
	fct := programFile progUnits first.

	self assert: fct class equals: IASTFunction.
	self assert: fct entityName equals: 'efunc'.
	self assert: fct body first size equals: 2.
	self assert: fct sourceAnchor startLine equals: 1.
	self assert: fct sourceAnchor startColumn equals: 7.
	self assert: fct sourceAnchor endLine equals: 3.
	self assert: fct sourceAnchor endColumn equals: 10.
	
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testGotoStatement [
"      PROGRAM MYPROG
      goto 100
      END
"
	
	| programFile |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:14)","statement":{"anno":[],"span":"(2:7)-(2:14)","tag":"goto","target":{"anno":[],"span":"(2:12)-(2:14)","tag":"value","value":{"contents":["100",null],"tag":"integer"}}},"tag":"statement"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.


	self assert: programFile progUnits first body isEmpty
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testImplicitNoneStatement [
	"PROGRAM MYPROG
       implicit none
      END
"
	
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:20)","statement":{"anno":[],"items":null,"span":"(2:8)-(2:20)","tag":"implicit"},"tag":"statement"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTImplicit.
	self assert: stmt ranges isNil.
	self assert: stmt forType isNil
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testImplicitStatementSeveralRanges [
	"PROGRAM MYPROG
       implicit character (c-e, h, l-m)
      END
"
	
	| programFile stmt range |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:39)","statement":{"anno":[],"items":{"anno":[],"list":[{"anno":[],"elements":{"anno":[],"list":[{"anno":[],"from":"c","span":"(2:28)-(2:30)","to":"e"},{"anno":[],"from":"h","span":"(2:33)-(2:33)","to":null},{"anno":[],"from":"l","span":"(2:36)-(2:38)","to":"m"}],"span":"(2:28)-(2:38)"},"span":"(2:17)-(2:39)","type":{"anno":[],"base_type":"character","selector":null,"span":"(2:17)-(2:25)"}}],"span":"(2:17)-(2:39)"},"span":"(2:8)-(2:39)","tag":"implicit"},"tag":"statement"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTImplicit.
	self assert: stmt ranges isCollection.
	self assert: stmt ranges size equals: 3.

	range := stmt ranges first.
	self assert: range isCollection.
	self assertCollection: range equals: { $c . $e }.

	range := stmt ranges second.
	self assert: range isCollection.
	self assertCollection: range equals: { $h . $h }.

	range := stmt ranges third.
	self assert: range isCollection.
	self assertCollection: range equals: { $l . $m }.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testImplicitStatementSimpleChar [
	"PROGRAM MYPROG
       implicit character (c)
      END
"
	
	| programFile stmt range |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:29)","statement":{"anno":[],"items":{"anno":[],"list":[{"anno":[],"elements":{"anno":[],"list":[{"anno":[],"from":"c","span":"(2:28)-(2:28)","to":null}],"span":"(2:28)-(2:28)"},"span":"(2:17)-(2:29)","type":{"anno":[],"base_type":"character","selector":null,"span":"(2:17)-(2:25)"}}],"span":"(2:17)-(2:29)"},"span":"(2:8)-(2:29)","tag":"implicit"},"tag":"statement"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTImplicit.
	self assert: stmt ranges isCollection.
	self assert: stmt ranges size equals: 1.

	range := stmt ranges first.
	self assert: range isCollection.
	self assertCollection: range equals: { $c . $c }.

	self assert: stmt forType class equals: IASTTypeRef.
	self assert: stmt forType entityName equals: 'character'.
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testImplicitStatementSimpleRange [
	"PROGRAM MYPROG
       implicit character (c-e)
      END
"
	
	| programFile stmt range |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:31)","statement":{"anno":[],"items":{"anno":[],"list":[{"anno":[],"elements":{"anno":[],"list":[{"anno":[],"from":"c","span":"(2:28)-(2:30)","to":"e"}],"span":"(2:28)-(2:30)"},"span":"(2:17)-(2:31)","type":{"anno":[],"base_type":"character","selector":null,"span":"(2:17)-(2:25)"}}],"span":"(2:17)-(2:31)"},"span":"(2:8)-(2:31)","tag":"implicit"},"tag":"statement"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTImplicit.
	self assert: stmt ranges isCollection.
	self assert: stmt ranges size equals: 1.

	range := stmt ranges first.
	self assert: range isCollection.
	self assertCollection: range equals: { $c . $e }.

]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testIncludeFile [

	"      subroutine hello( )
c@_#include ""file.inc""
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_#include \"file.inc\"","span":"(2:1)-(2:22)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTInclude.
	self assert: stmt includeCommand equals: 'include'.
	self assert: stmt entityName equals: 'file.inc'
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testIntegerVariableDeclaration [
	"subroutine hello
      integer i
      end
"
	| programFile var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:15)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:15)-(2:15)","type":"scalar","variable":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"i","tag":"variable"}}}],"span":"(2:15)-(2:15)"},"span":"(2:7)-(2:15)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 1.
	var := programFile progUnits first body first first.

	self assert: var class equals: IASTVariable.
	self assert: var entityName equals: 'i'.
	self assert: var typeSpec class equals: IASTTypeRef.
	self assert: var typeSpec entityName equals: 'integer'.
	self assert: var sourceAnchor isNotNil.
	self assert: var sourceAnchor class equals: IASTIndexedFileAnchor
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testMultipleStatements [
	"subroutine hello
      integer someVar
      someVar = 3 * someVar
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:21)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:15)-(2:21)","type":"scalar","variable":{"anno":[],"span":"(2:15)-(2:21)","tag":"value","value":{"contents":"somevar","tag":"variable"}}}],"span":"(2:15)-(2:21)"},"span":"(2:7)-(2:21)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:27)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:17)-(3:17)","tag":"value","value":{"contents":["3",null],"tag":"integer"}},"op":{"tag":"multiplication"},"right":{"anno":[],"span":"(3:21)-(3:27)","tag":"value","value":{"contents":"somevar","tag":"variable"}},"span":"(3:17)-(3:27)","tag":"binary"},"span":"(3:7)-(3:27)","tag":"assign_expression","target":{"anno":[],"span":"(3:7)-(3:13)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 2.

	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTVariable.
	self assert: stmt typeSpec class equals: IASTTypeRef.
	self assert: stmt entityName equals: 'somevar'.

	stmt := programFile progUnits first body second first.
	self assert: stmt class equals: IASTVarAccess.
	self assert: stmt isWrite.
	self assert: stmt entityName equals: 'somevar'.

	stmt := programFile progUnits first body second second.
	self assert: stmt class equals: IASTVarAccess.
	self deny: stmt isWrite.
	self assert: stmt entityName equals: 'somevar'.

]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testPointeurDeclaration [
"      subroutine hello
c@_   pointeur p1.pstr
      end
"
	| programFile seg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   pointeur p1.pstr","span":"(2:1)-(2:22)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopePointer.
	self assert: seg entityName equals: 'p1.pstr'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 1.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 23
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testProgramWithEmptyDoStatement [
	"program hello
      do i=1, n
      enddo 
      end
"
	| prog programFile |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"body":[],"do_spec":{"anno":[],"increment":null,"initial":{"anno":[],"expression":{"anno":[],"span":"(2:12)-(2:12)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"span":"(2:10)-(2:12)","tag":"assign_expression","target":{"anno":[],"span":"(2:10)-(2:10)","tag":"value","value":{"contents":"i","tag":"variable"}}},"limit":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"n","tag":"variable"}},"span":"(2:10)-(2:15)"},"end_label":null,"label":null,"name":null,"span":"(2:7)-(3:11)","tag":"do","target":null}],"name":"hello","span":"(1:7)-(4:9)","subprograms":null,"tag":"main"}]}'.


	prog := programFile progUnits first.
	self assert: prog accesses size equals: 2.
	self assertCollection: (prog accesses collect: [ :each | each entityName ]) hasSameElements: #(i n)
	

	

]

{ #category : #'tests-progUnit' }
JsonToIASTVisitorTest >> testProgramWithMultipleProgUnits [
	"program myprog
      end

      integer function ifunc( k, l )
      end

      subroutine mysub (msg)
      end
"
	| programFile node |
	programFile :=  self visitJsonCode:  '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[],"name":"myprog","span":"(1:7)-(2:9)","subprograms":null,"tag":"main"},{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(4:31)-(4:31)","tag":"value","value":{"contents":"k","tag":"variable"}},{"anno":[],"span":"(4:34)-(4:34)","tag":"value","value":{"contents":"l","tag":"variable"}}],"span":"(4:31)-(4:34)"},"blocks":[],"name":"ifunc","result":null,"span":"(4:7)-(5:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(4:7)-(4:13)"}},{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(7:25)-(7:27)","tag":"value","value":{"contents":"msg","tag":"variable"}}],"span":"(7:25)-(7:27)"},"blocks":[],"name":"mysub","options":[null,null],"span":"(7:7)-(8:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: programFile progUnits size equals: 3.
	
	node := programFile progUnits first.
	self assert: node class equals: IASTMainProgram.
	self assert: node entityName equals: 'myprog'.
	self assert: node body size equals: 0.
	self assert: node accesses size equals: 0.
	self assert: node invocations size equals: 0.
	
	node := programFile progUnits second.
	self assert: node class equals: IASTFunction.
	self assert: node parameters size equals: 2.
	self assert: node parameters first entityName equals: 'k'.
	self assert: node parameters second entityName equals: 'l'.

	node := programFile progUnits third.
	self assert: node class equals: IASTSubroutine.
	self assert: node parameters size equals: 1.
	self assert: node parameters first entityName equals: 'msg'.
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testProgramWithOneStatement [
	"program hello
      a = -b
      end
"
	| programFile prog |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:12)","statement":{"anno":[],"expression":{"anno":[],"expression":{"anno":[],"span":"(2:12)-(2:12)","tag":"value","value":{"contents":"b","tag":"variable"}},"op":{"tag":"minus"},"span":"(2:11)-(2:12)","tag":"unary"},"span":"(2:7)-(2:12)","tag":"assign_expression","target":{"anno":[],"span":"(2:7)-(2:7)","tag":"value","value":{"contents":"a","tag":"variable"}}},"tag":"statement"}],"name":"hello","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTMainProgram.

	prog := programFile progUnits first.
	self assert: prog entityName equals: 'hello'.
	self assert: prog body size equals: 1.
	self assert: prog comments isEmpty.
	self assert: prog body first size equals: 2.
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testProgramWithSimpleIfElseStatementWitBody [
	"program hello
      if (i < j) then
        i = i + 1
      else
        j = j - 1
      endif
      end
"
	| prog programFile |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(5:9)-(5:17)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(5:13)-(5:13)","tag":"value","value":{"contents":"j","tag":"variable"}},"op":{"tag":"subtraction"},"right":{"anno":[],"span":"(5:17)-(5:17)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"span":"(5:13)-(5:17)","tag":"binary"},"span":"(5:9)-(5:17)","tag":"assign_expression","target":{"anno":[],"span":"(5:9)-(5:9)","tag":"value","value":{"contents":"j","tag":"variable"}}},"tag":"statement"}],"conditions":[[{"anno":[],"left":{"anno":[],"span":"(2:11)-(2:11)","tag":"value","value":{"contents":"i","tag":"variable"}},"op":{"tag":"lt"},"right":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"j","tag":"variable"}},"span":"(2:11)-(2:15)","tag":"binary"},[{"anno":[],"label":null,"span":"(3:9)-(3:17)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:13)-(3:13)","tag":"value","value":{"contents":"i","tag":"variable"}},"op":{"tag":"addition"},"right":{"anno":[],"span":"(3:17)-(3:17)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"span":"(3:13)-(3:17)","tag":"binary"},"span":"(3:9)-(3:17)","tag":"assign_expression","target":{"anno":[],"span":"(3:9)-(3:9)","tag":"value","value":{"contents":"i","tag":"variable"}}},"tag":"statement"}]]],"end_label":null,"label":null,"name":null,"span":"(2:7)-(6:11)","tag":"if"}],"name":"hello","span":"(1:7)-(7:9)","subprograms":null,"tag":"main"}]}'.


	prog := programFile progUnits first.
	self assert: prog accesses size equals: 6.
	self assertCollection: (prog accesses collect: [ :each | each entityName ]) hasSameElements: #(i j).
	self assert: (prog accesses select: [:each | each entityName = 'i']) size equals: 3.
	self assert: prog accesses third isWrite.
	self assert: prog accesses fifth isWrite.
	

	

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testProgramWithSimpleIfStatementWitBody [
	"program hello
      if (i < j) then
        i = j
      endif
      end
"
	| prog programFile |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"blocks":null,"conditions":[[{"anno":[],"left":{"anno":[],"span":"(2:11)-(2:11)","tag":"value","value":{"contents":"i","tag":"variable"}},"op":{"tag":"lt"},"right":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"j","tag":"variable"}},"span":"(2:11)-(2:15)","tag":"binary"},[{"anno":[],"label":null,"span":"(3:9)-(3:13)","statement":{"anno":[],"expression":{"anno":[],"span":"(3:13)-(3:13)","tag":"value","value":{"contents":"j","tag":"variable"}},"span":"(3:9)-(3:13)","tag":"assign_expression","target":{"anno":[],"span":"(3:9)-(3:9)","tag":"value","value":{"contents":"i","tag":"variable"}}},"tag":"statement"}]]],"end_label":null,"label":null,"name":null,"span":"(2:7)-(4:11)","tag":"if"}],"name":"hello","span":"(1:7)-(5:9)","subprograms":null,"tag":"main"}]}'.


	prog := programFile progUnits first.
	self assert: prog accesses size equals: 4.
	self assertCollection: (prog accesses collect: [ :each | each entityName ]) hasSameElements: #(i j).
	self assert: prog accesses third isWrite.
	

	

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testProgramWithSimpleIfStatementWithoutBody [
	"program hello
      if (i < j) then
      endif
      end
"
	| prog programFile |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"blocks":null,"conditions":[[{"anno":[],"left":{"anno":[],"span":"(2:11)-(2:11)","tag":"value","value":{"contents":"i","tag":"variable"}},"op":{"tag":"lt"},"right":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"j","tag":"variable"}},"span":"(2:11)-(2:15)","tag":"binary"},[]]],"end_label":null,"label":null,"name":null,"span":"(2:7)-(3:11)","tag":"if"}],"name":"hello","span":"(1:7)-(4:9)","subprograms":null,"tag":"main"}]}'.


	prog := programFile progUnits first.
	self assert: prog accesses size equals: 2.
	self assertCollection: (prog accesses collect: [ :each | each entityName ]) hasSameElements: #(i j)
	

	

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testReturnConstantStatement [
"      integer function hello()
      return 42
      end
"
	| programFile fct |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:15)","statement":{"anno":[],"span":"(2:7)-(2:15)","tag":"return","target":{"anno":[],"span":"(2:14)-(2:15)","tag":"value","value":{"contents":["42",null],"tag":"integer"}}},"tag":"statement"}],"name":"hello","result":null,"span":"(1:7)-(3:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(1:7)-(1:13)"}}]}'.

	self assert: programFile progUnits size equals: 1.
	
	fct := programFile progUnits first.
	self assert: fct body isEmpty
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testReturnStatement [
"      integer function hello()
      return someVar
      end
"
	| programFile fct |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:20)","statement":{"anno":[],"span":"(2:7)-(2:20)","tag":"return","target":{"anno":[],"span":"(2:14)-(2:20)","tag":"value","value":{"contents":"somevar","tag":"variable"}}},"tag":"statement"}],"name":"hello","result":null,"span":"(1:7)-(3:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(1:7)-(1:13)"}}]}'.

	self assert: programFile progUnits size equals: 1.
	
	fct := programFile progUnits first.
	self assert: fct body first class equals: IASTVarAccess.
	self assert: fct body first entityName equals: 'somevar'.
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testSegactCommand [
	"subroutine hello
c@_   segact, lb
      end
"
	| programFile seg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segact, lb","span":"(2:1)-(2:16)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segact'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 1.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 17
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testSegadjCommand [
	"subroutine hello
c@_   segadj,lb
      end
"
	| programFile seg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segadj,lb","span":"(2:1)-(2:15)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segadj'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 1.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 16
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testSegdefCommand [
	"subroutine hello
c@_   segdef, lb
      end
"
	| programFile seg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segdef, lb","span":"(2:1)-(2:16)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segdef'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 1.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 17
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testSeginiCommand [
	"subroutine hello
c@_   segini,lb
      end
"
	| programFile seg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segini,lb","span":"(2:1)-(2:15)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segini'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 1.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 16
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testSegmentDeclarationEmpty [
	"subroutine hello
c@_   segment,user
c@_   end segment
      end
"
	| programFile seg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segment,user","span":"(2:1)-(2:18)","tag":"comment"},{"anno":[],"comment":"@_   end segment","span":"(3:1)-(3:17)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegment.
	self assert: seg entityName equals: 'user'.
	self assert: seg declarations size equals: 0.

	self assert: seg sourceAnchor isNotNil.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 1.
	self assert: seg sourceAnchor endLine equals: 3.
	self assert: seg sourceAnchor endColumn equals: 18
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testSegmentDeclarationWithContent [
	"subroutine hello
c@_   segment, user
        character*40 uname
        integer uid, age
c@_   end segment
      end
"
	| programFile seg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segment, user","span":"(2:1)-(2:19)","tag":"comment"},{"anno":[],"label":null,"span":"(3:9)-(3:26)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(3:22)-(3:26)","type":"scalar","variable":{"anno":[],"span":"(3:22)-(3:26)","tag":"value","value":{"contents":"uname","tag":"variable"}}}],"span":"(3:22)-(3:26)"},"span":"(3:9)-(3:26)","tag":"declaration","type":{"anno":[],"base_type":"character","selector":{"anno":[],"kind":null,"length":{"anno":[],"span":"(3:19)-(3:20)","tag":"value","value":{"contents":["40",null],"tag":"integer"}},"span":"(3:18)-(3:20)"},"span":"(3:9)-(3:20)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(4:9)-(4:24)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(4:17)-(4:19)","type":"scalar","variable":{"anno":[],"span":"(4:17)-(4:19)","tag":"value","value":{"contents":"uid","tag":"variable"}}},{"anno":[],"initial":null,"length":null,"span":"(4:22)-(4:24)","type":"scalar","variable":{"anno":[],"span":"(4:22)-(4:24)","tag":"value","value":{"contents":"age","tag":"variable"}}}],"span":"(4:17)-(4:24)"},"span":"(4:9)-(4:24)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(4:9)-(4:15)"}},"tag":"statement"},{"anno":[],"comment":"@_   end segment","span":"(5:1)-(5:17)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(6:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegment.
	self assert: seg entityName equals: 'user'.
	self assert: seg declarations size equals: 3.

	self assert: seg declarations first entityName equals: 'uname'.
	self assert: seg declarations second entityName equals: 'uid'.
	self assert: seg declarations third entityName equals: 'age'.

]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testSegsupCommand [
	"subroutine hello
c@_   segsup, lb
      end
"
	| programFile seg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segsup, lb","span":"(2:1)-(2:16)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segsup'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 1.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 17
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testSpecialSubroutine [

	"      subroutine __$__
      integer l
c@_   segment point
      real abs, ord
      character*(l) label
c@_   end segment
      end
"

	| programFile entity dummySub segment |
	programFile := self visitJsonCode:
		               '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:15)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:15)-(2:15)","type":"scalar","variable":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"l","tag":"variable"}}}],"span":"(2:15)-(2:15)"},"span":"(2:7)-(2:15)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"comment":"@_   segment point","span":"(3:1)-(3:19)","tag":"comment"},{"anno":[],"label":null,"span":"(4:7)-(4:19)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(4:12)-(4:14)","type":"scalar","variable":{"anno":[],"span":"(4:12)-(4:14)","tag":"value","value":{"contents":"abs","tag":"variable"}}},{"anno":[],"initial":null,"length":null,"span":"(4:17)-(4:19)","type":"scalar","variable":{"anno":[],"span":"(4:17)-(4:19)","tag":"value","value":{"contents":"ord","tag":"variable"}}}],"span":"(4:12)-(4:19)"},"span":"(4:7)-(4:19)","tag":"declaration","type":{"anno":[],"base_type":"real","selector":null,"span":"(4:7)-(4:10)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(5:7)-(5:25)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(5:21)-(5:25)","type":"scalar","variable":{"anno":[],"span":"(5:21)-(5:25)","tag":"value","value":{"contents":"label","tag":"variable"}}}],"span":"(5:21)-(5:25)"},"span":"(5:7)-(5:25)","tag":"declaration","type":{"anno":[],"base_type":"character","selector":{"anno":[],"kind":null,"length":{"anno":[],"span":"(5:17)-(5:19)","tag":"value","value":{"contents":"l","tag":"variable"}},"span":"(5:16)-(5:19)"},"span":"(5:7)-(5:19)"}},"tag":"statement"},{"anno":[],"comment":"@_   end segment","span":"(6:1)-(6:17)","tag":"comment"}],"name":"__$__","options":[null,null],"span":"(1:7)-(7:9)","subprograms":null,"tag":"subroutine"}]}'.


	dummySub := programFile progUnits first.
	self assert: dummySub class equals: IASTIncludedFile.
	self assert: dummySub body size equals: 2.
	self assert: dummySub localVariables size equals: 1.

	entity := programFile progUnits first body first.
	self assert: entity first class equals: IASTVariable.
	self assert: entity first entityName equals: 'l'.

	segment := programFile progUnits first body second.
	self assert: segment class equals: IASTEsopeSegment.
	self assert: segment entityName equals: 'point'.
	self assert: segment declarations size equals: 3.

	entity := segment declarations first.
	self assert: entity class equals: IASTVariable.
	self assert: entity entityName equals: 'abs'.
	self assert: entity typeSpec entityName equals: 'real'.

	entity := segment declarations second.
	self assert: entity class equals: IASTVariable.
	self assert: entity entityName equals: 'ord'.
	self assert: entity typeSpec entityName equals: 'real'.

	entity := segment declarations third.
	self assert: entity class equals: IASTVariable.
	self assert: entity entityName equals: 'label'.
	self assert: entity typeSpec entityName equals: 'character'
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testStringVariableDeclaration [
	"subroutine hello
      character*8 str
      end
"
	| programFile var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:21)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:19)-(2:21)","type":"scalar","variable":{"anno":[],"span":"(2:19)-(2:21)","tag":"value","value":{"contents":"str","tag":"variable"}}}],"span":"(2:19)-(2:21)"},"span":"(2:7)-(2:21)","tag":"declaration","type":{"anno":[],"base_type":"character","selector":{"anno":[],"kind":null,"length":{"anno":[],"span":"(2:17)-(2:17)","tag":"value","value":{"contents":["8",null],"tag":"integer"}},"span":"(2:16)-(2:17)"},"span":"(2:7)-(2:17)"}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first  size equals: 1.

	var := programFile progUnits first body first first.
	self assert: var class equals: IASTVariable.
	self assert: var entityName equals: 'str'.
	self assert: var typeSpec class equals: IASTTypeRef.
	self assert: var typeSpec entityName equals: 'character'.

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testSubroutineInvocation [
	"subroutine hello
      call someSubRoutine
      end
"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:25)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(2:25)-(2:25)"},"function":{"anno":[],"span":"(2:12)-(2:25)","tag":"value","value":{"contents":"somesubroutine","tag":"variable"}},"span":"(2:7)-(2:25)","tag":"call"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTInvocation.
	self assert: stmt entityName equals: 'somesubroutine'.
	self assert: stmt arguments size equals: 0

]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testSubroutineInvocationWithArguments [
	"subroutine hello
      call someSubRoutine(bar,5,baz)
      end
"
	| programFile stmt arg |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:36)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:27)-(2:29)","tag":"value","value":{"contents":"bar","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:27)-(2:29)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:31)-(2:31)","tag":"value","value":{"contents":["5",null],"tag":"integer"}},"tag":"expr"},"name":null,"span":"(2:31)-(2:31)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:33)-(2:35)","tag":"value","value":{"contents":"baz","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:33)-(2:35)"}],"span":"(2:26)-(2:36)"},"function":{"anno":[],"span":"(2:12)-(2:25)","tag":"value","value":{"contents":"somesubroutine","tag":"variable"}},"span":"(2:7)-(2:36)","tag":"call"},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTInvocation.
	self assert: stmt entityName equals: 'somesubroutine'.
	self assert: stmt arguments size equals: 2.

	arg := stmt arguments first.
	self assert: arg class equals: IASTVarAccess.
	self assert: arg entityName equals: 'bar'.

	arg := stmt arguments second.
	self assert: arg class equals: IASTVarAccess.
	self assert: arg entityName equals: 'baz'.
]

{ #category : #'tests-statement' }
JsonToIASTVisitorTest >> testTwoIntegerVariableDeclarations [
	"subroutine hello
      integer i,j
      end
"
	| programFile var |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:17)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:15)-(2:15)","type":"scalar","variable":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"i","tag":"variable"}}},{"anno":[],"initial":null,"length":null,"span":"(2:17)-(2:17)","type":"scalar","variable":{"anno":[],"span":"(2:17)-(2:17)","tag":"value","value":{"contents":"j","tag":"variable"}}}],"span":"(2:15)-(2:17)"},"span":"(2:7)-(2:17)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 2.

	var := programFile progUnits first body first first.
	self assert: var class equals: IASTVariable.
	self assert: var entityName equals: 'i'.
	self assert: var typeSpec class equals: IASTTypeRef.
	self assert: var typeSpec entityName equals: 'integer'.

	var := programFile progUnits first body first second.
	self assert: var class equals: IASTVariable.
	self assert: var entityName equals: 'j'.
	self assert: var typeSpec class equals: IASTTypeRef.
	self assert: var typeSpec entityName equals: 'integer'.
]

{ #category : #'tests-esope' }
JsonToIASTVisitorTest >> testWriteStatementWithStringArgument [
	"
      subroutine print
       write(*,*) 'hello'      
      end	
	"
	| programFile stmt |
	programFile :=  self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:25)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(2:19)-(2:25)","tag":"value","value":{"contents":"hello","tag":"string"}}],"span":"(2:19)-(2:25)"},"format":{"anno":[],"list":[{"anno":[],"expr":{"anno":[],"span":"(2:14)-(2:14)","tag":"value","value":{"tag":"star"}},"name":null,"span":"(2:14)-(2:14)"},{"anno":[],"expr":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"tag":"star"}},"name":null,"span":"(2:16)-(2:16)"}],"span":"(2:13)-(2:17)"},"span":"(2:8)-(2:25)","tag":"write"},"tag":"statement"}],"name":"print","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.


	self assert: programFile progUnits first body first size equals: 1.
	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTInvocation.
	self assert: stmt entityName equals: 'write'.
	self assert: stmt arguments size equals: 0.
]

{ #category : #running }
JsonToIASTVisitorTest >> visitJsonCode: jsonCode [
	| visitor |
	visitor := JsonToIASTVisitor new.
	^visitor visitProgramFile: (NeoJSONReader fromString: jsonCode)
]
