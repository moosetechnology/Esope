Class {
	#name : #EsopeRewriterTest,
	#superclass : #PP2CompositeNodeTest,
	#instVars : [
		'sixSpaces'
	],
	#category : #'Esope-Rewriter-Tests'
}

{ #category : #tests }
EsopeRewriterTest class >> esopeBigFile [
	^ EsopeGrammarTest esopeBigFile
]

{ #category : #tests }
EsopeRewriterTest class >> esopeSmallFile [
	^ EsopeGrammarTest esopeSmallFile
]

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
	
	self skip.
	self
		assert:
			(parser translateEsopeAt: (parser translateEsopeArray: 'a(b)'))
		equals: 'ESOar(a,b)'
]

{ #category : #tests }
EsopeRewriterTest >> testEsoSlImplicit [
	
	self skip.
	self
		assert:
			(parser translateEsopeSlash: 'a(/b)')
		equals: 'ESOsl(a,b)'
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
	self assert: parser output equals: '      ESOat(rlist,ilist)=0
'
]

{ #category : #tests }
EsopeRewriterTest >> testFortranLineEsoSlash [
	self
		parse:
			'        lxs=xs.cstg(/1)
'
		rule: #fortranLine.
	self
		assert: parser output
		equals:
			'        lxs=ESOsl(ESOat(xs,cstg),1)
'
]

{ #category : #tests }
EsopeRewriterTest >> testFortranLineNoEsoAt [

	self
		parse: sixSpaces , 'call newbook(lib,''le petit chaperon rouge'',10,2.12)
'
		rule: #fortranLine.
	self assert: parser output equals: '      call newbook(lib,''le petit chaperon rouge'',10,2.12)
'
]

{ #category : #tests }
EsopeRewriterTest >> testPointer [
	| sourcecode |
	sourcecode := 'pointeur splist.list
'.
	self parse: sixSpaces, sourcecode rule: #pointer.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testPointerWithSpaces [
	| sourcecode |
	sourcecode := '   pointeur t1.mytab    
'.
	self parse: '      ' , sourcecode rule: #pointer.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegact [
	| sourcecode |
	sourcecode := 'segact,splist
'.
	self parse: sixSpaces, sourcecode rule: #segact.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegactWithSpaces [
	| sourcecode |
	
	sourcecode := '  segact,xs
'.
	self parse: sixSpaces, sourcecode rule: #segact.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegadj [
	| sourcecode |
	sourcecode := 'segadj,aplist
'.
	self parse: sixSpaces, sourcecode rule: #segadj.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegdefFromBorbk [

	| rewriterdCode inputCode |
	inputCode := '      SEGMENT , pstr
        character*8 nomcod, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,        pntseg(nbseg), pntref(nbref)
      endsegment
'.
	rewriterdCode := 'cESO  SEGMENT , pstr
        character*8 nomcod, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,        pntseg(nbseg), pntref(nbref)
cESO  endsegment
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
	rewriterdCode := 'cESO  SEGMENT , PSTR
        character*8 nomcod, date, heure, typseg(nbseg), typref(nbref)
        integer     ibseg, ibref,        pntseg(nbseg), pntref(nbref)
cESO  endsegment
'.
	self parse: inputCode rule: #segment.
	self assert: parser outputForSegment equals: rewriterdCode
]

{ #category : #tests }
EsopeRewriterTest >> testSegdes [
	| sourcecode |
	sourcecode := 'segdes,alist
'.
	self parse: sixSpaces, sourcecode rule: #segdes.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testSegini [
	| sourcecode |
	sourcecode := 'segini,rlist
'.
	self parse: sixSpaces, sourcecode rule: #segini.
	self assert: parser output equals: 'cESO  ' , sourcecode
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
	finalcode := 'cESO  segment,values
        character*8        valtyp
        real               valf(valnf)
        integer            vale(valne)
cESO  endsegment
'.
	self parse: sourcecode rule: #segment.
	self assert: (parser outputForSegment) equals: finalcode.
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
	self parse: sixSpaces, sourcecode rule: #segsup.
	self assert: parser output equals: 'cESO  ' , sourcecode
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArray [
	self
		assert:
			(parser translateEsopeAt: (parser translateEsopeArray: 'ab.cd(ef)'))
		equals: 'ESOar(ESOat(ab,cd),ef)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayAndEsopeAtWithExpressionAsSubscript [

		self
		assert:
			(parser translateEsopeAt: (parser translateEsopeArray: 'ur.ubb(jr + 1)'))
		equals: 'ESOar(ESOat(ur,ubb),jr + 1)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayDotInsidePar [
	self
		assert: (parser translateEsopeAt: (parser translateEsopeArray: 'rlist.elist(rlist.ilist)=ms'))
		equals: 'ESOar(ESOat(rlist,elist),ESOat(rlist,ilist))=ms'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayRelbk [
	self
		assert: (parser translateEsopeAt: (parser translateEsopeArray: 'ur.ubb(jr) = ur.ubb(jr + 1)'))
		equals: 'ESOar(ESOat(ur,ubb),jr) = ESOar(ESOat(ur,ubb),jr + 1)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeArrayWithExpression [
	self
		assert:
			(parser translateEsopeAt: (parser translateEsopeArray: 'ur.ubb(jr + 1)'))
		equals: 'ESOar(ESOat(ur,ubb),jr + 1)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtBinaryOperator [
	self
		assert: (parser translateEsopeAt: '         if(lxs.eq.0)then')
		equals: '         if(lxs.eq.0)then'.
	self
		assert:
			(parser
				translateEsopeAt: '              if((rlist.ilist).gt.nlist)then')
		equals: '              if((ESOat(rlist,ilist)).gt.nlist)then'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtEqOperator [
	self assert: (parser translateEsopeAt: '         if(lxs.eq.0)then') equals: '         if(lxs.eq.0)then'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtNoDot [
	self assert: (parser translateEsopeAt: 'abc') equals: 'abc'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtOneDot [
	self
		assert: (parser translateEsopeAt: 'abc.def')
		equals: 'ESOat(abc,def)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeAtTwoDots [
	self
		assert: (parser translateEsopeAt: 'abc.def=opq.xyz')
		equals: 'ESOat(abc,def)=ESOat(opq,xyz)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashEsopeAt [
	self
		assert:
			(parser
				translateEsopeAt: (parser translateEsopeSlash: 'abc.def(/1)'))
	
		equals: 'ESOsl(ESOat(abc,def),1)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashNone [
	self
		assert: (parser translateEsopeSlash: 'abc.def')
		equals: 'abc.def'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashOne [
	self
		assert: (parser translateEsopeSlash: 'abc.def(/1)')
		equals: 'ESOsl(abc.def,1)'
]

{ #category : #tests }
EsopeRewriterTest >> testTranslateEsopeSlashSlash [
	self
		assert: (parser translateEsopeAt: 'C     //fin repeter "decouper chaque chaine"')
		equals: 'C     //fin repeter "decouper chaque chaine"'
]
