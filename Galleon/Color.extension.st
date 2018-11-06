Extension { #name : #Color }

{ #category : #'*Galleon-GUI' }
Color >> asArray [
	^{ self red. self green. self blue. self alpha}
]
