Class {
	#name : #RHListChooser,
	#superclass : #RHUIRootApp,
	#instVars : [
		'dataBlock'
	],
	#category : #'Galleon-GUI'
}

{ #category : #specs }
RHListChooser class >> defaultSpec [
	^ SpecLayout composed newRow: [ :t1 | t1 add: #dList ]
]

{ #category : #accessing }
RHListChooser >> childrenBlock: t1 [
	self dList childrenBlock: t1.
	^ self
]

{ #category : #accessing }
RHListChooser >> dataBlock [
	^ dataBlock
]

{ #category : #accessing }
RHListChooser >> dataBlock: anObject [
	dataBlock := anObject
]

{ #category : #api }
RHListChooser >> displayBlock: t1 [
	self dList displayBlock: t1.
	^ self
]

{ #category : #api }
RHListChooser >> iconBlock: t1 [
	self dList iconBlock: t1.
	^ self
]

{ #category : #initialization }
RHListChooser >> initializeDialogWindow: t1 [
	| t2 |
	t1
		okAction: [ [t2 := self dList selectedItem content] unless: self dList selectedItem isNil.
			t2
				ifNotNil: [ self dataBlock ~= nil
						ifTrue: [ self dataBlock value: t2 ] ] ].
	^ self
]

{ #category : #initialization }
RHListChooser >> initializeWidgets [
	self instantiateModels: #(#dList #TreeModel).
	^ self
]

{ #category : #actions }
RHListChooser >> openDialog: t1 title: t2 [
	self dataBlock: t1.
	self
		openDialogWithSpec;
		title: t2.
	^ self
]

{ #category : #api }
RHListChooser >> roots: t1 [
	self dList roots: t1.
	^ self
]
