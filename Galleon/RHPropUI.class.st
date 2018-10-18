Class {
	#name : #RHPropUI,
	#superclass : #RHWidget,
	#instVars : [
		'parent',
		'property'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHPropUI class >> for: t1 [
	^ t1 asPropUIModel
]

{ #category : #accessing }
RHPropUI >> content [
	^ self property value
]

{ #category : #accessing }
RHPropUI >> content: t1 [
	self property value: t1.
	self property update.
	"self parent signalUpdate."
	^ self
]

{ #category : #'instance creation' }
RHPropUI >> for: t1 [
	self property: t1.
	^ self
]

{ #category : #drawing }
RHPropUI >> getColor [
	^Color r: 0.4 g:0.64  b:0.88 alpha: 1.0.
]

{ #category : #accessing }
RHPropUI >> getLabel [
	| t1 |
	t1 := LabelMorph newLabel: self name, ':'.
	t1 color: Color white.
	"t1 height: 20."
	t1 width: self parent panelWidth - 10.
	^ t1
]

{ #category : #initialization }
RHPropUI >> initialize [
	super initialize.
	self layoutPolicy: TableLayout new.
	self listDirection: #bottomToTop.
	self hResizing: #spaceFill.
	self vResizing: #spaceFill.
	^ self
]

{ #category : #accessing }
RHPropUI >> name [
	^ self property name
]

{ #category : #accessing }
RHPropUI >> parent [
	^ parent
]

{ #category : #accessing }
RHPropUI >> parent: anObject [
	parent := anObject
]

{ #category : #accessing }
RHPropUI >> property [
	^ property
]

{ #category : #accessing }
RHPropUI >> property: anObject [
	property := anObject
]

{ #category : #drawing }
RHPropUI >> render [
	self color: self getColor.
	"self
		addMorph:
			((LabelMorph newLabel: '')
				width: 10;
				color: self parent bgColor;
				yourself)."
	self renderWidget.
	^ self
]

{ #category : #drawing }
RHPropUI >> renderWidget [
	^ self subclassResponsibility
]
