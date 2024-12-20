"
an abstract class to represent an esopeCommand, segini, segadj, segsup, segprt, segact, segdes, segcop, segmov

## Relations
======================

### Parents
| Relation | Origin | Opposite | Type | Comment |
|---|
| `statementContainer` | `FASTTStatement` | `statements` | `FASTTStatementBlock` | Block containing this statement.|

### Other
| Relation | Origin | Opposite | Type | Comment |
|---|
| `pointeurs` | `FASTEsopeEsopeCommand` | `esopeCommand` | `FASTEsopePointeur` | |


## Properties
======================

| Name | Type | Default value | Comment |
|---|
| `endPos` | `Number` | nil | |
| `startPos` | `Number` | nil | |

"
Class {
	#name : 'FASTEsopeEsopeCommand',
	#superclass : 'FASTEsopeEntity',
	#traits : 'FASTTStatement',
	#classTraits : 'FASTTStatement classTrait',
	#instVars : [
		'#pointeurs => FMMany type: #FASTEsopePointeur opposite: #esopeCommand'
	],
	#category : 'FAST-Esope-Entities-Entities',
	#package : 'FAST-Esope-Entities',
	#tag : 'Entities'
}

{ #category : 'meta' }
FASTEsopeEsopeCommand class >> annotation [

	<FMClass: #EsopeCommand super: #FASTEsopeEntity>
	<package: #'FAST-Esope-Entities'>
	<generated>
	^ self
]

{ #category : 'adding' }
FASTEsopeEsopeCommand >> addPointeur: anObject [
	<generated>
	^ self pointeurs add: anObject
]

{ #category : 'accessing' }
FASTEsopeEsopeCommand >> pointeurs [
	"Relation named: #pointeurs type: #FASTEsopePointeur opposite: #esopeCommand"

	<generated>
	<derived>
	^ pointeurs
]

{ #category : 'accessing' }
FASTEsopeEsopeCommand >> pointeurs: anObject [

	<generated>
	pointeurs value: anObject
]
