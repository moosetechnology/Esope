Class {
	#name : #EsopeRewriterTest,
	#superclass : #PP2CompositeNodeTest,
	#instVars : [
		'sixSpaces'
	],
	#category : #'Esope-Rewriter-Tests'
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

	self skip.
	self flag: #TODO. "Make the pointer followed by the dot prefix optional in the #slashTransformation: regex"
	self assert: (parser applyTransformation: 'a(/b)') equals: 'S__(a,b)'
]

{ #category : #tests }
EsopeRewriterTest >> testFortranLine [

	| sourcecode |
	sourcecode := sixSpaces , 'subroutine test(brr)
'.
	self parse: sourcecode rule: #fortranLine.

	self assert: parser output equals: sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testFortranLineEsoAt [

	self
		parse: sixSpaces , 'rlist.ilist=0
'
		rule: #fortranLine.
	self assert: parser output equals: '      D__(rlist,ilist)=0
'
]

{ #category : #tests }
EsopeRewriterTest >> testFortranLineEsoSlash [

	self
		parse: '        lxs=xs.cstg(/1)
'
		rule: #fortranLine.
	self assert: parser output equals: '        lxs=S__(D__(xs,cstg),1)
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
		assert: parser output
		equals:
			'      call newbook(lib,''le petit chaperon rouge'',10,2.12)
'
]

{ #category : #tests }
EsopeRewriterTest >> testPointer [

	| sourcecode |
	sourcecode := 'pointeur splist.list
'.
	self parse: sixSpaces , sourcecode rule: #pointer.
	self assert: parser output equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testPointerWithSpaces [

	| sourcecode |
	sourcecode := '   pointeur t1.mytab    
'.
	self parse: '      ' , sourcecode rule: #pointer.
	self assert: parser output equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegact [

	| sourcecode |
	sourcecode := 'segact,splist
'.
	self parse: sixSpaces , sourcecode rule: #segact.
	self assert: parser output equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegactWithSpaces [

	| sourcecode |
	sourcecode := '  segact,xs
'.
	self parse: sixSpaces , sourcecode rule: #segact.
	self assert: parser output equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegadj [

	| sourcecode |
	sourcecode := 'segadj,aplist
'.
	self parse: sixSpaces , sourcecode rule: #segadj.
	self assert: parser output equals: 'c@_   ' , sourcecode
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
	self assert: parser outputForSegment equals: rewriterdCode
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
	self assert: parser outputForSegment equals: rewriterdCode
]

{ #category : #tests }
EsopeRewriterTest >> testSegdes [

	| sourcecode |
	sourcecode := 'segdes,alist
'.
	self parse: sixSpaces , sourcecode rule: #segdes.
	self assert: parser output equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegini [

	| sourcecode |
	sourcecode := 'segini,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segini.
	self assert: parser output equals: 'c@_   ' , sourcecode
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
	self assert: parser outputForSegment equals: finalcode
]

{ #category : #tests }
EsopeRewriterTest >> testSegprt [

	| sourcecode |
	sourcecode := 'segprt,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segprt.
	self assert: parser output equals: 'c@_   ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegsup [

	| sourcecode |
	sourcecode := 'segsup,rlist
'.
	self parse: sixSpaces , sourcecode rule: #segsup.
	self assert: parser output equals: 'c@_   ' , sourcecode
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

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayDotInsidePar [

	self skip.
	self flag: #TODO. "Rethink the transformer (dot and slash) to handle correctly what is inside the parentheses"
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
