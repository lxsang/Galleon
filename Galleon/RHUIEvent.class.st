Class {
	#name : #RHUIEvent,
	#superclass : #Announcement,
	#instVars : [
		'type',
		'data'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHUIEvent class >> for:d [
	^ self new data:d; yourself
]

{ #category : #'as yet unclassified' }
RHUIEvent class >> for: d type:t [
	^ self new
		data: d;
		type:t;
		yourself
]

{ #category : #accessing }
RHUIEvent >> data [
	^ data
]

{ #category : #accessing }
RHUIEvent >> data: anObject [
	data := anObject
]

{ #category : #accessing }
RHUIEvent >> type [
	^ type
]

{ #category : #accessing }
RHUIEvent >> type: anObject [
	type := anObject
]
