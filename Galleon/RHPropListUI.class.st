Class {
	#name : #RHPropListUI,
	#superclass : #RHWidget,
	#instVars : [
		'parent',
		'panelWidth'
	],
	#category : #'Galleon-GUI'
}

{ #category : #adding }
RHPropListUI >> addItem: t1 [
	| t2 |
	t2 := RHPropUI for: t1.
	t2 parent: self.
	t2 render.
	self addMorphFront: t2.
	self addSeparator.
	^ self
]

{ #category : #adding }
RHPropListUI >> addSeparator [
	self
		addMorph:
			(Morph new
				extent: 5 @ 5;
				color: self bgColor).
	^ self
]

{ #category : #accessing }
RHPropListUI >> annoucer [
	^ self parent announcer
]

{ #category : #accessing }
RHPropListUI >> bgColor [
	^ Color
		r: 0
		g: 0
		b: 0
		alpha: 0
]

{ #category : #initialization }
RHPropListUI >> initialize [
	super initialize.
	self layoutPolicy: TableLayout new.
	self listDirection: #topToBottom.
	self hResizing: #spaceFill.
	self vResizing: #spaceFill.
	self color: self bgColor.
	^ self
]

{ #category : #accessing }
RHPropListUI >> panelWidth [
	^ panelWidth
]

{ #category : #accessing }
RHPropListUI >> panelWidth: anObject [
	panelWidth := anObject.
	self extent: panelWidth @ self extent y
]

{ #category : #accessing }
RHPropListUI >> parent [
	^ parent
]

{ #category : #accessing }
RHPropListUI >> parent: t1 [
	parent := t1.
	"announcer when: RHPropChangeEvent send: #propertiesUpdate to: self parent."
	^ self
]

{ #category : #adding }
RHPropListUI >> setItems: t1 [
	self removeAllMorphs.
	t1 do: [ :t2 | self addItem: t2 ].
	^ self
]

{ #category : #signalling }
RHPropListUI >> signalUpdate [
	self annoucer announce: RHPropChangeEvent.
	^ self
]
