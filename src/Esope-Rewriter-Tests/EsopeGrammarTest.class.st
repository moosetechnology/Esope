Class {
	#name : #EsopeGrammarTest,
	#superclass : #PP2CompositeNodeTest,
	#instVars : [
		'sixSpaces'
	],
	#category : #'Esope-Rewriter-Tests'
}

{ #category : #accessing }
EsopeGrammarTest >> parserClass [
	^ PPEsopeGrammar
]

{ #category : #running }
EsopeGrammarTest >> setUp [

	super setUp.
	parser := self parserInstance.
	sixSpaces := '      '.
]

{ #category : #tests }
EsopeGrammarTest >> testEmptyLine [

	self
		parse: '       
'
		rule: #emptyLine
]

{ #category : #tests }
EsopeGrammarTest >> testEndOfLine [

	self parse: String cr rule: #endOfLine.

	self parse: String crlf rule: #endOfLine.

	self parse: String lf rule: #endOfLine
]

{ #category : #tests }
EsopeGrammarTest >> testFortranLine [

	self
		parse: sixSpaces , 'subroutine test(brr)
'
		rule: #fortranLine.

	self parse: String cr rule: #fortranLine
]

{ #category : #tests }
EsopeGrammarTest >> testFortranLineEmpty [

	self
		parse: '
'
		rule: #fortranLine
]

{ #category : #tests }
EsopeGrammarTest >> testInclude [

	self
		parse: '#include <implicit.h>
'
		rule: #include.
	self
		parse: '#include "string.seg"
'
		rule: #include.

	self
		fail: '#include "implicit.h>
'
		rule: #include
]

{ #category : #tests }
EsopeGrammarTest >> testLines [

	| aLine |
	aLine := sixSpaces , 'abc' , String cr.

	self parse: '' rule: #lines.

	self parse: aLine rule: #lines.
	self parse: aLine , aLine , aLine rule: #lines.

	self fail: aLine , (sixSpaces , 'end' , String cr) rule: #lines
]

{ #category : #tests }
EsopeGrammarTest >> testNotEndLine [

	self parse: sixSpaces , 'abc' , String cr rule: #notEndLine.
	self fail: sixSpaces , 'end' , String cr rule: #notEndLine
]

{ #category : #tests }
EsopeGrammarTest >> testOptionalBlanks [

	self parse: '     ' rule: #optionalBlanks.


	self parse: '' rule: #optionalBlanks
]

{ #category : #tests }
EsopeGrammarTest >> testPointer [

	self
		parse: sixSpaces , 'pointeur splist.list
'
		rule: #pointer.
	self fail: 'pointeur splist.list' rule: #pointer
]

{ #category : #tests }
EsopeGrammarTest >> testPointerExtraSpaces [

	self
		parse: '         pointeur splist.list  
'
		rule: #pointer
]

{ #category : #tests }
EsopeGrammarTest >> testSegact [

	self parse: sixSpaces , 'segact,splist' , String cr rule: #segact.
	self parse: sixSpaces , 'segact,pv1' , String cr rule: #segact.
	self parse: sixSpaces , '  segact,xs' , String cr rule: #segact.
	self fail: 'segact,splist' , String cr rule: #segact
]

{ #category : #tests }
EsopeGrammarTest >> testSegadj [

	self
		parse: sixSpaces , 'segadj,alist
'
		rule: #segadj.
	self fail: 'segadj,alist' rule: #segadj
]

{ #category : #tests }
EsopeGrammarTest >> testSegadjVcAcc226 [

	self
		parse: sixSpaces , 'segadj,pval
'
		rule: #segadj.
	self fail: 'segadj,pval' rule: #segadj
]

{ #category : #tests }
EsopeGrammarTest >> testSegdes [

	self
		parse: sixSpaces , 'segdes,alist
'
		rule: #segdes.
	self
		parse: sixSpaces , '  segdes,pshp1*NOMOD
'
		rule: #segdes.
	self fail: 'segdes,alist' rule: #segdes
]

{ #category : #tests }
EsopeGrammarTest >> testSegini [

	self
		parse: sixSpaces , 'segini,rlist
'
		rule: #segini.
	self fail: 'segini,rlist' rule: #segini
]

{ #category : #tests }
EsopeGrammarTest >> testSegment [

	| segment |
	segment := '      segment,values
        character*8        valtyp
        real               valf(valnf)
        integer            vale(valne)
        logical            vall(valnl)
        character*(valsmx) valc(valnc)
        integer            vals(valnc)
      endsegment
'.
	self parse: segment rule: #segment.
	segment := '      segment string
        character cstg*(lstg)
      endsegment
'.
	self parse: segment rule: #segment.

	self fail: '      segment,values' rule: #segment
]

{ #category : #tests }
EsopeGrammarTest >> testSegmentSimpleWithMoreThanSixSpaces [

	| segment |
	segment := '       segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment
'.
	self parse: segment rule: #segment
]

{ #category : #tests }
EsopeGrammarTest >> testSegprt [

	self
		parse: sixSpaces , 'segprt,rlist
'
		rule: #segprt.
	self fail: 'segprt,rlist' rule: #segprt
]

{ #category : #tests }
EsopeGrammarTest >> testSegsup [

	self
		parse: sixSpaces , 'segsup,rlist
'
		rule: #segsup.
	self fail: 'segsup,rlist' rule: #segsup
]
