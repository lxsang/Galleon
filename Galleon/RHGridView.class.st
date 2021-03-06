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

{ #category : #event }
RHGridView >> propertyChange: prop [
	prop name = #spacing ifFalse:[^self].
	self spacing: prop value.
]

{ #category : #accessing }
RHGridView >> spacing [
	<galleonProperty: #Number> 
	^ spacing
]

{ #category : #accessing }
RHGridView >> spacing: anObject [
	spacing := anObject.
	self draw
]
