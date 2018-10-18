Extension { #name : #BlockClosure }

{ #category : #'*Galleon' }
BlockClosure >> if: aCond [
	| v |
	v := aCond isBlock
		ifTrue: [ aCond value ]
		ifFalse: [ aCond ].
	v
		ifTrue: [ ^ self value ]
]

{ #category : #'*Galleon' }
BlockClosure >> unless: aCond [
	| v |
	v := aCond isBlock
		ifTrue: [ aCond value ]
		ifFalse: [ aCond ].
	v
		ifFalse: [ ^ self value ]
]
