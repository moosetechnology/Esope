Class {
	#name : 'EsopeToFASTTests',
	#superclass : 'AbstractJsonToFASTTests',
	#category : 'FAST-Esope-Visitors-Tests',
	#package : 'FAST-Esope-Visitors-Tests'
}

{ #category : 'running' }
EsopeToFASTTests >> jsonVisitor [
	^FASTEsopeJsonVisitor
]

{ #category : 'tests' }
EsopeToFASTTests >> testSegment [

	| result seg declaration declarator |
	fortranCode := '      subroutine hello
c@_   segment, foo
        integer bar
c@_   end segment
      end
'.

	jsonCode :=  '{"meta":{"miVersion":"fortran77","miFilename":"/Users/sow/Documents/Pharo/images/M12_241203_PairYC/srcCode.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_   segment, foo","span":"(2:1)-(2:18)","tag":"comment"},{"anno":[],"label":null,"span":"(3:9)-(3:19)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(3:17)-(3:19)","type":"scalar","variable":{"anno":[],"span":"(3:17)-(3:19)","tag":"value","value":{"contents":"bar","tag":"variable"}}}],"span":"(3:17)-(3:19)"},"span":"(3:9)-(3:19)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(3:9)-(3:15)"}},"tag":"statement"},{"anno":[],"comment":"@_   end segment","span":"(4:1)-(4:17)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(5:9)","subprograms":null,"tag":"subroutine"}]}'.

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
