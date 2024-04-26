Class {
	#name : #SyntaxJsonToIASTVisitorTest,
	#superclass : #TestCase,
	#category : #'EsopeImporter-Tests-Visitor'
}

{ #category : #generation }
SyntaxJsonToIASTVisitorTest class >> generateFortranSourcesForTest: mth [
	"regenerate #jsonCode for test method mth from the source code in these methods"

	| fortranFilename fortran json |
	fortranFilename := 'tmpFASTSource.f'.

	fortran := mth comments first.
	json := FortranProjectSyntaxImporter new getJsonFor: fortran.
	json := String streamContents: [ :str || i |
		i := json indexOfSubCollection: '/home/'.
		str << (json copyFrom: 1 to: i-1).
		str << './fortranCode.F'.
		i := json indexOfSubCollection: fortranFilename.
		str << (json copyFrom: i + fortranFilename size to: json size)
	].

	mth ast body statements first value arguments: { RBLiteralValueNode value: json }.
	self compile: mth ast formattedCode.
]

{ #category : #generation }
SyntaxJsonToIASTVisitorTest class >> generateFortranSourcesForTests [
	"regenerate #jsonCode for all test methods from the source code in these methods"

	self methods do: [ :mth|
		((mth selector beginsWith: 'test') and: [
			(self statement: mth ast body statements first isAssignmentTo: #programFile) and: [ 
			mth comments isNotEmpty ] ])
			ifTrue: [ self generateFortranSourcesForTest: mth ]
	]

]

{ #category : #generation }
SyntaxJsonToIASTVisitorTest class >> statement: astStatement isAssignmentTo: aSymbol [

	^(astStatement class = RBAssignmentNode) and: [
		astStatement variable name = aSymbol ]
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testAccessArrayWithIndices [
	"
      subroutine hello
      integer arr(10)
      someVar = arr(i)
      end
"

	| programFile var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "5", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "3", "column":"7"}, "type" : {"tag" : "type_reference", "name":"INTEGER"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"ARR"}, "dimension_declarators" : [{"tag" : "literal_expression", "literal" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"19"}, "value":"10"}}]}]}, {"tag" : "assignment_statement", "start_pos" : {"line" : "4", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"7"}, "name":"SOMEVAR"}], "right" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"17"}, "name":"ARR"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"21"}, "name":"I"}]}]}]}] }'.

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
	self assert: var entityName equals: 'i'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testAccessArrayWithIndicesLiteral [
	"
      subroutine hello
      integer arr(10)
      someVar = arr(5)
      end
"

	| programFile var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "5", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "3", "column":"7"}, "type" : {"tag" : "type_reference", "name":"INTEGER"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"ARR"}, "dimension_declarators" : [{"tag" : "literal_expression", "literal" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"19"}, "value":"10"}}]}]}, {"tag" : "assignment_statement", "start_pos" : {"line" : "4", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"7"}, "name":"SOMEVAR"}], "right" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"17"}, "name":"ARR"}, "qualifiers_list" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "4", "column":"21"}, "value":"5"}}]}]}]}] }'.

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
	self assert: var indices first isNil
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testAccessArrayWithSeveralIndices [
	"
      subroutine hello
      integer arr(10, 10, 10)
      someVar = arr(x, 2, y)
      end
"

	| programFile var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "5", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "3", "column":"7"}, "type" : {"tag" : "type_reference", "name":"INTEGER"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"ARR"}, "dimension_declarators" : [{"upper_bound" : {"tag" : "literal_expression", "literal" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"19"}, "value":"10"}}}, {"upper_bound" : {"tag" : "literal_expression", "literal" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"23"}, "value":"10"}}}, {"tag" : "literal_expression", "literal" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"27"}, "value":"10"}}]}]}, {"tag" : "assignment_statement", "start_pos" : {"line" : "4", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"7"}, "name":"SOMEVAR"}], "right" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"17"}, "name":"ARR"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"21"}, "name":"X"}, {"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "4", "column":"24"}, "value":"2"}}, {"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"27"}, "name":"Y"}]}]}]}] }'.

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
	self assert: var indices third entityName equals: 'y'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testAssignementStatement [
	"
      subroutine hello
      someVar = otherVar
      end
"

	| programFile var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"7"}, "name":"SOMEVAR"}], "right" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"OTHERVAR"}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 2.

	var := programFile progUnits first body first first.
	self assert: var class equals: IASTVarAccess.
	self assert: var isWrite.
	self assert: var entityName equals: 'SOMEVAR'.

	var := programFile progUnits first body first second.
	self assert: var class equals: IASTVarAccess.
	self deny: var isWrite.
	self assert: var entityName equals: 'OTHERVAR'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testAssignementStatementWithComplexRHS [
	"
      subroutine hello
      someVar = otherVar + thirdVar
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"7"}, "name":"SOMEVAR"}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "binary_expression", "lhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"OTHERVAR"}, "operator" : "+", "rhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"28"}, "name":"THIRDVAR"}}}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 3.

	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTVarAccess.
	self assert: stmt entityName equals: 'somevar'.

	stmt := programFile progUnits first body first second.
	self assert: stmt class equals: IASTVarAccess.
	self assert: stmt entityName equals: 'othervar'.

	stmt := programFile progUnits first body first third.
	self assert: stmt class equals: IASTVarAccess.
	self assert: stmt entityName equals: 'thirdvar'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testAssignementStatementWithEsoAt [
	"
      subroutine hello
      someVar = D__(var,1)
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"7"}, "name":"SOMEVAR"}], "right" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"21"}, "name":"VAR"}, {"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"25"}, "value":"1"}}]}]}]}] }'.

	"first statement in body"
	stmt := programFile progUnits first body first.
	self assert: stmt size equals: 2.

	self assert: stmt first class equals: IASTVarAccess.
	self assert: stmt first entityName equals: 'somevar'.

	self assert: stmt second class equals: IASTVarEsoAt.
	self assert: stmt second entityName equals: 'd__'
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testBlockDataWithOneCommon [
	"
      blockdata hello
      common /mycom/ i
      end
"

	| programFile blockdata var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "block_data", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"17"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "common_statement", "start_pos" : {"line" : "3", "column":"7"}, "common_body" : [{"common_name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"MYCOM"}},{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"22"}, "name":"I"}, "dimension_declarators" : []}]}]}] }'.


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
SyntaxJsonToIASTVisitorTest >> testBlockDataWithOneCommonOneData [
	"
      block data hello
      common /mycom/ i
      data i /12345/
      end
"
	| programFile blockdata |
	self flag: 'not dealing with COMMON for now'.
	self skip.

	programFile :=  self visitJsonCode: ''.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTBlockData.

	blockdata := programFile progUnits first.
	self assert: blockdata entityName equals: 'hello'.
	self assert: blockdata body size equals: 3.
	self assert: blockdata comments isEmpty.
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testCallToWrite [
	"
      subroutine mysub (msg)
      write(*,*) msg
      end
"

	| programFile stmt arg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"MYSUB"}, "prog_unit_parameters" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"25"}, "name":"MSG"}], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "write_statement", "start_pos" : {"line" : "3", "column":"7"}, "control_info_list" : [{"asterisk":"*"},{"asterisk":"*"}], "io_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"18"}, "name":"MSG"}]}]}] }'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt first class equals: IASTInvocation.
	self assert: stmt first entityName equals: 'WRITE'.
	self assert: stmt first arguments size equals: 1.
	self assert: stmt first sourceAnchor isNotNil.

	arg := stmt first arguments first.
	self assert: arg class equals: IASTVarAccess.
	self assert: arg entityName equals: 'MSG'.
	self deny: arg isWrite
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testComment [
	"c     blah
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "1":"c     blah\n" }, "file" : "/home/anquetil/Pharo/images/fortran/FastTmp/tmpFASTSource.f", "program_units" : [{"tag" : "main", "name" : "null", "prog_unit_parameters" : [], "start_pos" : {"line" : "3", "column":"1"}, "end_pos" : {"line" : "3", "column":"3"}, "statement_list" : []}] }'.

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
	self assert: stmt sourceAnchor endColumn equals: 11
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testCommentInside [
	"
      integer function hello()
c     blah
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c     blah\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"24"}, "name":"HELLO"}, "prog_unit_parameters" : [], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits first body size equals: 1.
	stmt := programFile progUnits first body first.

	self assert: stmt class equals: IASTComment.
	self assert: stmt text equals: '     blah'
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testCommentOutside [
	"c     blah
      integer function hello()
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "1":"c     blah\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"24"}, "name":"HELLO"}, "prog_unit_parameters" : [], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits size equals: 2.
	stmt := programFile progUnits first.
	self assert: stmt class equals: IASTComment.
	self assert: stmt text equals: '     blah'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testContinueStatement [
	"
      PROGRAM MYPROG
      continue
      END
"

	| programFile |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"MYPROG"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "continue_statement", "start_pos" : {"line" : "3", "column":"7"}}]}] }'.


	self assert: programFile progUnits first body isEmpty
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testESOAtWithArrayArgument [
"
      subroutine hello
        integer arr(10)
        x = D__(y,arr(z))
      end
"
	"Special case of a D__ function call with an array as argument"

	| programFile d__ arg |
	self skip.

	programFile := self visitJsonCode: ''.

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
SyntaxJsonToIASTVisitorTest >> testEmptyBlockData [
	"
      BLOCK data hello
      end
"

	| programFile block |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "block_data", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTBlockData.
	block := programFile progUnits first.
	self assert: block entityName equals: 'HELLO'.
	self assert: block body isEmpty.
	self assert: block comments isEmpty
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testEmptyFunction [
	"
      integer function hello()
      end
"

	| programFile fct |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"24"}, "name":"HELLO"}, "prog_unit_parameters" : [], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTFunction.
	fct := programFile progUnits first.
	self assert: fct entityName equals: 'HELLO'.
	self assert: fct parameters isEmpty.
	self assert: fct returnType class equals: IASTTypeRef.
	self assert: fct returnType entityName equals: 'INTEGER'.
	self assert: fct body isEmpty.

	self assert: fct sourceAnchor notNil.
	self assert: fct sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: fct sourceAnchor fileName equals: './fortranCode.F'.
	self assert: fct sourceAnchor startLine equals: 2.
	self assert: fct sourceAnchor startColumn equals: 7.
	self assert: fct sourceAnchor endLine equals: 3.
	self assert: fct sourceAnchor endColumn equals: 9
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testEmptyFunctionWithArguments [
	"
      integer function hello(i,j)
      end
"

	| programFile fct param |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"24"}, "name":"HELLO"}, "prog_unit_parameters" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"30"}, "name":"I"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"32"}, "name":"J"}], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}] }'.


	fct := programFile progUnits first.
	self assert: fct entityName equals: 'HELLO'.
	self assert: fct parameters size equals: 2.

	param := fct parameters first.
	self assert: param class equals: IASTParameter.
	self assert: param entityName equals: 'I'.

	param := fct parameters second.
	self assert: param class equals: IASTParameter.
	self assert: param entityName equals: 'J'
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testEmptyProgram [
	"
      program hello
      end
"

	| programFile prog |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"HELLO"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self
		assert: programFile progUnits first class
		equals: IASTMainProgram.
	prog := programFile progUnits first.
	self assert: prog entityName equals: 'HELLO'.
	self assert: prog body isEmpty.
	self assert: prog comments isEmpty.

	self assert: prog sourceAnchor notNil.
	self assert: prog sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: prog sourceAnchor fileName equals: './fortranCode.F'.
	self assert: prog sourceAnchor startLine equals: 2.
	self assert: prog sourceAnchor startColumn equals: 7.
	self assert: prog sourceAnchor endLine equals: 3.
	self assert: prog sourceAnchor endColumn equals: 9
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testEmptyReturnStatement [
	"
      subroutine hello
      return
      end
"

	| programFile fct |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "return_statement", "start_pos" : {"line" : "3", "column":"7"}}]}] }'.

	self assert: programFile progUnits size equals: 1.

	fct := programFile progUnits first.
	self assert: fct body isEmpty
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testEmptySubroutine [
	"
      subroutine hello
      end
"

	| programFile sub |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self assert: programFile progUnits first class equals: IASTSubroutine.
	sub := programFile progUnits first.
	self assert: sub entityName equals: 'HELLO'.
	self assert: sub parameters isEmpty.
	self assert: sub body isEmpty.

	self assert: sub sourceAnchor notNil.
	self assert: sub sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: sub sourceAnchor fileName equals: './fortranCode.F'.
	self assert: sub sourceAnchor startLine equals: 2.
	self assert: sub sourceAnchor startColumn equals: 7.
	self assert: sub sourceAnchor endLine equals: 3.
	self assert: sub sourceAnchor endColumn equals: 9
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testEmptySubroutineOneParam [
	"
      subroutine hello( name )
      end
"

	| programFile sub |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"25"}, "name":"NAME"}], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}] }'.


	sub := programFile progUnits first.
	self assert: sub entityName equals: 'HELLO'.
	self assert: sub parameters size equals: 1.
	self assert: sub parameters first class equals: IASTParameter.
	self assert: sub parameters first entityName equals: 'NAME'.
	self assert: sub body isEmpty
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testEmptySubroutineTwoParams [
	"
      subroutine hello( param1, param2 )
      end
"

	| programFile sub |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"25"}, "name":"PARAM1"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"33"}, "name":"PARAM2"}], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}] }'.


	sub := programFile progUnits first.
	self assert: sub entityName equals: 'HELLO'.
	self assert: sub parameters size equals: 2.
	self assert: sub parameters first class equals: IASTParameter.
	self assert: sub parameters first entityName equals: 'PARAM1'.
	self assert: sub parameters second class equals: IASTParameter.
	self assert: sub parameters second entityName equals: 'PARAM2'.
	self assert: sub body isEmpty
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testEsoArTwoArgs [
	"
      subroutine hello()
        d__(baz,bar) = 5
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"9"}, "left" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"9"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"13"}, "name":"BAZ"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"BAR"}]}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"24"}, "value":"5"}}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 1.
	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTVarEsoAt.
	self assert: stmt isWrite.
	self assert: stmt entities size equals: 2
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testEsoArWithDotArg [
	"
      subroutine hello( )
	     d__(p,a(d__(p,i))) = 5
      end
"

	| programFile d__ arg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"14"}, "left" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"14"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"18"}, "name":"P"}, {"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"20"}, "name":"A"}, "qualifiers_list" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"22"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"26"}, "name":"P"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"28"}, "name":"I"}]}]}]}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"35"}, "value":"5"}}]}]}] }'.


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
	self assert: d__ entities second entityName equals: 'i'
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testEsoArWithEsoAtArg [
	"
      subroutine hello( )
	     d__(baz,bar(2)) = 5
      end
"

	| programFile d__ arg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"14"}, "left" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"14"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"18"}, "name":"BAZ"}, {"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"22"}, "name":"BAR"}, "qualifiers_list" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"26"}, "value":"2"}}]}]}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"32"}, "value":"5"}}]}]}] }'.


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
	self assert: arg entityName equals: 'bar'
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testEsoArWithVarArg [
	"
      subroutine hello( )
	     d__(baz,bar(i)) = 5
      end
"

	| programFile d__ arg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"14"}, "left" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"14"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"18"}, "name":"BAZ"}, {"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"22"}, "name":"BAR"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"26"}, "name":"I"}]}]}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"32"}, "value":"5"}}]}]}] }'.


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
SyntaxJsonToIASTVisitorTest >> testEsoAtOneArg [
	"
      subroutine hello( )
        d__(baz,2) = 5.3
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"9"}, "left" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"9"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"13"}, "name":"BAZ"}, {"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"17"}, "value":"2"}}]}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_real_constant", "start_pos" : {"line" : "3", "column":"22"}, "value":"5.3"}}]}]}] }'.


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
SyntaxJsonToIASTVisitorTest >> testEsoAtTwoArgs [
	"
      subroutine hello( )
        d__(baz,bar) = 5
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"9"}, "left" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"9"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"13"}, "name":"BAZ"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"BAR"}]}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"24"}, "value":"5"}}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 1.
	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTVarEsoAt.
	self assert: stmt isWrite.
	self assert: stmt entities size equals: 2.
	stmt entities do: [ :ent |
		self assert: ent class equals: IASTVarAccess.
		self assert: (#( baz bar ) includes: ent entityName asSymbol).
		self deny: ent isWrite ]
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testEsoAtTwoArgsReceivesVar [
	"
      subroutine hello( )
        d__(baz,bar) = otherVar
      end
"

	| programFile var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"9"}, "left" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"9"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"13"}, "name":"BAZ"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"BAR"}]}], "right" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"24"}, "name":"OTHERVAR"}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 2.

	var := programFile progUnits first body first first.
	self assert: var class equals: IASTVarEsoAt.

	var := programFile progUnits first body first second.
	self assert: var class equals: IASTVarAccess.
	self assert: var entityName equals: 'othervar'.
	self deny: var isWrite
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testEsoSl [
	"
      subroutine hello( )
        n = s__(a,i)
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"9"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"9"}, "name":"N"}], "right" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"13"}, "name":"S__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"A"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"19"}, "name":"I"}]}]}]}] }'.


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
SyntaxJsonToIASTVisitorTest >> testEsoSlWithDot [
	"
      subroutine hello( )
        n = s__(d__(p,a),i)
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"9"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"9"}, "name":"N"}], "right" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"13"}, "name":"S__"}, "qualifiers_list" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"21"}, "name":"P"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"23"}, "name":"A"}]}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"26"}, "name":"I"}]}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 2.
	stmt := programFile progUnits first body first second.
	self assert: stmt class equals: IASTVarEsoSl.
	self assert: stmt entities size equals: 2.

	self assert: stmt entities first class equals: IASTVarEsoAt.
	self assert: stmt entities first entities size equals: 2.
	self
		assert: stmt entities first entities first class
		equals: IASTVarAccess.
	self
		assert: stmt entities first entities first entityName
		equals: 'p'.
	self
		assert: stmt entities first entities second class
		equals: IASTVarAccess.
	self
		assert: stmt entities first entities second entityName
		equals: 'a'.

	self assert: stmt entities second class equals: IASTVarAccess.
	self assert: stmt entities second entityName equals: 'i'
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testEsoSlWithTwoDot [
	"
      subroutine hello( )
        n = s__(d__(p,a),d__(p,i))
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"9"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"9"}, "name":"N"}], "right" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"13"}, "name":"S__"}, "qualifiers_list" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"21"}, "name":"P"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"23"}, "name":"A"}]}, {"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"26"}, "name":"D__"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"30"}, "name":"P"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"32"}, "name":"I"}]}]}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 2.
	stmt := programFile progUnits first body first second.
	self assert: stmt class equals: IASTVarEsoSl.
	self assert: stmt entities size equals: 2.
	self assert: stmt entities first class equals: IASTVarEsoAt.
	self assert: stmt entities first entities size equals: 2.
	self
		assert: stmt entities first entities first class
		equals: IASTVarAccess.
	self
		assert: stmt entities first entities first entityName
		equals: 'p'.
	self
		assert: stmt entities first entities second class
		equals: IASTVarAccess.
	self
		assert: stmt entities first entities second entityName
		equals: 'a'.

	self assert: stmt entities second class equals: IASTVarEsoAt.
	self assert: stmt entities second entities size equals: 2.
	self
		assert: stmt entities second entities first class
		equals: IASTVarAccess.
	self
		assert: stmt entities second entities first entityName
		equals: 'p'.
	self
		assert: stmt entities second entities second class
		equals: IASTVarAccess.
	self
		assert: stmt entities second entities second entityName
		equals: 'i'
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testEsopeIfCommentStatement [
"
      subroutine sub()
c@_   IF (N.GT.0) SEGINI P
      end
"
	| programFile seg cond |
	
	self skip.
	
	programFile :=  self visitJsonCode: ''.

	self assert: programFile progUnits size equals: 1.
	
	cond := programFile progUnits first body first first.
	self assert: cond class equals: IASTVarAccess.
	self assert: cond entityName equals: 'n'.

	seg := programFile progUnits first body first second.
	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'p'.
	self assert: seg esopeCommand equals: 'segini'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 19.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 29
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testFunctionWithFunctionInvocation [
	"
      integer function efunc()
      i = ifunc (i, j)
      end
"

	| programFile fct |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"24"}, "name":"EFUNC"}, "prog_unit_parameters" : [], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"7"}, "name":"I"}], "right" : [{"tag" : "array_element_name", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"11"}, "name":"IFUNC"}, "qualifiers_list" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"18"}, "name":"I"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"21"}, "name":"J"}]}]}]}] }'.


	self assert: programFile progUnits size equals: 1.

	fct := programFile progUnits first.

	self assert: fct class equals: IASTFunction.
	self assert: fct entityName equals: 'efunc'.
	self assert: fct body first size equals: 2.
	self assert: fct sourceAnchor startLine equals: 1.
	self assert: fct sourceAnchor startColumn equals: 7.
	self assert: fct sourceAnchor endLine equals: 3.
	self assert: fct sourceAnchor endColumn equals: 10
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testGotoStatement [
	"
      PROGRAM MYPROG
      goto 100
      END
"

	| programFile |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"MYPROG"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "unconditional_goto_statement", "start_pos" : {"line" : "3", "column":"7"}, "labels" : [{"label_ref":"100"}], "var" : []}]}] }'.


	self assert: programFile progUnits first body isEmpty
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testIfStatement [
	"
      integer function hello()
      if(a) a=1
      end
"

	| programFile fct |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"24"}, "name":"HELLO"}, "prog_unit_parameters" : [], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "logical_if_statement", "start_pos" : {"line" : "3", "column":"7"}, "expression" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"10"}, "name":"A"}, "statement" : {"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"13"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"13"}, "name":"A"}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"15"}, "value":"1"}}]}}]}] }'.

	self assert: programFile progUnits size equals: 1.

	fct := programFile progUnits first.
	self assert: fct body first first class equals: IASTVarAccess.
	self assert: fct body first first entityName equals: 'a'.
	self assert: fct body first second first class equals: IASTVarAccess.
	self assert: fct body first second first entityName equals: 'a'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testImplicitNoneStatement [
	"
      PROGRAM MYPROG
       implicit none
      END
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"MYPROG"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "implicit_none_statement", "start_pos" : {"line" : "3", "column":"8"}}]}] }'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTImplicit.
	self assert: stmt rules isNil
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testImplicitStatementSeveralRanges [
	"
      PROGRAM MYPROG
       implicit character (c-e, h, l-m)
      END
"

	| programFile stmt rule range |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"MYPROG"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "implicit_statement", "start_pos" : {"line" : "3", "column":"8"}, "implicit_parameters" : [{"type" : {"tag" : "type_reference", "name":"CHARACTER"}, "implicit_elements" : [{"tag" : "implicit_range", "implicit_range_lower" : "c", "implicit_range_upper":"e"},{"tag" : "implicit_range", "implicit_range_lower" : "h", "implicit_range_upper":""},{"tag" : "implicit_range", "implicit_range_lower" : "l", "implicit_range_upper":"m"}]}]}]}] }'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTImplicit.
	self assert: stmt rules isCollection.
	self assert: stmt rules size equals: 1.

	rule := stmt rules first.
	self assert: rule class equals: IASTImplicitTypingRule.
	self assert: rule forType class equals: IASTTypeRef.
	self assert: rule ranges size equals: 3.

	range := rule ranges first.
	self assert: range isCollection.
	self assertCollection: range equals: { $c. $e }.

	range := rule ranges second.
	self assert: range isCollection.
	self assertCollection: range equals: { $h. $h }.

	range := rule ranges third.
	self assert: range isCollection.
	self assertCollection: range equals: { $l. $m }
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testImplicitStatementSimpleChar [
	"
      PROGRAM MYPROG
       implicit character (c)
      END
"

	| programFile stmt range rule |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"MYPROG"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "implicit_statement", "start_pos" : {"line" : "3", "column":"8"}, "implicit_parameters" : [{"type" : {"tag" : "type_reference", "name":"CHARACTER"}, "implicit_elements" : [{"tag" : "implicit_range", "implicit_range_lower" : "c", "implicit_range_upper":""}]}]}]}] }'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTImplicit.
	self assert: stmt rules size equals: 1.

	rule := stmt rules first.
	self assert: rule forType class equals: IASTTypeRef.
	self assert: rule forType entityName equals: 'character'.

	self assert: rule ranges size equals: 1.

	range := rule ranges first.
	self assert: range isCollection.
	self assertCollection: range equals: { $c. $c }
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testImplicitStatementSimpleRange [
	"
      PROGRAM MYPROG
       implicit character (c-e)
      END
"

	| programFile stmt range rule |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"MYPROG"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "implicit_statement", "start_pos" : {"line" : "3", "column":"8"}, "implicit_parameters" : [{"type" : {"tag" : "type_reference", "name":"CHARACTER"}, "implicit_elements" : [{"tag" : "implicit_range", "implicit_range_lower" : "c", "implicit_range_upper":"e"}]}]}]}] }'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTImplicit.
	self assert: stmt rules size equals: 1.

	rule := stmt rules first.
	self assert: rule ranges size equals: 1.
	range := rule ranges first.
	self assert: range isCollection.
	self assertCollection: range equals: { $c. $e }
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testIncludeFile [
	"
      subroutine hello( )
c@_#include ""file.inc""
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c@_#include \"file.inc\"\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits first body size equals: 1.
	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTInclude.
	self assert: stmt includeCommand equals: 'include'.
	self assert: stmt entityName equals: 'file.inc'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testIntegerVariableDeclaration [
	"
      subroutine hello
      integer i
      end
"

	| programFile var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "3", "column":"7"}, "type" : {"tag" : "type_reference", "name":"INTEGER"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"I"}, "dimension_declarators" : []}]}]}] }'.


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
SyntaxJsonToIASTVisitorTest >> testMultipleStatements [
	"
      subroutine hello
      integer someVar
      someVar = 3 * someVar
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "5", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "3", "column":"7"}, "type" : {"tag" : "type_reference", "name":"INTEGER"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"SOMEVAR"}, "dimension_declarators" : []}]}, {"tag" : "assignment_statement", "start_pos" : {"line" : "4", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"7"}, "name":"SOMEVAR"}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "binary_expression", "lhs" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "4", "column":"17"}, "value":"3"}, "operator" : "*", "rhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"21"}, "name":"SOMEVAR"}}}]}]}] }'.


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
	self assert: stmt entityName equals: 'somevar'
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testPointeurDeclaration [
	"
      subroutine hello
c@_   pointeur p1.pstr
      end
"

	| programFile seg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c@_   pointeur p1.pstr\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopePointer.
	self assert: seg entityName equals: 'p1.pstr'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 7.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 23
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testProgramWithEmptyDoStatement [
	"
      program hello
      do i=1, n
      enddo 
      end
"

	| prog programFile |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "/home/anquetil/Pharo/images/fortran/FastTmp/tmpFASTSource.f", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"HELLO"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "5", "column":"9"}, "statement_list" : [{"tag" : "do_statement", "start_pos" : {"line" : "3", "column":"7"}, "loop_control" : {"variable_name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"10"}, "name":"I"}, "init" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"12"}, "value":"1"}, "limit" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"N"}}, "statement_list" : [{"tag" : "continue_statement", "start_pos" : {"line" : "4", "column":"13"}}], "end_do" : {"label":""}}]}] }'.


	prog := programFile progUnits first.
	self assert: prog accesses size equals: 2.
	self
		assertCollection:
		(prog accesses collect: [ :each | each entityName ])
		hasSameElements: #( i n )
]

{ #category : #'tests-progUnit' }
SyntaxJsonToIASTVisitorTest >> testProgramWithMultipleProgUnits [
	"
      program myprog
      end

      integer function ifunc( k, l )
      end

      subroutine mysub (msg)
      end
"

	| programFile node |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"MYPROG"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "3", "column":"9"}, "statement_list" : []}, {"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "5", "column":"24"}, "name":"IFUNC"}, "prog_unit_parameters" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "5", "column":"31"}, "name":"K"}, {"tag" : "symbolic_name", "start_pos" : {"line" : "5", "column":"34"}, "name":"L"}], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "5", "column":"7"}, "end_pos" : {"line" : "6", "column":"9"}, "statement_list" : []}, {"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "8", "column":"18"}, "name":"MYSUB"}, "prog_unit_parameters" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "8", "column":"25"}, "name":"MSG"}], "start_pos" : {"line" : "8", "column":"7"}, "end_pos" : {"line" : "9", "column":"9"}, "statement_list" : []}] }'.

	self assert: programFile progUnits size equals: 3.

	node := programFile progUnits first.
	self assert: node class equals: IASTMainProgram.
	self assert: node entityName equals: 'MYPROG'.
	self assert: node body size equals: 0.
	self assert: node accesses size equals: 0.
	self assert: node invocations size equals: 0.

	node := programFile progUnits second.
	self assert: node class equals: IASTFunction.
	self assert: node parameters size equals: 2.
	self assert: node parameters first entityName equals: 'K'.
	self assert: node parameters second entityName equals: 'L'.

	node := programFile progUnits third.
	self assert: node class equals: IASTSubroutine.
	self assert: node parameters size equals: 1.
	self assert: node parameters first entityName equals: 'MSG'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testProgramWithOneStatement [
	"
      program hello
      a = -b
      end
"

	| programFile prog |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"HELLO"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"7"}, "name":"A"}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "constant_signed", "sign" : "-", "constant" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"12"}, "name":"B"}}}]}]}] }'.


	self assert: programFile class equals: IASTProgramFile.
	self assert: programFile progUnits size equals: 1.
	self
		assert: programFile progUnits first class
		equals: IASTMainProgram.

	prog := programFile progUnits first.
	self assert: prog entityName equals: 'hello'.
	self assert: prog body size equals: 1.
	self assert: prog comments isEmpty.
	self assert: prog body first size equals: 2
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testProgramWithSimpleIfElseStatementWitBody [
	"
      program hello
      if (i .lt. j) then
        i = i + 1
      else
        j = j - 1
      endif
      end
"

	| prog programFile |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"HELLO"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "8", "column":"9"}, "statement_list" : [{"tag" : "block_if_statement", "start_pos" : {"line" : "3", "column":"7"}, "condition" : {"tag" : "logical_expression", "expression" : {"tag" : "logical_factor", "negated" : "false", "expression" : {"tag" : "logical_primary", "expression" : {"tag" : "binary_expression", "lhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"11"}, "name":"I"}, "operator" : ".LT.", "rhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"18"}, "name":"J"}}}}}, "then_statements" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "4", "column":"9"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"9"}, "name":"I"}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "binary_expression", "lhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"13"}, "name":"I"}, "operator" : "+", "rhs" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "4", "column":"17"}, "value":"1"}}}]}], "else_block" : {"tag" : "else", "start_pos" : {"line" : "5", "column":"7"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "6", "column":"9"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "6", "column":"9"}, "name":"J"}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "binary_expression", "lhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "6", "column":"13"}, "name":"J"}, "operator" : "-", "rhs" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "6", "column":"17"}, "value":"1"}}}]}], "end_if" : {"tag" : "end_if", "start_pos" : {"line" : "7", "column":"7"}}}}]}] }'.


	prog := programFile progUnits first.
	self assert: prog accesses size equals: 6.
	self
		assertCollection:
		(prog accesses collect: [ :each | each entityName ])
		hasSameElements: #( i j ).
	self
		assert:
		(prog accesses select: [ :each | each entityName = 'i' ]) size
		equals: 3.
	self assert: prog accesses third isWrite.
	self assert: prog accesses fifth isWrite
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testProgramWithSimpleIfStatementWitBody [
	"
      program hello
      if (i .lt. j) then
        i = j
      endif
      end
"

	| prog programFile |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"HELLO"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "6", "column":"9"}, "statement_list" : [{"tag" : "block_if_statement", "start_pos" : {"line" : "3", "column":"7"}, "condition" : {"tag" : "logical_expression", "expression" : {"tag" : "logical_factor", "negated" : "false", "expression" : {"tag" : "logical_primary", "expression" : {"tag" : "binary_expression", "lhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"11"}, "name":"I"}, "operator" : ".LT.", "rhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"18"}, "name":"J"}}}}}, "then_statements" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "4", "column":"9"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"9"}, "name":"I"}], "right" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"13"}, "name":"J"}]}], "else_block" : {"statement_list" : [], "end_if" : {"tag" : "end_if", "start_pos" : {"line" : "5", "column":"7"}}}}]}] }'.


	prog := programFile progUnits first.
	self assert: prog accesses size equals: 4.
	self
		assertCollection:
		(prog accesses collect: [ :each | each entityName ])
		hasSameElements: #( i j ).
	self assert: prog accesses third isWrite
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testProgramWithSimpleIfStatementWithoutBody [
	"
      program hello
      if (i .lt. j) then
      endif
      end
"

	| prog programFile |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "main", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"15"}, "name":"HELLO"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "5", "column":"9"}, "statement_list" : [{"tag" : "block_if_statement", "start_pos" : {"line" : "3", "column":"7"}, "condition" : {"tag" : "logical_expression", "expression" : {"tag" : "logical_factor", "negated" : "false", "expression" : {"tag" : "logical_primary", "expression" : {"tag" : "binary_expression", "lhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"11"}, "name":"I"}, "operator" : ".LT.", "rhs" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"18"}, "name":"J"}}}}}, "then_statements" : [], "else_block" : {"statement_list" : [], "end_if" : {"tag" : "end_if", "start_pos" : {"line" : "4", "column":"7"}}}}]}] }'.


	prog := programFile progUnits first.
	self assert: prog accesses size equals: 2.
	self
		assertCollection:
		(prog accesses collect: [ :each | each entityName ])
		hasSameElements: #( i j )
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testReturnConstantStatement [
	"
      integer function hello()
      hello = 42
      return
      end
"

	| programFile fct |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"24"}, "name":"HELLO"}, "prog_unit_parameters" : [], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "5", "column":"9"}, "statement_list" : [{"tag" : "assignment_statement", "start_pos" : {"line" : "3", "column":"7"}, "left" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"7"}, "name":"HELLO"}], "right" : [{"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"15"}, "value":"42"}}]}, {"tag" : "return_statement", "start_pos" : {"line" : "4", "column":"7"}}]}] }'.

	self assert: programFile progUnits size equals: 1.

	fct := programFile progUnits first.
	self assert: fct body isEmpty
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testReturnStatement [
	"
      integer function hello()
      return
      end
"

	| programFile fct |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "function", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"24"}, "name":"HELLO"}, "prog_unit_parameters" : [], "return_type" : {"tag" : "type_reference", "name":"INTEGER"}, "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "return_statement", "start_pos" : {"line" : "3", "column":"7"}}]}] }'.

	self assert: programFile progUnits size equals: 1.

	fct := programFile progUnits first.
	self assert: fct body first class equals: IASTVarAccess.
	self assert: fct body first entityName equals: 'somevar'
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testSegactCommand [
	"
      subroutine hello
c@_   segact, lb
      end
"

	| programFile seg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c@_   segact, lb\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segact'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 7.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 17
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testSegadjCommand [
	"
      subroutine hello
c@_   segadj,lb
      end
"

	| programFile seg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c@_   segadj,lb\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segadj'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 7.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 16
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testSeginiCommand [
	"
      subroutine hello
c@_   segini,lb
      end
"

	| programFile seg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c@_   segini,lb\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segini'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 7.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 16
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testSegmentDeclarationEmpty [
	"
      subroutine hello
c@_   segment,user
c@_   end segment
      end
"

	| programFile seg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c@_   segment,user\nc@_   end segment\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "5", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegment.
	self assert: seg entityName equals: 'user'.
	self assert: seg declarations size equals: 0.

	self assert: seg sourceAnchor isNotNil.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 7.
	self assert: seg sourceAnchor endLine equals: 3.
	self assert: seg sourceAnchor endColumn equals: 18
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testSegmentDeclarationWithContent [
	"
      subroutine hello
c@_   segment, user
        character*40 uname
        integer uid, age
c@_   end segment
      end
"

	| programFile seg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c@_   segment, user\n", "6":"c@_   end segment\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "7", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "4", "column":"9"}, "type" : {"tag" : "type_reference", "name" : "CHARACTER", "len_specification" : {"tag" : "nonzero_unsigned_int_constant", "start_pos" : {"line" : "4", "column":"19"}, "value":"40"}}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "4", "column":"19"}, "name":"UNAME"}, "dimension_declarators" : []}]}, {"tag" : "variable_declaration_statement", "start_pos" : {"line" : "5", "column":"9"}, "type" : {"tag" : "type_reference", "name":"INTEGER"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "5", "column":"17"}, "name":"UID"}, "dimension_declarators" : []},{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "5", "column":"22"}, "name":"AGE"}, "dimension_declarators" : []}]}]}] }'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegment.
	self assert: seg entityName equals: 'user'.
	self assert: seg declarations size equals: 3.

	self assert: seg declarations first entityName equals: 'uname'.
	self assert: seg declarations second entityName equals: 'uid'.
	self assert: seg declarations third entityName equals: 'age'
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testSegsupCommand [
	"
      subroutine hello
c@_   segsup, lb
      end
"

	| programFile seg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "3":"c@_   segsup, lb\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : []}] }'.


	self assert: programFile progUnits first body size equals: 1.
	seg := programFile progUnits first body first.

	self assert: seg class equals: IASTEsopeSegCommand.
	self assert: seg entityName equals: 'lb'.
	self assert: seg esopeCommand equals: 'segsup'.
	self assert: seg sourceAnchor class equals: IASTIndexedFileAnchor.
	self assert: seg sourceAnchor startLine equals: 2.
	self assert: seg sourceAnchor startColumn equals: 7.
	self assert: seg sourceAnchor endLine equals: 2.
	self assert: seg sourceAnchor endColumn equals: 17
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testSpecialSubroutine [
	"
      subroutine __$__
      integer l
c@_   segment point
      real abs, ord
      character*(l) label
c@_   end segment
      end
"

	| programFile entity dummySub segment |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { "4":"c@_   segment point\n", "7":"c@_   end segment\n" }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"__$__"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "8", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "3", "column":"7"}, "type" : {"tag" : "type_reference", "name":"INTEGER"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"L"}, "dimension_declarators" : []}]}, {"tag" : "variable_declaration_statement", "start_pos" : {"line" : "5", "column":"7"}, "type" : {"tag" : "type_reference", "name":"REAL"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "5", "column":"12"}, "name":"ABS"}, "dimension_declarators" : []},{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "5", "column":"17"}, "name":"ORD"}, "dimension_declarators" : []}]}, {"tag" : "variable_declaration_statement", "start_pos" : {"line" : "6", "column":"7"}, "type" : {"tag" : "type_reference", "name" : "CHARACTER", "len_specification" : {"tag" : "variable_expression", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "6", "column":"18"}, "name":"L"}}}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "6", "column":"21"}, "name":"LABEL"}, "dimension_declarators" : []}]}]}] }'.


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
SyntaxJsonToIASTVisitorTest >> testStringVariableDeclaration [
	"
      subroutine hello
      character*8 str
      end
"

	| programFile var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "3", "column":"7"}, "type" : {"tag" : "type_reference", "name" : "CHARACTER", "len_specification" : {"tag" : "nonzero_unsigned_int_constant", "start_pos" : {"line" : "3", "column":"17"}, "value":"8"}}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"STR"}, "dimension_declarators" : []}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 1.

	var := programFile progUnits first body first first.
	self assert: var class equals: IASTVariable.
	self assert: var entityName equals: 'str'.
	self assert: var typeSpec class equals: IASTTypeRef.
	self assert: var typeSpec entityName equals: 'character'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testSubroutineInvocation [
	"
      subroutine hello
      call someSubRoutine
      end
"

	| programFile stmt |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "call_statement", "start_pos" : {"line" : "3", "column":"7"}, "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"12"}, "name":"SOMESUBROUTINE"}, "arguments" : []}]}] }'.


	self assert: programFile progUnits first body size equals: 1.

	stmt := programFile progUnits first body first.
	self assert: stmt class equals: IASTInvocation.
	self assert: stmt entityName equals: 'somesubroutine'.
	self assert: stmt arguments size equals: 0
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testSubroutineInvocationWithArguments [
	"
      subroutine hello
      call someSubRoutine(bar,5,baz)
      end
"

	| programFile stmt arg |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "call_statement", "start_pos" : {"line" : "3", "column":"7"}, "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"12"}, "name":"SOMESUBROUTINE"}, "arguments" : [{"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"27"}, "name":"BAR"}, {"tag" : "arithmetic_expression", "expression" : {"tag" : "unsigned_int_constant", "start_pos" : {"line" : "3", "column":"31"}, "value":"5"}}, {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"33"}, "name":"BAZ"}]}]}] }'.


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
	self assert: arg entityName equals: 'baz'
]

