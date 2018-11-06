Class {
	#name : #RHWidget,
	#superclass : #Morph,
	#instVars : [
		'onclick'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'event handling' }
RHWidget >> handlesMouseDown: evt [
    ^true
]

{ #category : #'event handling' }
RHWidget >> mouseDown: evt [
    evt hand waitForClicksOrDrag: self event: evt
]

{ #category : #'event handling' }
RHWidget >> mouseUp:e [
	onclick ifNil: [ ^self ].
	onclick value: e
]

{ #category : #'event handling' }
RHWidget >> onclick:v [
	onclick := v
]
