Class {
	#name : #EsopeRewriterTest,
	#superclass : #PP2CompositeNodeTest,
	#instVars : [
		'sixSpaces'
	],
	#category : #'EsopeImporter-Tests-Rewriter'
}

{ #category : #accessing }
EsopeRewriterTest >> parserClass [
	^ PPEsopeRewriter 
]

{ #category : #running }
EsopeRewriterTest >> setUp [

	super setUp.
	parser initStream.
	sixSpaces := '      '
]

{ #category : #tests }
EsopeRewriterTest >> testEsoArImplicit [

	self assert: (parser applyTransformation: 'a(b)') equals: 'a(b)'
]

{ #category : #tests }
EsopeRewriterTest >> testEsoSlImplicit [

	self assert: (parser applyTransformation: 'a(/b)') equals: 'S__(a,b)'
]

{ #category : #'tests-transformation' }
EsopeRewriterTest >> testEsopeDotTransformationInsideInvocationOrArraySubscript [

	| actualSource expectedSource |
	self skip.
	self flag: #TODO. "The regex we're using treats everything inside the outer parentheses as an index and therefore doesn't apply a transformation to it.
	So it won't work for examples like this. 
	Make sure you test (#testEsopeTransformationInsideInvocationOrArraySubscript) and add other situations to cover special cases that may arise."

	actualSource := '      bk = lb.bref(ur.ubb(ibor))'.
	expectedSource := '      bk = D__(lb,bref(D__(ur,ubb(ibor))))'.
	self
		assert: (parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterTest >> testEsopeSlashTransformationInsideInvocationOrArraySubscript [

	| actualSource expectedSource |
	self skip.
	self flag: #TODO. "The regex we're using treats everything inside the outer parentheses as an index and therefore doesn't apply a transformation to it.
	So it won't work for examples like this. 
	Make sure you test (#testEsopeTransformationInsideInvocationOrArraySubscript) and add other situations to cover special cases that may arise."

	actualSource := '      bk = lb.bref(ur.ubb(/ibor))'.
	expectedSource := '      bk = D__(lb,bref(S__(D__(ur,ubb),ibor)))'.
	self
		assert: (parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #tests }
EsopeRewriterTest >> testFortranLine [

	| sourcecode |
	sourcecode := sixSpaces , 'subroutine test(brr)
'.
	self parse: sourcecode rule: #fortranLine.

	self assert: parser generatedCode equals: sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testFortranLineEsoAt [

	self
		parse: sixSpaces , 'rlist.ilist=0
'
		rule: #fortranLine.
	self assert: parser generatedCode equals: '      D__(rlist,ilist)=0
'
]

{ #category : #tests }
EsopeRewriterTest >> testFortranLineEsoSlash [

	self
		parse: '        lxs=xs.cstg(/1)
'
		rule: #fortranLine.
	self assert: parser generatedCode equals: '        lxs=S__(D__(xs,cstg),1)
'
]

{ #category : #tests }
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

{ #category : #'tests-todo' }
EsopeRewriterTest >> testFortranLineStartWithTab [
	| sourcecode |
	sourcecode := String tab , '   call procedure
'.
	self parse: sourcecode rule: #fortranLine.

	self assert: parser generatedCode equals: '           call procedure
'
]

{ #category : #tests }
EsopeRewriterTest >> testNoTranslateFormat [

	| sourcecode |
	sourcecode := ' 6000    FORMAT(/,1X,''text'',A)', String lf.

	self parse: sourcecode rule: #fortranLine.
	self
		assert: parser generatedCode
		equals:  sourcecode 
]

{ #category : #tests }
EsopeRewriterTest >> testPointer [

	| sourcecode |
	sourcecode := 'pointeur splist.list
'.
	self parse: sixSpaces , sourcecode rule: #pointer.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testPointerWithSpaces [

	| sourcecode |
	sourcecode := '   pointeur t1.mytab    
'.
	self parse: '      ' , sourcecode rule: #pointer.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testPointers [

	| sourcecode |
	sourcecode := 'pointeur splist.list,p.q,r.s
'.
	self parse: sixSpaces , sourcecode rule: #pointer.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegact [

	| sourcecode |
	sourcecode := 'segact,splist
'.
	self parse: sixSpaces , sourcecode rule: #segact.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegactWithSpaces [

	| sourcecode |
	sourcecode := '  segact,xs
'.
	self parse: sixSpaces , sourcecode rule: #segact.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegadj [

	| sourcecode |
	sourcecode := 'segadj,aplist
'.
	self parse: sixSpaces , sourcecode rule: #segadj.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
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
	self parse: inputCode rule: #segment.
	self assert: parser generatedCode equals: rewriterdCode
]

{ #category : #tests }
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
	self parse: inputCode rule: #segment.
	self assert: parser generatedCode equals: rewriterdCode
]

{ #category : #tests }
EsopeRewriterTest >> testSegdes [

	| sourcecode |
	sourcecode := 'segdes,alist
'.
	self parse: sixSpaces , sourcecode rule: #segdes.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegini [

	| sourcecode |
	sourcecode := 'segini,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segini.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegment [

	| finalcode sourcecode |
	sourcecode := '      segment,values
        character*8        valtyp
        real               valf(valnf)
        integer            vale(valne)
      endsegment
'.
	finalcode := 'c@_   segment,values
        character*8        valtyp
        real               valf(valnf)
        integer            vale(valne)
c@_   endsegment
'.
	self parse: sourcecode rule: #segment.
	self assert: parser generatedCode equals: finalcode
]

{ #category : #'tests-todo' }
EsopeRewriterTest >> testSegmentArcopySaphtool [
	| actualSource expectedSource |
	self skip.
	self flag: #TODO. 

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
	self parse: actualSource rule: #segment.
	self assert: parser generatedCode equals: expectedSource.
]

{ #category : #'tests-todo' }
EsopeRewriterTest >> testSegmentSimpleWithMoreThanSixSpaces [
	| actualSource expectedSource |
	self skip.
	self flag: #TODO. 
	"When we have more than sixSpace, the test for segment fails:
	- it seems related to end of the segment definition
	- 
	"
	actualSource := '       segment, user
        character*40 uname
        integer ubb(ubbcnt)
       end segment
'.
	expectedSource := 'c@_    segment, user
        character*40 uname
        integer ubb(ubbcnt)
c@_   end segment
'.
	self parse: actualSource rule: #segment.
	self assert: parser output equals: expectedSource.
]

{ #category : #tests }
EsopeRewriterTest >> testSegprt [

	| sourcecode |
	sourcecode := 'segprt,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segprt.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegsup [

	| sourcecode |
	sourcecode := 'segsup,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segsup.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArray [

	self
		assert: (parser applyTransformation: 'ab.cd(ef)')
		equals: 'D__(ab,cd(ef))'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayAndEsopeAtWithExpressionAsSubscript [

	self
		assert: (parser applyTransformation: 'ur.ubb(jr + 1)')
		equals: 'D__(ur,ubb(jr + 1))'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayAsFunctionStatement [

	self
		assert: (parser applyTransformation: 'ur.ubb(jr) = ur.ubb(jr + 1)')
		equals: 'D__(ur,ubb(jr)) = D__(ur,ubb(jr + 1))'
]

{ #category : #'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeArrayDotInsidePar [

	self skip.
	self
		assert: (parser applyTransformation: 'rlist.elist(rlist.ilist)=ms')
		equals: 'D__(rlist,elist(D__(rlist,ilist)))=ms'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayNew [

	self
		assert: (parser applyTransformation: 'ab.cd')
		equals: 'D__(ab,cd)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayNewWithSubscript [

	self
		assert: (parser applyTransformation: 'ab.cd(i, j+1)')
		equals: 'D__(ab,cd(i, j+1))'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayRelbk [

	self
		assert: (parser applyTransformation: 'ur.ubb(jr) = ur.ubb(jr + 1)')
		equals: 'D__(ur,ubb(jr)) = D__(ur,ubb(jr + 1))'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayWithExpression [

	self
		assert: (parser applyTransformation: 'ur.ubb(jr + 1)')
		equals: 'D__(ur,ubb(jr + 1))'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtBinaryOperator [

	self
		assert: (parser applyTransformation: '         if(lxs.eq.0)then')
		equals: '         if(lxs.eq.0)then'.
	self
		assert: (parser applyTransformation:
				 '              if((rlist.ilist).gt.nlist)then')
		equals: '              if((D__(rlist,ilist)).gt.nlist)then'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtEqOperator [

	self
		assert: (parser applyTransformation: '         if(lxs.eq.0)then')
		equals: '         if(lxs.eq.0)then'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtNoDot [

	self assert: (parser applyTransformation: 'abc') equals: 'abc'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtOneDot [
	self
		assert: (parser applyTransformation: 'abc.def')
		equals: 'D__(abc,def)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtTwoDots [

	self
		assert: (parser applyTransformation: 'abc.def=opq.xyz')
		equals: 'D__(abc,def)=D__(opq,xyz)'
]

{ #category : #'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeIFLogical [

	| sourcecode |
	self skip.
	
	sourcecode := 'if(e) segadj, p
'.
	self parse: sixSpaces , sourcecode rule: #segact.
	self assert: parser generatedCode equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeNotDot [

	self skip.

	self
		assert: (parser applyTransformation: '      A=.NOT.B ')
		equals: '      A=.NOT.B '
]

{ #category : #'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeSlash10 [

	| sourcecode |
	self skip.

	sourcecode := sixSpaces , '   A = B ( /1 )
'.
	self parse: sourcecode rule: #fortranLine.
	self assert: parser generatedCode equals: sixSpaces , '   A = S__(B,1)
'
]

{ #category : #'tests-todo' }
EsopeRewriterTest >> testTranslateEsopeSlash20 [

	| sourcecode |
	self skip.

	sourcecode := sixSpaces , '   A = B ( /1 )
'.
	self parse: sourcecode rule: #fortranLine.
	self assert: parser generatedCode equals: sixSpaces , '   A = S__(B,1)
'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashEsopeAt [

	self
		assert: (parser applyTransformation: 'abc.def(/1)')
		equals: 'S__(D__(abc,def),1)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashNone [

	self
		assert: (parser slashTransformation: 'abc.def')
		equals: 'abc.def'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashOne [

	self
		assert: (parser slashTransformation: 'abc.def(/1)')
		equals: 'S__(D__(abc,def),1)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashSlash [

	self
		assert: (parser slashTransformation:
				 'C     //fin repeter "decouper chaque chaine"')
		equals: 'C     //fin repeter "decouper chaque chaine"'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashWithSpacesBeforeLeftPar [

	self
		assert: (parser slashTransformation: 'tab (/1)')
		equals: 'S__(tab,1)'
]
