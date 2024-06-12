"
## Demo 

You can run any line to create a FAMIX model from the ESOPE source code or pure Fortran77 code.

```st
RunDemos runPureF77.

RunDemos runPlainExample.

RunDemos runBorbk.

RunDemos runFindbk.

RunDemos runFindur.

RunDemos runLibpnt.

RunDemos runMain.

RunDemos runNewbook.

RunDemos runNewlib.

RunDemos runNewuser.

RunDemos runRelbk.
```
"
Class {
	#name : #RunDemos,
	#superclass : #Object,
	#classVars : [
		'Counter'
	],
	#category : #'EsopeImporter-demos'
}

{ #category : #'class initialization' }
RunDemos class >> counter [

	Counter := Counter + 10
]

{ #category : #'class initialization' }
RunDemos class >> initialize [

	Counter := 1000
]

{ #category : #example }
RunDemos class >> runBorbk [

	<script>
	self runner: DemosCodes borbk
]

{ #category : #example }
RunDemos class >> runFindbk [

	<script>
	self runner: DemosCodes findbk
]

{ #category : #example }
RunDemos class >> runFindur [

	<script>
	self runner: DemosCodes findur
]

{ #category : #example }
RunDemos class >> runLibpnt [

	<script>
	self runner: DemosCodes libpnt
]

{ #category : #example }
RunDemos class >> runMain [

	<script>
	self runner: DemosCodes main
]

{ #category : #example }
RunDemos class >> runNewbook [

	<script>
	self runner: DemosCodes newbook
]

{ #category : #example }
RunDemos class >> runNewlib [

	<script>
	self runner: DemosCodes newlib
]

{ #category : #example }
RunDemos class >> runNewuser [

	<script>
	self runner: DemosCodes newuser
]

{ #category : #example }
RunDemos class >> runPlainExample [

	<script>
	self runner: DemosCodes plainExample
]

{ #category : #example }
RunDemos class >> runPureF77 [

	<script>
	self runner: DemosCodes pureF77
]

{ #category : #example }
RunDemos class >> runRelbk [

	<script>
	self runner: DemosCodes relbk
]

{ #category : #example }
RunDemos class >> runner: anEsopeSourceCode [

	<script>
	| rewriter defVisitor iast   jsonVisitor refVisitor |
	rewriter := PPEsopeRewriter new.
	rewriter parse: anEsopeSourceCode.

	jsonVisitor := JsonToIASTVisitor new.
   jsonVisitor visitCode: rewriter output.
	iast := jsonVisitor visitCode:  rewriter output.

	defVisitor := IASTToFamixFortranVisitor new.
	defVisitor model
		rootFolder: FileSystem workingDirectory;
		name: 'mooseModelF77-' , self counter asString.
	refVisitor := FamixEsopeResolver newFrom: defVisitor model.

	(iast accept: defVisitor) accept: refVisitor.

	refVisitor model inspect
]