{ #category : #'tests-statement' }
SyntaxJsonToIASTVisitorTest >> testTwoIntegerVariableDeclarations [
	"
      subroutine hello
      integer i,j
      end
"

	| programFile var |
	programFile := self visitJsonCode:
		               '{ "tag":"fortran_file", "comments": { }, "file" : "./fortranCode.F", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"HELLO"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "variable_declaration_statement", "start_pos" : {"line" : "3", "column":"7"}, "type" : {"tag" : "type_reference", "name":"INTEGER"}, "declarators" : [{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"15"}, "name":"I"}, "dimension_declarators" : []},{"tag" : "variable_declarator", "variable" : {"tag" : "symbolic_name", "start_pos" : {"line" : "3", "column":"17"}, "name":"J"}, "dimension_declarators" : []}]}]}] }'.


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
	self assert: var typeSpec entityName equals: 'integer'
]

{ #category : #'tests-esope' }
SyntaxJsonToIASTVisitorTest >> testWriteStatementWithStringArgument [
	"
      subroutine print
       write(*,*) 'hello'      
      end	
	"

	| programFile stmt |
	programFile := self visitJsonCode:
		               ' end |^ ./fortranCode.F, line 4: column 10: Warning:	A tabulation character is illegal outside comments or character constants. In this executable program, each such tabulation character is changed into one space. { "tag":"fortran_file", "comments": { }, "file" : "/home/anquetil/Pharo/images/fortran/FastTmp/tmpFASTSource.f", "program_units" : [{"tag" : "subroutine", "name" : {"tag" : "symbolic_name", "start_pos" : {"line" : "2", "column":"18"}, "name":"PRINT"}, "prog_unit_parameters" : [], "start_pos" : {"line" : "2", "column":"7"}, "end_pos" : {"line" : "4", "column":"9"}, "statement_list" : [{"tag" : "write_statement", "start_pos" : {"line" : "3", "column":"8"}, "control_info_list" : [{"asterisk":"*"},{"asterisk":"*"}], "io_list" : [{"tag" : "character_expression", "expression" : {"tag" : "character_constant", "start_pos" : {"line" : "3", "column":"19"}, "value":"''hello''"}}]}]}] }'.


	self assert: programFile progUnits first body first size equals: 1.
	stmt := programFile progUnits first body first first.
	self assert: stmt class equals: IASTInvocation.
	self assert: stmt entityName equals: 'write'.
	self assert: stmt arguments size equals: 0
]

{ #category : #running }
SyntaxJsonToIASTVisitorTest >> visitJsonCode: jsonCode [
	| visitor |
	visitor := SyntaxJsonToIASTVisitor new.
	^visitor onFile: (NeoJSONReader fromString: jsonCode)
]
