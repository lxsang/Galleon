Class {
	#name : #RHGridView,
	#superclass : #RHModule,
	#instVars : [
		'spacing',
		'grid',
		'lb'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHGridView class >> readMe [
	^ 'I represent a grid in the world.
My frame is the world''s frame.
My spacing is in metter, 1m is my default spacing'
]

{ #category : #'as yet unclassified' }
RHGridView >> allShapes [
	^ {lb. grid}
]

{ #category : #converting }
RHGridView >> asJSONObject [
	|d|
	d := super asJSONObject.
	d at: 'spacing' put: self spacing.
	^d
]

{ #category : #drawing }
RHGridView >> draw [
	[ ^ self ] if: self parent isNil.
	self lock
		critical: [ lb
				ifNil: [ lb := TRLabelShape new text: '+'.
					lb color: Color blue.
					self canvas addShape: lb ].
			grid ifNotNil: [ self canvas removeShape: grid ].
			grid := TRCanvasGridShape new spacing: (self spacing / self parent resolution) asInteger.
			self canvas addShape: grid.
			self canvas push: grid behind: lb.
			self canvas signalUpdate ]
]

{ #category : #initialization }
RHGridView >> initialize [
	super initialize.
	spacing := 1
]

{ #category : #accessing }
RHGridView >> name [
	^ 'Grid view'
]

{ #category : #initialization }
RHGridView >> propList [
	^ super propList ,{(RHProperty
		from:
			{(#name -> #spacing).
			(#type -> Number)}
		holder: self)}
]

{ #category : #'as yet unclassified' }
RHGridView >> propertyChange: prop [
	self spacing: prop value.
]

{ #category : #accessing }
RHGridView >> spacing [
	^ spacing
]

{ #category : #accessing }
RHGridView >> spacing: anObject [
	spacing := anObject.
	self draw
]
