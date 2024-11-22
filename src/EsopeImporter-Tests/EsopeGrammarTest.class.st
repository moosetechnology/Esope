Class {
	#name : 'EsopeGrammarTest',
	#superclass : 'PP2CompositeNodeTest',
	#instVars : [
		'sixSpaces'
	],
	#category : 'EsopeImporter-Tests-Rewriter',
	#package : 'EsopeImporter-Tests',
	#tag : 'Rewriter'
}

{ #category : 'accessing' }
EsopeGrammarTest >> parserClass [
	^ PPEsopeGrammar
]

{ #category : 'running' }
EsopeGrammarTest >> setUp [

	super setUp.
	parser := self parserInstance.
	sixSpaces := '      '.
]

{ #category : 'tests' }
EsopeGrammarTest >> testCommentLine [

	self
		parse: 'c: end segment
'
		rule: #commentLine.

	self
		parse: '*: CNOM    Tableau des noms  des objets du fichier 1
'
		rule: #commentLine
]

{ #category : 'tests' }
EsopeGrammarTest >> testEmptyLine [

	self
		parse: '       
'
		rule: #emptyLine
]

{ #category : 'tests' }
EsopeGrammarTest >> testEndOfLine [

	self parse: String cr rule: #endOfLine.

	self parse: String crlf rule: #endOfLine.

	self parse: String lf rule: #endOfLine
]

{ #category : 'tests' }
EsopeGrammarTest >> testEndSegment [

	| segment |

	self flag: #TESTSKIP. "workaround"
	self skip.

	segment := '      endsegment
'.
	self parse: segment rule: #endSegment.

	segment := '      end segment  
'.
	self parse: segment rule: #endSegment.

	self fail: '      end segment,values' rule: #endSegment
]

{ #category : 'tests' }
EsopeGrammarTest >> testFortranLine [

	self
		parse: sixSpaces , 'subroutine test(brr)
'
		rule: #fortranLine.

	self parse: String cr rule: #fortranLine
]

{ #category : 'tests' }
EsopeGrammarTest >> testFortranLineEmpty [

	self
		parse: '
'
		rule: #fortranLine
]

{ #category : 'tests' }
EsopeGrammarTest >> testInclude [

	self flag: #TESTSKIP. "workaround"
	self skip.

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

{ #category : 'tests' }
EsopeGrammarTest >> testIncludeDoubleQuote [


	self
		parse: '#include "string.seg"
'
		rule: #include.
]

{ #category : 'tests' }
EsopeGrammarTest >> testIncludeMixed [


	self flag: #TESTSKIP. "workaround"
	self skip.

	self
		fail: '#include "string.seg>
'
		rule: #include.
]

{ #category : 'tests' }
EsopeGrammarTest >> testIncludeNotDoubleQuote [


	self
		parse: '#include <string.seg>
'
		rule: #include.
]

{ #category : 'tests' }
EsopeGrammarTest >> testLines [

	| aLine |
	aLine := sixSpaces , 'abc' , String cr.

	self parse: '', String lf rule: #emptyLine.
	self parse: 'C', String cr rule: #commentLine.
	self parse: aLine rule: #fortranLine.
	self parse: aLine , aLine , aLine.
	self parse: aLine , (sixSpaces , 'end' , String cr)
]

{ #category : 'tests' }
EsopeGrammarTest >> testOptionalBlanks [

	self parse: '     ' rule: #optionalBlanks.


	self parse: '' rule: #optionalBlanks
]

{ #category : 'tests' }
EsopeGrammarTest >> testPointer [

	self flag: #TESTSKIP. "workaround"
	self skip.

	self
		parse: sixSpaces , 'pointeur splist.list
'
		rule: #pointer.
	self fail: 'pointeur splist.list' rule: #pointer
]

{ #category : 'tests' }
EsopeGrammarTest >> testPointerExtraSpaces [

	self
		parse: '         pointeur splist.list  
'
		rule: #pointer
]

{ #category : 'tests' }
EsopeGrammarTest >> testPointers [

	self flag: #TESTSKIP. "workaround"
	self skip.
	
	self
		parse: sixSpaces , 'pointeur splist.list,p.q, q.r
'
		rule: #pointer.
	self fail: 'pointeur splist.list' rule: #pointer
]

{ #category : 'tests' }
EsopeGrammarTest >> testSegact [

	self flag: #TESTSKIP. "workaround"
	self skip.

	self parse: sixSpaces , 'segact,splist' , String cr rule: #segact.
	self parse: sixSpaces , 'segact,pv1' , String cr rule: #segact.
	self parse: sixSpaces , '  segact,xs' , String cr rule: #segact.
	self fail: 'segact,splist' , String cr rule: #segact
]

{ #category : 'tests' }
EsopeGrammarTest >> testSegadj [

	self flag: #TESTSKIP. "workaround"
	self skip.

	self
		parse: sixSpaces , 'segadj,alist
'
		rule: #segadj.
	self fail: 'segadj,alist' rule: #segadj
]

{ #category : 'tests' }
EsopeGrammarTest >> testSegadjVcAcc226 [

	self flag: #TESTSKIP. "workaround"
	self skip.

	self
		parse: sixSpaces , 'segadj,pval
'
		rule: #segadj.
	self fail: 'segadj,pval' rule: #segadj
]

{ #category : 'tests' }
EsopeGrammarTest >> testSegdes [

	self flag: #TESTSKIP. "workaround"
	self skip.

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

{ #category : 'tests' }
EsopeGrammarTest >> testSegini [

	self flag: #TESTSKIP. "workaround"
	self skip.

	self
		parse: sixSpaces , 'segini,rlist
'
		rule: #segini.
	self fail: 'segini,rlist' rule: #segini
]

{ #category : 'tests' }
EsopeGrammarTest >> testSegment [

	| segment |

	self flag: #TESTSKIP. "workaround"
	self skip.

	segment := '      segment,values
'.
	self parse: segment rule: #segment.

	segment := '      segment string
'.
	self parse: segment rule: #segment.

	segment := '      segment BIDon(LL)
'.
	self parse: segment rule: #segment.

	segment := '      segment BIDon(LL)*R
'.
	self parse: segment rule: #segment.

	self fail: '      segment,values' rule: #segment
]

{ #category : 'tests' }
EsopeGrammarTest >> testSegmentSimpleWithMoreThanSixSpaces [

	| segment |
	segment := '       segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment
'.
	self parse: segment
]

{ #category : 'tests' }
EsopeGrammarTest >> testSegprt [

	self flag: #TESTSKIP. "workaround"
	self skip.

	self
		parse: sixSpaces , 'segprt,rlist
'
		rule: #segprt.
	self fail: 'segprt,rlist' rule: #segprt
]

{ #category : 'tests' }
EsopeGrammarTest >> testSegsup [

	self flag: #TESTSKIP. "workaround"
	self skip.

	self
		parse: sixSpaces , 'segsup,rlist
'
		rule: #segsup.
	self fail: 'segsup,rlist' rule: #segsup
]
