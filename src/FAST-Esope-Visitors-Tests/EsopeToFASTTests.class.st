Class {
	#name : 'EsopeToFASTTests',
	#superclass : 'AbstractJsonToFASTTests',
	#category : 'FAST-Esope-Visitors-Tests-Visitor',
	#package : 'FAST-Esope-Visitors-Tests',
	#tag : 'Visitor'
}

{ #category : 'running' }
EsopeToFASTTests >> jsonVisitor [
	^FASTEsopeJsonVisitor
]

{ #category : 'tests-expression' }
EsopeToFASTTests >> testDerefAccess [
	
	| result asnmt expr |
	fortranCode := '      PROGRAM MYPROG
       var = lb.att
      END
'.
	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"/home/anquetil/Pharo/images/FastFortran-parsing/srcCode.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:19)","statement":{"anno":[],"expression":{"anno":[],"expression":{"anno":[],"span":"(2:14)-(2:15)","tag":"value","value":{"contents":"lb","tag":"variable"}},"field":{"anno":[],"span":"(2:17)-(2:19)","tag":"value","value":{"contents":"att","tag":"variable"}},"span":"(2:14)-(2:19)","tag":"deref"},"span":"(2:8)-(2:19)","tag":"assign_expression","target":{"anno":[],"span":"(2:8)-(2:10)","tag":"value","value":{"contents":"var","tag":"variable"}}},"tag":"statement"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.
	result := self visitJsonCode.

	asnmt := result first statementBlock statements first.
	self assert: asnmt class equals: FASTFortranAssignmentStatement.

	expr := asnmt expression.
	self assert: expr class equals: FASTFortranFieldAccess.
	self assert: expr startPos equals: 35.

	self assert: expr pointer class equals: FASTFortranScalarVariable.
	self assert: expr pointer name equals: 'lb'.
	self assert: expr pointer startPos equals: 35.

	self assert: expr field class equals: FASTFortranScalarVariable.
	self assert: expr field name equals: 'att'.
	self assert: expr field startPos equals: 38

]

{ #category : 'tests-expression' }
EsopeToFASTTests >> testFortranComment [

	| result cmt |
	fortranCode := '      integer function aFct()
C comment in a function''s body
      end
'.
	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":" comment in a function''s body","span":"(2:1)-(2:30)","tag":"comment"}],"name":"afct","result":null,"span":"(1:7)-(3:9)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(1:7)-(1:13)"}}]}'.
	result := self visitJsonCode.

	cmt := result first statementBlock comments anyOne.
	self assert: cmt content equals: 'C comment in a function''s body'.
	self assert: cmt startPos equals: 31.
	self assert: cmt endPos equals: 60.
]

{ #category : 'tests-expression' }
EsopeToFASTTests >> testIncludeStatement [
	| cmd result |
	
	fortranCode := '      subroutine hello
c@_#include "file.inc"
      end
'.

	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"/Users/sow/Documents/Pharo/images/FAST-Esope-fix/srcCode.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_#include \"file.inc\"","span":"(2:1)-(2:22)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	result := self visitJsonCode.

	cmd := result first statementBlock statements first.
	self assert: cmd class equals: FASTEsopeCppIncludeStatement.
	self assert: cmd filename equals: 'file.inc'.
	self assert: cmd startPos equals: 28.
	self assert: cmd endPos equals: 45.
]

{ #category : 'tests-expression' }
EsopeToFASTTests >> testPointerOneDeclaration [
	| cmd result varDecl |
	
	fortranCode := '      subroutine hello
c@_   pointeur ptr1.seg1
      end
'.

	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"/Users/sow/Documents/Pharo/images/FAST-Esope-fix/srcCode.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   pointeur ptr1.seg1","span":"(2:1)-(2:24)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	result := self visitJsonCode.

	cmd := result first statementBlock statements first.
	self assert: cmd class equals: FASTEsopePointeurDeclarationStatement.
	self assert: cmd startPos equals: 30.
	self assert: cmd endPos equals: 47.

	self assert: cmd variableDeclarationStatements size equals: 1.

	varDecl := cmd variableDeclarationStatements first.

	self assert: varDecl declaredType class equals: FASTEsopePointerType.
	self assert: varDecl declaredType name equals: 'seg1'.
	self assert: varDecl declarators size equals: 1.
	self assert: varDecl declarators first class equals: FASTFortranVariableDeclarator.
	self assert: varDecl declarators first name equals: 'ptr1'.
]

{ #category : 'tests-expression' }
EsopeToFASTTests >> testSegactCommand [
	| cmd result |
	fortranCode := '      subroutine hello
c@_   segact, lb
      end
'.

	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"./fortran77.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segact, lb","span":"(2:1)-(2:16)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	result := self visitJsonCode.

	cmd := result first statementBlock statements first.
	self assert: cmd class equals: FASTEsopeSegact.

	self assert: cmd variables size equals: 1.
	self assert: cmd variables first name equals: 'lb'.
]

{ #category : 'tests' }
EsopeToFASTTests >> testSegadjCommand [
	
	| result cmd |
	fortranCode := '      PROGRAM MYPROG
C@_     segadj,pt
      END
'.
	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"comment":"@_     segadj,pt","span":"(2:1)-(2:17)","tag":"comment"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.
	result := self visitJsonCode.

	cmd := result first statementBlock statements first.
	self assert: cmd class equals: FASTEsopeSegadj.	
	self assert: cmd variables size equals: 1.
	self assert: cmd variables first name equals: 'pt'.
	self assert: cmd startPos equals: 30.
	self assert: cmd endPos equals: 38.
]

{ #category : 'tests' }
EsopeToFASTTests >> testSegdesCommand [
	
	| result stmt |
	fortranCode := '      PROGRAM MYPROG
C@_     segdes,pt
      END
'.
	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"comment":"@_     segdes,pt","span":"(2:1)-(2:17)","tag":"comment"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.
	result := self visitJsonCode.

	stmt := result first statementBlock statements first.
	self assert: stmt class equals: FASTEsopeSegdes.		
	self assert: stmt variables size equals: 1.
	self assert: stmt variables first name equals: 'pt'.
	self assert: stmt startPos equals: 30.
	self assert: stmt endPos equals: 38.
]

{ #category : 'tests' }
EsopeToFASTTests >> testSeginiCommand [
	
	| result cmd |
	fortranCode := '      PROGRAM MYPROG
C@_     segini,pt
      END
'.
	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"comment":"@_     segini,pt","span":"(2:1)-(2:17)","tag":"comment"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.
	result := self visitJsonCode.

	cmd := result first statementBlock statements first.
	self assert: cmd class equals: FASTEsopeSegini.		
	self assert: cmd variables size equals: 1.
	self assert: cmd variables first name equals: 'pt'.
	self assert: cmd startPos equals: 30.
	self assert: cmd endPos equals: 38.
]

{ #category : 'tests-expression' }
EsopeToFASTTests >> testSeginiCommandMultipleVariables [
	| cmd result |
	
	self skip: #TODO.

	fortranCode := '      subroutine hello
c@_   segini, lb1, lb2, lb3
      end
'.

	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"/home/anquetil/Pharo/images/fast-fortran/srcCode.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segini, lb1, lb2, lb3","span":"(2:1)-(2:27)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	result := self visitJsonCode.

	cmd := result first statementBlock statements first.
	self assert: cmd class equals: FASTEsopeSegini.

	self assert: cmd variables size equals: 3.
	self assert: cmd variables first name equals: 'lb1'.	
	self assert: cmd variables second name equals: 'lb2'.
	self assert: cmd variables third name equals: 'lb3'.
]

{ #category : 'tests' }
EsopeToFASTTests >> testSegmentEmpty [

	| result seg declaration |
	fortranCode := '      subroutine hello
c@_   segment, foo
c@_   end segment
      end
'.

	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"/Users/sow/Documents/Pharo/images/FAST-Esope-fix/srcCode.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segment, foo","span":"(2:1)-(2:18)","tag":"comment"},{"anno":[],"comment":"@_   end segment","span":"(3:1)-(3:17)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.

	result := self visitJsonCode.

	self assert: result first declarations size equals: 1.
	seg := result first declarations anyOne.
	
	self assert: seg class equals: FASTEsopeSegment.
	self assert: seg name equals: 'foo'.

	self assert: seg statements size equals: 0.
]

{ #category : 'tests' }
EsopeToFASTTests >> testSegmentWithDeclaration [

	| result seg declaration declarator |
	fortranCode := '      subroutine hello
c@_   segment, foo
        integer bar
c@_   end segment
      end
'.

	jsonCode := self fortranParser parseString: fortranCode.

	result := self visitJsonCode.

	self assert: result first declarations size equals: 1.
	seg := result first declarations anyOne.
	
	self assert: seg class equals: FASTEsopeSegment.
	self assert: seg name equals: 'foo'.

	self assert: seg statements size equals: 1.
	
	declaration := seg statements anyOne.
	self assert: declaration class equals: FASTFortranVariableDeclarationStatement.
	
	self assert: declaration declaredType class equals: FASTFortranIntegerType.
	
	
	self assert: declaration declarators size equals: 1.
	declarator := declaration declarators anyOne.
	self assert: declarator class equals: FASTFortranVariableDeclarator.
	self assert: declarator name equals: 'bar'
]

{ #category : 'tests-expression' }
EsopeToFASTTests >> testSegprtCommandNoComma [
	| cmd result |
	fortranCode := '      subroutine hello
c@_   segprt lb
      end
'.

	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"/home/anquetil/Pharo/images/fast-fortran/srcCode.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segprt lb","span":"(2:1)-(2:15)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	result := self visitJsonCode.

	cmd := result first statementBlock statements first.
	self assert: cmd class equals: FASTEsopeSegprt.

	self assert: cmd variables size equals: 1.
	self assert: cmd variables first name equals: 'lb'.
]

{ #category : 'tests' }
EsopeToFASTTests >> testSegsupCommand [
	
	| result cmd |
	fortranCode := '      PROGRAM MYPROG
C@_     segsup,pt
      END
'.
	jsonCode := '{"meta":{"miVersion":"fortran77","miFilename":"fortran77.f"},"program_units":[{"anno":[],"blocks":[{"anno":[],"comment":"@_     segsup,pt","span":"(2:1)-(2:17)","tag":"comment"}],"name":"myprog","span":"(1:7)-(3:9)","subprograms":null,"tag":"main"}]}'.
	result := self visitJsonCode.

	cmd := result first statementBlock statements first.
	self assert: cmd class equals: FASTEsopeSegsup.		
	self assert: cmd variables size equals: 1.
	self assert: cmd variables first name equals: 'pt'.
	self assert: cmd startPos equals: 30.
	self assert: cmd endPos equals: 38.
]