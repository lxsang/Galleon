Class {
	#name : #RHAnnotationListener,
	#superclass : #RHModule,
	#instVars : [
		'sub'
	],
	#category : #'Galleon-GUI'
}

{ #category : #initialization }
RHAnnotationListener >> callback: msg [
	|obj|
	obj := STONJSON fromStream: msg data readStream.
	self announcer announce: (RHAnnotationClearEvent new).
	obj do:[:el|
			| ins |
			ins := (el at: 'class') asClass fromJSONObject: el.
			ins readonly.
			self announcer announce: (RHAnnotationEvent for: ins type:#add ).
			self announcer announce: (RHGoalAddEvent for: ins) 
	].
]

{ #category : #initialization }
RHAnnotationListener >> desynchronize [
	sub ifNil: [ ^ self ].
	self proxy controller node unsubscribe: sub
]

{ #category : #initialization }
RHAnnotationListener >> initialize [
	super initialize.
	topic := '/robotcmd/annotations'
]

{ #category : #initialization }
RHAnnotationListener >> name [
	^ 'An Annotation listener'
]

{ #category : #initialization }
RHAnnotationListener >> propList [
	^ super propList
		,{
			(RHProperty
				from:
					{(#name -> #topic).
					(#type -> String)}
				holder: self)}
]

{ #category : #initialization }
RHAnnotationListener >> synchronize [
	self topic ifNil: [ ^ self ].
	sub := (self proxy controller node buildConnectionFor: self topic)
		typedAs: 'std_msgs/String';
		for: [ :msg | self callback: msg ];
		connect
]
