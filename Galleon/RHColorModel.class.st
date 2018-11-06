Class {
	#name : #RHColorModel,
	#superclass : #RHPropUI,
	#instVars : [
		'box'
	],
	#category : #'Galleon-GUI'
}

{ #category : #rendering }
RHColorModel >> renderWidget [
	box := RHWidget new.
	box extent:  self parent panelWidth@ 15.
	box color: self content.
	self addMorph: self getLabel.
	box onclick: [:e| self selectColor:e].
	self addMorph: box.
	^ self
]

{ #category : #rendering }
RHColorModel >> selectColor:e [
	RHColorPalette open: [:c | box color:c. self content: c  ] title: 'Select color'
]
