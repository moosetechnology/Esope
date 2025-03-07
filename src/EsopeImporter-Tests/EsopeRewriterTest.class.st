Class {
	#name : 'EsopeRewriterTest',
	#superclass : 'PP2CompositeNodeTest',
	#instVars : [
		'sixSpaces'
	],
	#category : 'EsopeImporter-Tests-Rewriter',
	#package : 'EsopeImporter-Tests',
	#tag : 'Rewriter'
}

{ #category : 'accessing' }
EsopeRewriterTest >> parserClass [
	^ PPEsopeRewriter 
]

{ #category : 'running' }
EsopeRewriterTest >> setUp [

	super setUp.
	parser initStream.
	sixSpaces := '      '
]

{ #category : 'tests' }
EsopeRewriterTest >> testCommentLine [

	| sourcecode |
	sourcecode := 'c       subroutine test(/brr)
'.
	self parse: sourcecode rule: #commentLine.

	self assert: parser generatedCode equals: sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testCommentLineWithStar [

	| sourcecode |
	sourcecode := '*: end of nothing
'.
	self parse: sourcecode rule: #commentLine.

	self assert: parser generatedCode equals: sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testEsoArImplicit [

	self assert: (parser applyTransformation: 'a(b)') equals: 'a(b)'
]

{ #category : 'tests' }
EsopeRewriterTest >> testEsoSlImplicit [
	| code |
	code := String tab , 'a(/b)', String lf.
	
	self parse: code rule: #fortranLine.
	self assert: parser generatedCode equals: '        a(S__/b)', String lf.
]

{ #category : 'tests-transformation' }
EsopeRewriterTest >> testEsopeDotTransformationInsideInvocationOrArraySubscript [

	| actualSource expectedSource |

	actualSource := '      bk = lb.bref(/ur.ubb(/ibor))'.
	expectedSource := '      bk = lb.bref(S__/ur.ubb(S__/ibor))'.
	self
		assert: (parser applySlashTransformation: actualSource)
		equals: expectedSource
]

{ #category : 'tests' }
EsopeRewriterTest >> testEsopeLineWithLabel [

	| actualSource expectedSource |
	actualSource := '40    SEGINI,P
'.
	expectedSource := 'c@_40 SEGINI,P
'.

	self parse: actualSource rule: #segini.
	self assert: parser generatedCode equals: expectedSource.

]

{ #category : 'tests-transformation' }
EsopeRewriterTest >> testEsopeSlashTransformationInsideInvocationOrArraySubscript [

	| actualSource expectedSource |

	actualSource := '      bk = lb.bref(ur.ubb(/ibor))'.
	expectedSource := '      bk = lb.bref(ur.ubb(S__/ibor))'.
	self
		assert: (parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : 'tests' }
EsopeRewriterTest >> testFortranLine [

	| sourcecode |
	sourcecode := sixSpaces , 'subroutine test(brr)
'.
	self parse: sourcecode rule: #anyLine.

	self assert: parser generatedCode equals: sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testFortranLineEsoAt [

	self parse: sixSpaces , 'rlist.ilist=0', String lf rule: #fortranLine.
	self assert: parser generatedCode equals: sixSpaces , 'rlist.ilist=0', String lf.
]

{ #category : 'tests' }
EsopeRewriterTest >> testFortranLineEsoSlash [

	self parse: '        lxs=xs.cstg(/1)', String lf rule: #fortranLine.
	self assert: parser generatedCode equals: '        lxs=xs.cstg(S__/1)', String lf
]

{ #category : 'tests' }
EsopeRewriterTest >> testFortranLineNoEsoAt [

	self
		parse:
			sixSpaces , 'call newbook(lib,''le petit chaperon rouge'',10,2.12)
'
		rule: #fortranLine.
	self
		assert: parser generatedCode
		equals:
			'      call newbook(lib,''le petit chaperon rouge'',10,2.12)
'
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testFortranLineStartWithTab [
	| sourcecode |
	sourcecode := String tab , '   call procedure', String lf.

	self parse: sourcecode rule: #fortranLine.
	self assert: parser generatedCode equals: '           call procedure', String lf.
]

{ #category : 'tests' }
EsopeRewriterTest >> testNoEndOfLine [

	| sourcecode |
	sourcecode := '      function toto
      end'.
	self parse: sourcecode.

	self assert: parser generatedCode equals: sourcecode , OSPlatform current lineEnding
]

{ #category : 'tests' }
EsopeRewriterTest >> testNoTranslateFormat [

	| sourcecode |
	sourcecode := ' 6000    FORMAT(/,1X,''text'',A)', String lf.

	self parse: sourcecode rule: #fortranLine.
	self
		assert: parser generatedCode
		equals:  sourcecode 
]

{ #category : 'tests' }
EsopeRewriterTest >> testPointer [

	| sourcecode |
	sourcecode := 'pointeur splist.list
'.
	self parse: sixSpaces , sourcecode rule: #pointer.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testPointerWithSpaces [

	| sourcecode |
	sourcecode := '   pointeur t1.mytab    
'.
	self parse: '      ' , sourcecode rule: #pointer.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testPointers [

	| sourcecode |
	sourcecode := 'pointeur splist.list,p.q,r.s
'.
	self parse: sixSpaces , sourcecode rule: #pointer.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegact [

	| sourcecode |
	sourcecode := 'segact,splist
'.
	self parse: sixSpaces , sourcecode rule: #segact.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegactWithSpaces [

	| sourcecode |
	sourcecode := '  segact,xs
'.
	self parse: sixSpaces , sourcecode rule: #segact.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegadj [

	| sourcecode |
	sourcecode := 'segadj,aplist
'.
	self parse: sixSpaces , sourcecode rule: #segadj.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegdefFromBorbk [

	| rewriterdCode inputCode |
	inputCode := '      SEGMENT , pstr
        character*8 nomcod, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,        pntseg(nbseg), pntref(nbref)
      endsegment
'.
	rewriterdCode := 'c@_   SEGMENT , pstr
        character*8 nomcod, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,        pntseg(nbseg), pntref(nbref)
c@_   endsegment
'.
	self parse: inputCode.
	self assert: parser generatedCode equals: rewriterdCode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegdefUpperCase [

	| rewriterdCode inputCode |
	inputCode := '      SEGMENT , PSTR
        character*8 nomcod, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,        pntseg(nbseg), pntref(nbref)
      endsegment
'.
	rewriterdCode := 'c@_   SEGMENT , PSTR
        character*8 nomcod, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,        pntseg(nbseg), pntref(nbref)
c@_   endsegment
'.
	self parse: inputCode.
	self assert: parser generatedCode equals: rewriterdCode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegdes [

	| sourcecode |
	sourcecode := 'segdes,alist
'.
	self parse: sixSpaces , sourcecode rule: #segdes.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegini [

	| sourcecode |
	sourcecode := 'segini,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segini.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegment [

	| finalcode sourcecode |
	sourcecode := '      segment,values
'.
	finalcode := 'c@_   segment,values
'.
	self parse: sourcecode rule: #segment.
	self assert: parser generatedCode equals: finalcode
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testSegmentArcopySaphtool [
	| actualSource expectedSource |

	actualSource := '      SEGMENT TEMPNO
*: comment
         INTEGER      INDSAU
      ENDSEGMENT
'.
	expectedSource := 'c@_   SEGMENT TEMPNO
*: comment
         INTEGER      INDSAU
c@_   ENDSEGMENT
'.
	self parse: actualSource rule: #start.
	self assert: parser generatedCode equals: expectedSource.
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testSegmentSimpleWithMoreThanSixSpaces [
	| actualSource expectedSource |

	actualSource := '       segment, user
        character*40 uname
        integer ubb(ubbcnt)
        end segment
'.
	expectedSource := 'c@_    segment, user
        character*40 uname
        integer ubb(ubbcnt)
c@_     end segment
'.
	self parse: actualSource.
	self assert: parser generatedCode equals: expectedSource.
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegprt [

	| sourcecode |
	sourcecode := 'segprt,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segprt.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testSegsup [

	| sourcecode |
	sourcecode := 'segsup,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segsup.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeArray [

	
	self parse: sixSpaces, 'ab.cd(ef)', String lf rule: #fortranLine.
	
	self assert: parser generatedCode equals: sixSpaces , 'ab.cd(ef)', String lf
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeArrayAndEsopeAtWithExpressionAsSubscript [

	self
		assert: (parser applySlashTransformation: 'ur.ubb(/jr + 1)')
		equals: 'ur.ubb(S__/jr + 1)'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeArrayAsFunctionStatement [

	self
		assert: (parser applySlashTransformation: 'ur.ubb(//jr) = ur.ubb(/jr + 1)')
		equals: 'ur.ubb(//jr) = ur.ubb(S__/jr + 1)'
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeArrayDotInsidePar [

	| code |

	code := sixSpaces, 'rlist.elist(rlist.ilist)=ms', String lf.
	self parse: code rule: #fortranLine.
	self
		assert: parser generatedCode equals: code
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeArrayNew [

	self
		assert: (parser applySlashTransformation: 'ab.cd')
		equals: 'ab.cd'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeArrayNewWithSubscript [

	self
		assert: (parser applySlashTransformation: 'ab.cd(i, j+1)')
		equals: 'ab.cd(i, j+1)'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeArrayRelbk [

	self
		assert: (parser applySlashTransformation: 'ur.ubb(jr) = ur.ubb(jr + 1)')
		equals: 'ur.ubb(jr) = ur.ubb(jr + 1)'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeArrayWithExpression [

	self
		assert: (parser applySlashTransformation: 'ur.ubb(/jr/1)')
		equals: 'ur.ubb(S__/jr/1)'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeAtBinaryOperator [

	self
		assert: (parser applySlashTransformation: '         if(lxs.eq.0)then')
		equals: '         if(lxs.eq.0)then'.
	self
		assert: (parser applySlashTransformation:
				 '              if((rlist.ilist).gt.nlist)then')
		equals: '              if((rlist.ilist).gt.nlist)then'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeAtEqOperator [

	self
		assert: (parser applyTransformation: '         if(lxs.eq.0)then')
		equals: '         if(lxs.eq.0)then'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeAtNoDot [

	self assert: (parser applyTransformation: 'abc') equals: 'abc'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeAtOneDot [
	self
		assert: (parser applySlashTransformation: 'abc.def')
		equals: 'abc.def'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeAtTwoDots [

	self
		assert: (parser applySlashTransformation: 'abc.def=opq.xyz')
		equals: 'abc.def=opq.xyz'
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeIFLogical [

	| sourcecode |
	
	sourcecode := 'if(e) segadj, p
'.
	self parse: sixSpaces , sourcecode rule: #fortranLine.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeIFLogicalWithLineContinuation [

	| sourcecode |
	self skip.
	
	sourcecode := 'if(e)
     * segadj p
'.
	self parse: sixSpaces , sourcecode.
	self assert: parser generatedCode equals: '      ' , sourcecode
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeIFLogicalWithSlash [

	| sourcecode |
	self skip.
	
	sourcecode := 'if(e1(/e2)) segadj, p
'.
	self parse: sixSpaces , sourcecode rule: #fortranLine.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeMultipleSlashes [

	self parse: sixSpaces, 'abc.def(/def.xyz)=opq.xyz(/abc.def)', String lf rule: #fortranLine.
	
	self assert: parser generatedCode equals: sixSpaces, 'abc.def(S__/def.xyz)=opq.xyz(S__/abc.def)', String lf
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeNotDot [

	self
		assert: (parser applySlashTransformation: '      A=.NOT.B ')
		equals: '      A=.NOT.B '
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeSlash10 [

	| sourcecode |
	self skip.

	sourcecode := sixSpaces , '   A = B ( /1 )' , String lf.
	self parse: sourcecode rule: #fortranLine.
	self assert: parser generatedCode equals: sixSpaces , '   A = B ( S__/1 )' , String lf
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeSlash20 [

	| sourcecode |

	self skip.
	
	
	sourcecode := sixSpaces , '   A = B ( /1 )', String lf.
	self parse: sourcecode rule: #fortranLine.
	self assert: parser generatedCode equals: sixSpaces , '   A = B ( S__/1 )', String lf
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeSlashEsopeAt [

	self parse: sixSpaces, 'abc.def(/1)', String lf rule: #fortranLine.

	self
		assert: parser generatedCode
		equals: sixSpaces, 'abc.def(S__/1)', String lf
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeSlashNone [

	self
		assert: (parser slashTransformation: 'abc.def')
		equals: 'abc.def'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeSlashOne [

	self
		assert: (parser slashTransformation: 'abc.def(/1)')
		equals: 'S__(D__(abc,def),1)'
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeSlashSlash [

	self
		assert: (parser slashTransformation:
				 'C     //fin repeter "decouper chaque chaine"')
		equals: 'C     //fin repeter "decouper chaque chaine"'
]

{ #category : 'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeSlashWithDotInsidePar [

	| code |

	code := 'rlist.elist(/rlist.ilist)=ms'.
	self parse: sixSpaces , code , String lf rule: #fortranLine.
	self
		assert: parser generatedCode
		equals: sixSpaces , 'rlist.elist(S__/rlist.ilist)=ms' , String lf
]

{ #category : 'tests' }
EsopeRewriterTest >> testTranslateEsopeSlashWithSpacesBeforeLeftPar [

	self
		assert: (parser slashTransformation: 'tab (/1)')
		equals: 'S__(tab,1)'
]
