Class {
	#name : #EsopeFullGrammarTest,
	#superclass : #TestCase,
	#instVars : [
		'parser'
	],
	#category : #'Esope-Rewriter-Tests'
}

{ #category : #running }
EsopeFullGrammarTest >> parserClass [

	^ PPEsopeGrammar
]

{ #category : #running }
EsopeFullGrammarTest >> setUp [

	super setUp.
	parser := self parserClass new
]

{ #category : #running }
EsopeFullGrammarTest >> testBigFile [

	self deny:
		(parser parse: EsopeGrammarTest esopeBigFile) isPetit2Failure
]

{ #category : #running }
EsopeFullGrammarTest >> testEmptyFile [

	self deny: (parser parse: '
') isPetit2Failure
]

{ #category : #running }
EsopeFullGrammarTest >> testEsopePointeurFile [

	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
      pointeur alist.list
      return
      end
') isPetit2Failure
]

{ #category : #running }
EsopeFullGrammarTest >> testEsopeSegactFile [

	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
      segact,splist
      return
      end
') isPetit2Failure
]

{ #category : #running }
EsopeFullGrammarTest >> testEsopeSegadjFile [

	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
                segadj,rlist

      return
      end
') isPetit2Failure
]

{ #category : #running }
EsopeFullGrammarTest >> testEsopeSegdesFile [

	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
      segdes,alist

      return
      end
') isPetit2Failure
]

{ #category : #running }
EsopeFullGrammarTest >> testEsopeSeginiFile [

	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
              segini,ms

      return
      end
') isPetit2Failure
]

{ #category : #running }
EsopeFullGrammarTest >> testNonEsopeFile [

	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
      return
      end
') isPetit2Failure
]

{ #category : #running }
EsopeFullGrammarTest >> testSmallFile [

	self deny:
		(parser parse: EsopeGrammarTest esopeSmallFile) isPetit2Failure
]
