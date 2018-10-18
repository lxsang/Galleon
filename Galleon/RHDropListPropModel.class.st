Class {
	#name : #RHDropListPropModel,
	#superclass : #RHPropUI,
	#category : #'Galleon-GUI'
}

{ #category : #drawing }
RHDropListPropModel >> renderWidget [
	| t1 |
	t1 := DropListModel new.
	t1 extent:  self parent panelWidth@ 20.
	t1
		items: self property dataset;
		displayBlock: [ :t2 | t2 asString ];
		setSelectedItem: self content;
		whenSelectedItemChanged: [ :t2 | self content: t2 ].
	self addMorph: self getLabel.
	self addMorph: t1 buildWithSpec.
	^ self
]
