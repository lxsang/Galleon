Class {
	#name : #TFTree,
	#superclass : #Object,
	#instVars : [
		'parent',
		'children',
		'tf',
		'frameid',
		'stamp',
		'root'
	],
	#category : #'Galleon-ROS'
}

{ #category : #adding }
TFTree >> addChild: el [
	self children add: el.
	el parent: self
]

{ #category : #updating }
TFTree >> addChildTF: transform to: node [
	| child |
	child := self root element: transform child_frame_id asSymbol.
	child
		ifNil: [ child := TFTree new.	"add new child"
			child frameid: transform child_frame_id asSymbol.
			child root: self root.
			child stamp: transform header stamp.
			child tf: transform transform.
			node addChild: child ]
		ifNotNil: [ child tf: transform transform.
			child stamp: transform header stamp.
			child parent frameid = node frameid
				ifFalse: [ child parent children remove: child.
					node addChild: child ] ]	"update child"
]

{ #category : #updating }
TFTree >> addNewTF: transform [
	| newnode child |
	newnode := TFTree new.
	newnode frameid: transform header frame_id asSymbol.
	newnode root: self root.
	child := self root element: transform child_frame_id asSymbol.
	child
		ifNil: [ child := TFTree new.
			child frameid: transform child_frame_id asSymbol.
			child root: self root ]
		ifNotNil: [  child parent children remove: child].	
	child stamp: transform header stamp.
	child tf: transform transform.
	newnode addChild: child.
	self root addChild: newnode
]

{ #category : #converting }
TFTree >> asString [
	^self frameid 
]

{ #category : #accessing }
TFTree >> children [
	^ children
]

{ #category : #accessing }
TFTree >> children:frid [
	self children do:[:c| c frameid = frid ifTrue: [^c]].
	^nil
]

{ #category : #accessing }
TFTree >> element: frame [
	self frameid = frame ifTrue: [ ^self ].
	self children do:[:c||e|
			e := c element: frame.
			e isNotNil ifTrue: [ ^e ] 
	].
	^nil
]

{ #category : #flattening }
TFTree >> flatten [
	|c|
	c := OrderedCollection new.
	self frameid ifNotNil: [ c add:self ].
	self children do:[:ch| c := c, (ch flatten) ].
	^c
]

{ #category : #accessing }
TFTree >> frameid [
	^ frameid
]

{ #category : #accessing }
TFTree >> frameid: anObject [
	frameid := anObject
]

{ #category : #initialization }
TFTree >> initialize [
	parent := nil.
	children := OrderedCollection new.
	root := self
]

{ #category : #lookup }
TFTree >> lookup: target from:source [
	^self
]

{ #category : #accessing }
TFTree >> parent [
	^ parent
]

{ #category : #accessing }
TFTree >> parent: anObject [
	parent := anObject.
	self root: parent root.
]

{ #category : #accessing }
TFTree >> path: frame [
	| node |
	self frameid ifNil: [ node := {} ] ifNotNil: [ node := {self} ].
	self frameid = frame
		ifTrue: [ ^ {self} ].
	self children
		do: [ :c | 
			| e |
			e := c element: frame.
			e isNotNil
				ifTrue: [ ^ node , (c path: frame) ] ].
	^ {}
]

{ #category : #accessing }
TFTree >> root [
	^ root
]

{ #category : #accessing }
TFTree >> root: anObject [
	root := anObject
]

{ #category : #accessing }
TFTree >> stamp [
	^ stamp
]

{ #category : #accessing }
TFTree >> stamp: anObject [
	stamp := anObject
]

{ #category : #accessing }
TFTree >> tf [
	^ tf
]

{ #category : #accessing }
TFTree >> tf: anObject [
	tf := anObject
]

{ #category : #updating }
TFTree >> update:aMsg [
	aMsg transforms do:[:transform|
		self updateTF:transform
	]
]

{ #category : #updating }
TFTree >> updateTF: transform [
	|node|
	node := self root element: transform header frame_id asSymbol.
	node ifNil: [
		self addNewTF: transform 
	] ifNotNil: [ 
		self addChildTF:transform to:node.
	] 
	
]

{ #category : #accessing }
TFTree >> view [
	| view els |
	view := RTView new.
	els := (RTLabel new color:Color darkGray) elementsOn: self flatten .
		els @ RTDraggable.
		view addAll: els.
	RTEdgeBuilder new
		view: view;
		objects: self flatten ;
	shape:
		(RTLine new
			attachPoint: RTShorterDistanceAttachPoint new; color:Color darkGray)
			+
				(RTSimpleArrowHead new
					attachPoint: RTShorterDistanceAttachPoint new; color:Color darkGray);
		connectFrom: #yourself toAll: #children.
	RTTreeLayout on: els.
	view @ RTDraggableView.
	^ view
]
