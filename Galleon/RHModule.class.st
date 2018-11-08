Class {
	#name : #RHModule,
	#superclass : #TRCompositeShape,
	#instVars : [
		'parent',
		'localframe',
		'topic',
		'children'
	],
	#category : #'Galleon-GUI'
}

{ #category : #initalize }
RHModule class >> childOf: anObject [
	| o |
	o := self new.
	(anObject respondsTo: #addChild:) ifTrue: [ 
		anObject addChild: o.
		 ] ifFalse:[
	o parent: anObject.].
	^ o
]

{ #category : #'instance creation' }
RHModule class >> fromJSONObject: obj [
	^self new fromJSONObject: obj; yourself
]

{ #category : #querying }
RHModule class >> queryInstanceVars [
	|arr|
	arr := Array new:0.
	(self superclass respondsTo: #queryInstanceVars) ifTrue:[
		arr := self superclass queryInstanceVars
	].
	arr := arr , (self instanceVariables collect:[:e| e -> self]).
	^arr
]

{ #category : #comment }
RHModule class >> readMe [
	^'Module documentation'
]

{ #category : #accessing }
RHModule >> addChild: anObject [
	anObject parent:self.
	self children add:anObject.
]

{ #category : #accessing }
RHModule >> announcer [
	^self parent announcer
]

{ #category : #export }
RHModule >> asJSONObject [
	|d prop val|
	d := Dictionary new.
	d at: 'class' put: self className.
	d at: 'children' put: (self children collect: [ :el | el asJSONObject ]) asArray.
	self class queryInstanceVars do:[ :v|
		"check if we has a getter"
		prop := self propertyTypeOf: v.
		prop ifNotNil:[
			val := (MessageSend receiver: self selector:prop name)  value.
			val class = Color ifTrue:[val := val asArray].
			d at:prop name asString put: val
		]
	].
	^d
]

{ #category : #services }
RHModule >> callService: aName args: aBlock [
	| service res |
	service := self proxy controller node service: aName.
	res := service call: aBlock.
	^res
]

{ #category : #accessing }
RHModule >> canvas [
	^self parent canvas
]

{ #category : #accessing }
RHModule >> children [
	^ children
]

{ #category : #accessing }
RHModule >> children: anObject [
	children := anObject
]

{ #category : #sync }
RHModule >> desynchronize [
	self undraw
]

{ #category : #accessing }
RHModule >> doc [
	^ self class readMe
]

{ #category : #drawing }
RHModule >> draw [
	^ self subclassResponsibility 
]

{ #category : #'instance creation' }
RHModule >> fromJSONObject: obj [
	| submodules |
	submodules := obj at: 'children'.
	obj removeKey: 'class'.
	obj removeKey: 'children'.
	obj keysAndValuesDo: [ :k :v | 
		v class = Array ifTrue:[
			(MessageSend receiver: self selector: (k , ':') asSymbol argument: v asColor) value
		] ifFalse:[
			(MessageSend receiver: self selector: (k , ':') asSymbol argument: v) value
		]
	].
	"children"
	submodules
		do: [ :el | 
			| c |
			c := (el at: 'class') asClass  fromJSONObject: el.
			self addChild: c ].
	^ self
]

{ #category : #initialization }
RHModule >> initialize [
	super initialize.
	children := OrderedCollection new.
	topic := nil
]

{ #category : #accessing }
RHModule >> localframe [
	<galleonProperty: #String>
	^ localframe
]

{ #category : #accessing }
RHModule >> localframe: anObject [
	localframe := anObject
]

{ #category : #accessing }
RHModule >> lock [
	^ self parent lock
]

{ #category : #sync }
RHModule >> name [
	^ 'A Galleon visualization module'
]

{ #category : #accessing }
RHModule >> parent [
	^ parent
]

{ #category : #accessing }
RHModule >> parent: anObject [
	parent := anObject
]

{ #category : #querying }
RHModule >> propList [
	|list prop|
	"the prop list is automatically from pragma"
	"first query all the install variable"
	list := OrderedCollection new.
	list add: (RHProperty
		from:
			{(#name -> #doc).
			(#type -> Text)}
		holder: self).
	self class queryInstanceVars do:[ :v|
		"check if we has a getter"
		prop := self propertyTypeOf: v.
		prop ifNotNil:[ list add: prop ]
	].
	^list
]

{ #category : #event }
RHModule >> propertyChange: prop [
]

{ #category : #querying }
RHModule >> propertyTypeOf: v [
	|pragmas arg|
	(self respondsTo:v key) ifFalse:[^nil].
	pragmas := (v value >> v key) pragmas.
	pragmas isEmpty ifTrue:[^nil].
	pragmas first key = #galleonProperty: ifFalse:[^nil].
	pragmas first arguments size = 1 ifFalse:[^nil].
	arg := pragmas first arguments at: 1.
	^(RHProperty
		from:
			{(#name -> v key).
			(#type -> arg asClass)}
		holder: self)
]

{ #category : #accessing }
RHModule >> proxy [
	^ self parent proxy
]

{ #category : #sync }
RHModule >> synchronize [
	self draw
]

{ #category : #sync }
RHModule >> synchronizeAll [
	self synchronize.
	self children do:[:c| c synchronize].
]

{ #category : #tf }
RHModule >> tfFrom: aFrame to: aNotherFrame [
	| rs |
	self parent use_external_tf_service
		ifTrue: [ rs := self
				callService: self parent tf_lookup_service
				args: [ :msg | 
					msg from: aFrame asString.
					msg to: aNotherFrame asString ].
			^ self tfListener tfToMatrix: rs transform transform ]
		ifFalse: [ ^ self tfListener lookupTFFrom: aFrame asSymbol to: aNotherFrame asSymbol ]
]

{ #category : #tf }
RHModule >> tfFromParent [
	self parent localframe asSymbol = self localframe asSymbol
		ifTrue: [ ^ nil ].
	^ self tfFrom: self localframe asSymbol  to: self parent localframe asSymbol
]

{ #category : #accessing }
RHModule >> tfListener [
	^ self parent tfListener
]

{ #category : #accessing }
RHModule >> topic [
	<galleonProperty: #String>
	^ topic
]

{ #category : #accessing }
RHModule >> topic: anObject [
	topic := anObject
]

{ #category : #tf }
RHModule >> translateFromParent [
	| m |
	self parent localframe asSymbol = self localframe asSymbol
		ifTrue: [ ^ 0 @ 0 ].
	m := self tfFromParent.
	m ifNil: [ ^ 0 @ 0 ].
	^ ((m at: 1 at: 4) / self parent resolution) rounded @ ((0 - (m at: 2 at: 4)) / self parent resolution) rounded
]

{ #category : #drawing }
RHModule >> undraw [
	self lock
		critical: [ self remove.
			self resetShapes.
			self canvas signalUpdate ]
]

{ #category : #drawing }
RHModule >> updateCanvas [
	self lock critical:[self canvas signalUpdate ].
]
