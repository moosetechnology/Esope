"
A FamixFortranModelTransformationVisitorTest is a test class for testing the behavior of FamixFortranModelTransformationVisitor
"
Class {
	#name : 'FamixFortranModelTransformationVisitorTest',
	#superclass : 'TestCase',
	#instVars : [
		'visitor'
	],
	#category : 'Famix-Esope-Visitors-Tests',
	#package : 'Famix-Esope-Visitors-Tests'
}

{ #category : 'running' }
FamixFortranModelTransformationVisitorTest >> newVisitor [

	^FamixFortranModelTransformationVisitor new
]

{ #category : 'running' }
FamixFortranModelTransformationVisitorTest >> setUp [
	super setUp.

	visitor := self newVisitor
]

{ #category : 'running' }
FamixFortranModelTransformationVisitorTest >> testMultipleProceduresMovedToModule [
	"
C	--------someFile.f----------------
	subroutine sub
	end
	real function f()
	end function
C  -----end someFile.f --------------

C	--------someFile_mod.f90----------------
module sub_mod
	implicit none
contains
	subroutine sub()
	end subroutine sub
	real function f()
	end function f
end sub_mod
C	--------end someFile_mod.f90----------------

	"

	| f77SourceFile subroutine function res module |
	
	subroutine := FamixF77PUSubroutine new 
		name: 'sub' ;
		sourceAnchor: (FamixF77SourceTextAnchor new source: '      subroutine sub
      end' );
		yourself.

	function := FamixF77PUFunction new 
		name: 'f' ;
		declaredType: (FamixF77TypeIntrinsic new name: 'real');
		sourceAnchor: (FamixF77SourceTextAnchor new source: '      real function f()
      end function' )
		yourself.

	f77SourceFile := FamixF77ProgramFile new 
		filename: 'someFile.f';
	 	addProgramUnit: subroutine ;
	 	addProgramUnit: function ;
		yourself.
		
	res := f77SourceFile accept: visitor.
	
	self assert: res class equals: FASTFortran2kProgramFile.
	self assert: res programUnit size equals: 1.
	
	module := res programUnit anyOne.
	self assert: module class equals: FASTFortran2kModule.
	self assert: module name equals: 'someFile_mod'.
	self assert: module procedures size equals: 2.
	
	res := module procedures first.
	self assert: res class equals: FASTFortran2kSubroutine.
	self assert: res name equals: 'sub'.

	res := module procedures second.
	self assert: res class equals: FASTFortran2kFunction.
	self assert: res name equals: 'f'.

]

{ #category : 'running' }
FamixFortranModelTransformationVisitorTest >> testProcedureInProgFileMovedTOModule [
	"
C	--------sub.f----------------
	subroutine sub
	print*, 'hello'
	end
C  -----end sub.f --------------

C	--------sub_mod.f90----------------
module sub_mod
	implicit none
contains
	subroutine sub()
	print *, 'hello'
	end subroutine sub
end sub_mod
C	--------end sub_mod.f90----------------

	"

	| f77SourceFile subroutine res |
	
	subroutine := FASTFortranSubroutine new 
			name: 'sub'; 
			statementBlock: (FASTFortranStatementBlock new
				statements: {
					FASTFortranPrintStatement new
						format: FASTFortranAsterisk new;
						arguments: { FASTFortranCharacterLiteral new primitiveValue: 'Hello' }; 
						yourself
				}
			); 
			yourself.

	f77SourceFile := FASTFortranProgramFile new "fileName: 'sub.f'"
	 	addProgramUnit: subroutine;
		yourself.
	
	
	f77SourceFile famix: (FamixF77ProgramFile new filename: 'sub.f').
	subroutine famix: (FamixF77PUSubroutine new name: 'sub').
		
	res := f77SourceFile accept: visitor.
	
	self assert: res class equals: FASTFortran2kProgramFile.
	self assert: res programUnit size equals: 1.
	
	res := res programUnit first.
	self assert: res class equals: FASTFortran2kModule.
	self assert: res name equals: 'sub_mod'.
	self assert: res procedures size equals: 1.
	
	res := res procedures first.
	self assert: res class equals: FASTFortran2kSubroutine.
	self assert: res name equals: 'sub'.
	self assert: res parameters size equals: 0.
	self assert: res statementBlock statements size equals: 1.
	self assert: res statementBlock statements first class equals: FASTFortran2kPrintStatement.
	

]

{ #category : 'running' }
FamixFortranModelTransformationVisitorTest >> testProgramAndProcedureMovedToProgranAndModule [
	"
	subroutine sub
	print*, 'hello'
	end
	program demo
	call sub()
	end


module sub_mod
	implicit none
contains
	subroutine sub()
	print *, 'hello'
	end subroutine sub
end sub_mod

program demo
	use :: sub_mod
	implicit none
	call sub()
end program demo

"

	| sourceFileSrc sourceFileDst subroutine programMain entity |
	
	subroutine := FASTFortranSubroutine new 
			name: 'sub'; 
			statementBlock: (FASTFortranStatementBlock new
				statements: {
					FASTFortranPrintStatement new
						format: FASTFortranAsterisk new;
						arguments: { FASTFortranCharacterLiteral new primitiveValue: 'Hello' }; 
						yourself
				}
			); 
			yourself.
			
	programMain := FASTFortranProgramMain new 
			name: 'demo'; 
			statementBlock: (FASTFortranStatementBlock new
				statements: { FASTFortranCallStatement new name: 'sub' ; arguments: {}; yourself }
			); 
			yourself.

	
	sourceFileSrc := FASTFortranProgramFile new "fileName: 'demo.f'"
	 	programUnit: { subroutine . programMain };
		yourself.
	
	
	sourceFileSrc famix: (FamixF77ProgramFile new filename: 'demo.f').
	subroutine famix: (FamixF77PUSubroutine new name: 'sub').
	programMain famix: (FamixF77PUMain new name: 'demo').

	sourceFileDst := sourceFileSrc accept: visitor.
	
	self assert: sourceFileDst class equals: FASTFortran2kProgramFile.
	self assert: sourceFileDst programUnit size equals: 2.
	
	entity := sourceFileDst programUnit first.
	self assert: entity class equals: FASTFortran2kModule.
	self assert: entity name equals: 'demo_mod'.
	self assert: entity procedures size equals: 1.
	
	entity := entity procedures first.
	self assert: entity class equals: FASTFortran2kSubroutine.
	self assert: entity name equals: 'sub'.
	
	entity := sourceFileDst programUnit second.
	self assert: entity class equals: FASTFortran2kProgramMain.
	self assert: entity name equals: 'demo'.
]

{ #category : 'running' }
FamixFortranModelTransformationVisitorTest >> testProgramWithExternalSubroutineInvocation [
	"
	subrotine 'sub' defined in file: 'someFile.f'

C	--------mainFile.f----------------
	program demo
	call sub
	end
C  -----end mainFile.f --------------

C	--------mainFile.f90----------------
program demo
	use :: someFile_mod
	implicit none
	call sub()
end program demo
C	--------end mainFile.f90----------------
	"

	| subroutine programMain subroutineInvocation res  f77MainFile |

	subroutine :=  FASTFortranSubroutine new 
			name: 'sub'; 
			famix: (FamixF77PUSubroutine new
				name: 'sub' ;
				programFile: (FamixF77ProgramFile new filename: 'someFile.f'));
			yourself.
			
	subroutineInvocation := FASTFortranCallStatement new 
			name: 'sub'; 
			arguments: {};
			yourself.
	
	programMain :=  FASTFortranProgramMain new 
			name: 'demo'; 
			statementBlock: ( FASTFortranStatementBlock new statements: { subroutineInvocation } );
			famix: (FamixF77PUMain new
				name: 'demo' ;
				programFile: (FamixF77ProgramFile new filename: 'mainFile.f'));
			yourself.
	
	subroutineInvocation famix: (
		FamixF77Invocation new 
			sender: programMain famix; 
			addCandidate: subroutine famix;
			yourself
		).
		
	f77MainFile := FamixF77ProgramFile new
		filename: 'mainFile.f';
		addProgramUnit: programMain famix;
		yourself.

	res := f77MainFile accept: visitor.

	self assert: res class equals: FASTFortran2kProgramMain.
	self assert: res name equals: 'demo'.
	self assert: res statementBlock statements size equals: 3.

]
