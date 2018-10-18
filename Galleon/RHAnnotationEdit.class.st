Class {
	#name : #RHAnnotationEdit,
	#superclass : #RHUIRootApp,
	#instVars : [
		'dataBlock'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHAnnotationEdit class >> defaultSpec [
	^ SpecLayout composed
		newColumn: [ :t1 | 
			t1
				newRow: [ :t2 | t2 add: #lblModel ] height: 25;
				newRow: [ :t2 | t2 add: #Clist ];
				addSplitter;
				newRow: [ :t2 | t2 add: #lblDesc ] height:25;
				newRow: [ :t2 | t2 add: #txtDesc ] height: 25 ]
]

{ #category : #accessing }
RHAnnotationEdit >> childrenBlock: t1 [
	self Clist childrenBlock: t1.
	^ self
]

{ #category : #accessing }
RHAnnotationEdit >> dataBlock [
	^ dataBlock
]

{ #category : #accessing }
RHAnnotationEdit >> dataBlock: anObject [
	dataBlock := anObject
]

{ #category : #initialization }
RHAnnotationEdit >> displayBlock: t1 [
	self Clist displayBlock: t1.
	^ self
]

{ #category : #defaults }
RHAnnotationEdit >> iconBlock: t1 [
	self Clist iconBlock: t1.
	^ self
]

{ #category : #initialization }
RHAnnotationEdit >> initializeDialogWindow: t1 [
	| t2 |
	t1
		okAction: [[t2 := self Clist selectedItem content] unless: self Clist selectedItem isNil.
			t2
				ifNotNil: [ self dataBlock ~= nil
						ifTrue: [ self dataBlock value: (t2 text: self txtDesc getText) ] ] ].
	^ self
]

{ #category : #initialization }
RHAnnotationEdit >> initializeWidgets [
	self instantiateModels: #(#lblModel #LabelModel #Clist #TreeModel #lblDesc #LabelModel #txtDesc #TextInputFieldModel).
	self lblModel label: 'Annotation model'.
	self lblDesc label: 'Annotation'.
	self txtDesc autoAccept: true
]

{ #category : #dialog }
RHAnnotationEdit >> openDialog: t1 title: t2 [
	self dataBlock: t1.
	self
		openDialogWithSpec;
		title: t2.
	^ self
]

{ #category : #api }
RHAnnotationEdit >> roots: t1 [
	self Clist roots: t1.
	^ self
]
