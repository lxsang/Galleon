Class {
	#name : #RHTextPropModel,
	#superclass : #RHPropUI,
	#instVars : [
		'numeric',
		'roText'
	],
	#category : #'Galleon-GUI'
}

{ #category : #initialization }
RHTextPropModel >> initialize [
	super initialize.
	numeric := false.
	roText := false.
	^ self
]

{ #category : #accessing }
RHTextPropModel >> numeric [
	^ numeric
]

{ #category : #accessing }
RHTextPropModel >> numeric: anObject [
	numeric := anObject
]

{ #category : #drawing }
RHTextPropModel >> renderWidget [
	| t1 accept wrap |
	self addMorph: self getLabel.
	accept := nil.
	wrap := true.
	t1 := PluggableTextFieldMorph new.
	self numeric
		ifTrue: [ t1 convertTo: Number ]
		ifFalse: [ t1 convertTo: String ].
	t1 width: self parent panelWidth.
	self roText
		ifTrue: [ t1 height: 80 ]
		ifFalse: [ t1 height: 30.
			t1 acceptOnCR: true.
			t1 alwaysAccept: true.
			accept := #content:.
			wrap := false.
			t1 hideScrollBarsIndefinitely ].
	t1
		on: self
		text: #content
		accept: accept
		readSelection: nil
		menu: nil.
	t1 textMorph
		autoFit: true;
		wrapFlag: wrap.
	self addMorph: t1.
	^ self
]

{ #category : #accessing }
RHTextPropModel >> roText [
	^ roText
]

{ #category : #accessing }
RHTextPropModel >> roText: anObject [
	roText := anObject
]
