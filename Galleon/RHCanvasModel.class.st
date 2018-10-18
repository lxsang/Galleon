Class {
	#name : #RHCanvasModel,
	#superclass : #ComposableModel,
	#instVars : [
		'viewer'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHCanvasModel class >> defaultSpec [
    <spec: #default>
    ^ SpecLayout composed
        add: #viewer;
        yourself
]

{ #category : #'as yet unclassified' }
RHCanvasModel >> initializeWidgets [
	| t1 |
	t1 := TRCanvas new.
	t1 camera adjust.
	viewer := t1 buildMorph asSpecAdapter.
	self focusOrder add: viewer
]

{ #category : #accessing }
RHCanvasModel >> viewer [
	^ viewer
]

{ #category : #accessing }
RHCanvasModel >> viewer: anObject [
	viewer := anObject
]
