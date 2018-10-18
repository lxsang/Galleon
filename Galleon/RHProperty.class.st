Class {
	#name : #RHProperty,
	#superclass : #Object,
	#instVars : [
		'name',
		'value',
		'holder',
		'type',
		'setter',
		'getter',
		'dataset'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHProperty class >> from:t1 holder:t2 [
	^self new
		from:t1 holder: t2;
		yourself
]

{ #category : #'as yet unclassified' }
RHProperty >> asPropUIModel [
	self type
		caseOf:
			{(Symbol
				-> [ ^ RHTextPropModel new
						for: self;
						yourself ]).
			(String
				-> [ ^ RHTextPropModel new
						for: self;
						yourself ]).
			(Number
				-> [ ^ RHTextPropModel new
						for: self;
						numeric: true;
						yourself ]).
			(Text
				-> [ ^ RHTextPropModel new
						for: self;
						roText:  true;
						yourself ]).
			(Array
				-> [ ^ RHDropListPropModel new
						for: self;
						yourself ]).
			(Boolean
				-> [ self dataset: {true . false}.
					^ RHDropListPropModel new
						for: self;
						yourself ])}
		otherwise: [ ^ RHPropUI new
				for: self;
				yourself ]
]

{ #category : #accessing }
RHProperty >> dataset [
	^ dataset
]

{ #category : #accessing }
RHProperty >> dataset: anObject [
	dataset := anObject
]

{ #category : #'instance creation' }
RHProperty >> from: t1 holder:t2 [
	self holder: t2.
	t1 do: [ :t3|
		(MessageSend receiver: self 
				selector: (t3 key, ':') asSymbol
				argument: t3 value
		) value	
	].
	self value: (MessageSend receiver: self holder selector: self getter ) value.
	^self
]

{ #category : #accessing }
RHProperty >> getter [
	getter == nil ifTrue: [ ^self name asSymbol ].
	^ getter
]

{ #category : #accessing }
RHProperty >> getter: anObject [
	getter := anObject
]

{ #category : #accessing }
RHProperty >> holder [
	^ holder
]

{ #category : #accessing }
RHProperty >> holder: anObject [
	holder := anObject
]

{ #category : #accessing }
RHProperty >> name [
	^ name
]

{ #category : #accessing }
RHProperty >> name: anObject [
	name := anObject
]

{ #category : #accessing }
RHProperty >> setter [
	setter == nil ifTrue: [ ^(self name, ':') asSymbol  ].
	^ setter
]

{ #category : #accessing }
RHProperty >> setter: anObject [
	setter := anObject
]

{ #category : #accessing }
RHProperty >> type [
	^ type
]

{ #category : #accessing }
RHProperty >> type: anObject [
	type := anObject
]

{ #category : #updating }
RHProperty >> update [
	(MessageSend receiver: self holder selector: self setter argument: self value) value.
	self holder propertyChange: self.
	"update view if needed"
	^ self
]

{ #category : #accessing }
RHProperty >> value [
	^ value
]

{ #category : #accessing }
RHProperty >> value: anObject [
	value := anObject
]
