Class {
	#name : #TRUtil,
	#superclass : #TRObject,
	#classInstVars : [
		'instance'
	],
	#category : #'Galleon-External-Trachel-Core'
}

{ #category : #accessing }
TRUtil class >> instance [
	^ instance ifNil: [ instance := self new ]
]

{ #category : #factory }
TRUtil >> widgetFactory [
	^ TRMorphWidgetFactory
]
