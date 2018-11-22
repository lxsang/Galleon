Class {
	#name : #InterVMBaseModule,
	#superclass : #Object,
	#instVars : [
		'portal'
	],
	#category : #'Galleon-InterVM-API'
}

{ #category : #'instance creation' }
InterVMBaseModule class >> on:aProxy [
	^self new on:aProxy; yourself
]

{ #category : #accessing }
InterVMBaseModule >> closePortal [
	self teleport __close
]

{ #category : #accessing }
InterVMBaseModule >> controller [
	^ portal __ctrl
]

{ #category : #initialization }
InterVMBaseModule >> initialize [
	portal := InterVMTeleport new.
	portal << self
]

{ #category : #accessing }
InterVMBaseModule >> on: proxy [
	self proxy: proxy 
]

{ #category : #accessing }
InterVMBaseModule >> proxy: p [
	portal __proxy: p
]

{ #category : #accessing }
InterVMBaseModule >> teleport [
	^portal
]
