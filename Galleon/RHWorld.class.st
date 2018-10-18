Class {
	#name : #RHWorld,
	#superclass : #RHModule,
	#instVars : [
		'resolution',
		'tf_lookup_service',
		'use_external_tf_service'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHWorld class >> readMe [
^'I am the top module representing the world.
My default frame is ''map'''
]

{ #category : #converting }
RHWorld >> asJSONObject [
	|d|
	d := super asJSONObject.
	d at: 'resolution' put: self resolution.
	d at: 'tf_lookup_service' put: self tf_lookup_service.
	d at: 'use_external_tf_service' put: self use_external_tf_service.
	^d
]

{ #category : #drawing }
RHWorld >> draw [
	"| xtent xaxe yaxe |
	xtent := self parent canvas extent.
	xaxe := TRLineShape new from: (0 - xtent x) @ 0 to: xtent x @ 0.
	self addShape: xaxe.
	yaxe := TRLineShape new from: 0 @ xtent y to: 0 @ (0 - xtent y).
	self addShape: yaxe.
	self canvas addShape: self."
	^ self
]

{ #category : #initialization }
RHWorld >> initialize [
	super initialize.
	localframe := 'map'.
	tf_lookup_service  := '/tf_lookup'.
	use_external_tf_service := true.
	resolution := 0.05
]

{ #category : #accessing }
RHWorld >> name [
	^ 'World'
]

{ #category : #initialization }
RHWorld >> propList [
	^ super propList
		,
			{(RHProperty
				from:
					{(#name -> #use_external_tf_service).
					(#type -> Boolean )}
				holder: self).			
			(RHProperty
				from:
					{(#name -> #tf_lookup_service).
					(#type -> String)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #localframe).
					(#type -> String)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #resolution).
					(#type -> Number)}
				holder: self)}
]

{ #category : #event }
RHWorld >> propertyChange: prop [
	
]

{ #category : #action }
RHWorld >> pushBottom: el [
	self children remove: el.
	self children add: el.
	self lock
		critical: [ el allShapes do: [ :s | self canvas pushFront: s ].
			self canvas signalUpdate ]
]

{ #category : #action }
RHWorld >> pushDown: el [
	| index nextElement |
	index := self children indexOf: el.
	index = 0
		ifTrue: [ ^ self ].
	index = self children size
		ifTrue: [ ^ self ].
	nextElement := self children at: index + 1.
	nextElement allShapes isEmpty
		ifTrue: [ ^ self ].
	self children remove: el.
	self children add: el after: nextElement.
	self lock
		critical: [ self canvas pushAll: nextElement allShapes behindAll: el allShapes.
			self canvas signalUpdate ]
]

{ #category : #action }
RHWorld >> pushTop: el [
	self children remove: el.
	self children addFirst: el.
	self lock critical: [ 
		el allShapes do:[:s| self canvas pushBack: s].
		self canvas signalUpdate 
	]
]

{ #category : #action }
RHWorld >> pushUp: el [
	| index previousElement |
	index := self children indexOf: el.
	index <= 1
		ifTrue: [ ^ self ].
	previousElement := self children at: index - 1.
	"change the layer"
	previousElement allShapes isEmpty
		ifTrue: [ ^ self ].
	self children remove: el.
	self children add: el before: previousElement.
	self lock
		critical: [ self canvas pushAll: el allShapes behindAll: previousElement allShapes.
			self canvas signalUpdate ]
]

{ #category : #accessing }
RHWorld >> resolution [
	^ resolution
]

{ #category : #accessing }
RHWorld >> resolution: anObject [
	resolution := anObject
]

{ #category : #accessing }
RHWorld >> tf_lookup_service [
	^ tf_lookup_service
]

{ #category : #accessing }
RHWorld >> tf_lookup_service: anObject [
	tf_lookup_service := anObject
]

{ #category : #accessing }
RHWorld >> use_external_tf_service [
	^ use_external_tf_service
]

{ #category : #accessing }
RHWorld >> use_external_tf_service: anObject [
	use_external_tf_service := anObject
]
