Class {
	#name : #EsopeRewriterForBookStoreTest,
	#superclass : #PP2CompositeNodeTest,
	#instVars : [
		'sixSpaces'
	],
	#category : #'EsopeImporter-Tests-Rewriter'
}

{ #category : #accessing }
EsopeRewriterForBookStoreTest >> parserClass [
	^ PPEsopeRewriter 
]

{ #category : #running }
EsopeRewriterForBookStoreTest >> setUp [

	super setUp.
	parser initStream.
	sixSpaces := '      '
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testApplyTransformationTodoAndSlash [
	| actualSource expectedSource |

	actualSource := '         ur.ubb(jr) == ur.ubb(jr + 1) + ur.ubb(/jr)'.
	expectedSource := '         D__(ur,ubb(jr)) == D__(ur,ubb(jr + 1)) + S__(D__(ur,ubb),jr)'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testComplexDot [
	| actualSource expectedSource |

	actualSource := '         ur.ubb(jr) == ur.ubb(jr + 1)'.
	expectedSource := '         D__(ur,ubb(jr)) == D__(ur,ubb(jr + 1))'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testComplexSlashPointerDotAttribute [
	| actualSource expectedSource |

	actualSource := '       brcnt = lb.bref(/j/2)'.
	expectedSource := '       brcnt = S__(D__(lb,bref),j/2)'.
	self
		assert:
			(parser applyTransformation: actualSource )
		equals: expectedSource
]

{ #category : #'tests-complete' }
EsopeRewriterForBookStoreTest >> testDemoFullCompilationUnit [
	| actualSource expectedSource |

	actualSource := '      subroutine newuser(lib,name)
      implicit none

      integer ubbcnt
      segment, user
        character*40 uname
        integer ubb(ubbcnt)
      end segment

      pointeur ur.user
c the user doesn''t have a book yet
      ubbcnt = 0
      segini, ur
      ur.uname = name
      end
'.
	expectedSource := '      subroutine newuser(lib,name)
      implicit none

      integer ubbcnt
c@_   segment, user
        character*40 uname
        integer ubb(ubbcnt)
c@_   end segment

c@_   pointeur ur.user
c the user doesn''t have a book yet
      ubbcnt = 0
c@_   segini, ur
      D__(ur,uname) = name
      end
'.
	self parse: actualSource.

	self assert: parser output equals: expectedSource 
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testDotWithPointerAndArrayAttribute [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr.a_attr(i)'.
	expectedSource := '       brcnt = D__(ptr,a_attr(i))'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testDotWithPointerAndArrayAttributeComplex [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr.a_attr(i+j)'.
	expectedSource := '       brcnt = D__(ptr,a_attr(i+j))'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testDotWithPointerAndScalarAttribute [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr.s_attr'.
	expectedSource := '       brcnt = D__(ptr,s_attr)'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testEsopeDotTransformationInsideInvocationOrArraySubscript [

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
EsopeRewriterForBookStoreTest >> testEsopeSlashTransformationInsideInvocationOrArraySubscript [

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

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testEsopeTransformationInsideInvocationOrArraySubscript [

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
EsopeRewriterForBookStoreTest >> testFortranLine [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr + a'.
	expectedSource := '       brcnt = ptr + a'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testFortranLineWithDot [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr + a'.
	expectedSource := '       brcnt = ptr + a'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testFortranLineWithOperatorDot [
	| actualSource expectedSource |

	actualSource := '         if ( a.eq.b) then'.
	expectedSource := '         if ( a.eq.b) then'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testPointerComplex [
	| actualSource expectedSource |
	self skip.
	actualSource := '         pointeur ptr1.seg,ptr2.seg
'.
	expectedSource := 'c@_      pointeur ptr1.seg,ptr2.seg
'.
	
	self parse: actualSource rule: #pointer.
	self assert: parser output equals: expectedSource
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testPointerSimple [
	| actualSource expectedSource |

	actualSource := '         pointeur ptr.seg
'.
	expectedSource := 'c@_      pointeur ptr.seg
'.
	
	self parse: actualSource rule: #pointer.
	self assert: parser output equals: expectedSource
]

{ #category : #'tests-helper' }
EsopeRewriterForBookStoreTest >> testSegCommand: aSymbolRule with: paramsString [
	| actualSource expectedSource |

	actualSource := '          ' , aSymbolRule , paramsString.
	expectedSource := 'c@_       ' , aSymbolRule , paramsString.
	
	self parse: actualSource rule: aSymbolRule.
	self assert: parser output equals: expectedSource
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegactComplex [

	self testSegCommand: #segact with: 'p, q
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegactSimple [

	self testSegCommand: #segact with: 'p    
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegadjComplex [

	self testSegCommand: #segadj with: 'p, q
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegadjSimple [

	self testSegCommand: #segadj with: 'p    
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegdesComplex [

	self testSegCommand: #segdes with: 'p, q
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegdesSimple [

	self testSegCommand: #segdes with: 'p    
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSeginiComplex [

	self testSegCommand: #segact with: 'p, q
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSeginiComplexWithCopy [

	self testSegCommand: #segini with: 'p=q
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSeginiSimpleWithComma [

	self testSegCommand: #segini with: ',rlist
'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSeginiSimpleWithSpace [

	self testSegCommand: #segini with: '          rlist



'
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegmentComplex [
	| actualSource expectedSource |

	actualSource := '      segment, user
       character*40 uname
       integer ubb(ubbcnt)
       pointeur ptr.seg
      end segment
'.
	expectedSource := 'c@_   segment, user
       character*40 uname
       integer ubb(ubbcnt)
c@_    pointeur ptr.seg
c@_   end segment
'.
	self parse: actualSource rule: #segment.
	self assert: parser output equals: expectedSource.
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegmentSimple [
	| actualSource expectedSource |
	actualSource := '      segment, user
       character*40 uname
       integer ubb(ubbcnt)
      end segment
'.
	expectedSource := 'c@_   segment, user
       character*40 uname
       integer ubb(ubbcnt)
c@_   end segment
'.
	self parse: actualSource rule: #segment.
	self assert: parser output equals: expectedSource.
]

{ #category : #'tests-cannotation' }
EsopeRewriterForBookStoreTest >> testSegmentSimpleWithMoreThanSixSpaces [
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

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testSimpleSlashAttribute [
	| actualSource expectedSource |

	actualSource := '       brcnt = ptr.bref(/j)'.
	expectedSource := '       brcnt = S__(D__(ptr,bref),j)'.
	self
		assert:
			(parser applyTransformation: actualSource)
		equals: expectedSource
]

{ #category : #'tests-transformation' }
EsopeRewriterForBookStoreTest >> testSimpleSlashAttributeWithoutPrefix [

	| actualSource expectedSource |
	actualSource := '       brcnt = bref(/j)'.
	expectedSource := '       brcnt = S__(bref,j)'.
	self
		assert: (parser applyTransformation: actualSource)
		equals: expectedSource
]
