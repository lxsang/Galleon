Class {
	#name : #ROSTFListener,
	#superclass : #Object,
	#instVars : [
		'proxy',
		'tree',
		'lock',
		'isListening',
		'callbacks'
	],
	#category : #'Galleon-ROS'
}

{ #category : #'as yet unclassified' }
ROSTFListener class >> listenFrom:aController [
	^self new listenFrom: aController.
]

{ #category : #'as yet unclassified' }
ROSTFListener >> addCallback: aBlock [
	callbacks add: aBlock 
]

{ #category : #accessing }
ROSTFListener >> callbacks [
	^ callbacks
]

{ #category : #lookup }
ROSTFListener >> getBTTFMatrix: path [
	^nil
]

{ #category : #matrix }
ROSTFListener >> getIdentity [
	^Matrix identity: 4
]

{ #category : #matrix }
ROSTFListener >> getTBTFMatrix: path [
	| m collection |
	path ifNil: [ ^ nil ].
	path isEmpty
		ifTrue: [ ^ nil ].
	path size = 1
		ifTrue: [ ^ self getIdentity ].
	collection := path asOrderedCollection.
	collection removeFirst.
	m := self getIdentity.
	collection do: [ :node | m := m +* (self tfToMatrix: node tf) ].
	^ m
]

{ #category : #initialization }
ROSTFListener >> initialize [
	tree := TFTree new.
	lock := Mutex new.
	self isListening: false.
	callbacks := OrderedCollection new.
]

{ #category : #accessing }
ROSTFListener >> isListening [
	^ isListening
]

{ #category : #accessing }
ROSTFListener >> isListening: anObject [
	isListening := anObject
]

{ #category : #scripts }
ROSTFListener >> listen [
	proxy ifNil: [ ^self ].
	self isListening ifTrue: [ ^self ].
	(self proxy controller node buildConnectionFor: '/tf' ) 
		typedAs: 'tf2_msgs/TFMessage'; 
								for: [ :msg | self updateTFTree:msg ];
								connect .
	(self proxy controller node buildConnectionFor: '/tf_static' ) 
		typedAs: 'tf2_msgs/TFMessage'; 
								for: [ :msg | self updateTFTree:msg ];
								connect.
	self isListening: true.
	^self
]

{ #category : #scripts }
ROSTFListener >> listenFrom: aproxy [
	self proxy: aproxy.
	self listen.
]

{ #category : #accessing }
ROSTFListener >> lock [
	^ lock
]

{ #category : #accessing }
ROSTFListener >> lock: anObject [
	lock := anObject
]

{ #category : #lookup }
ROSTFListener >> lookupTFFrom: sFrame to: tFrame [
	| n path |
	self listen.
	lock
		critical: [ n := self tree element: sFrame.
			n ifNil: [ ^ nil ].
			path := n path: tFrame.
			path isEmpty
				ifTrue: [ n := self tree element: tFrame.
					n ifNil: [ ^ nil ].
					^ self getBTTFMatrix: (n path: sFrame) ]
				ifFalse: [ ^ self getTBTFMatrix: path ] ]
]

{ #category : #matrix }
ROSTFListener >> matrixFromQuaternion: q [
	|sqx sqy sqw sqz m invs tmp1 tmp2|
	m := Matrix identity:4.
	sqw := (q w)*(q w).
	sqx := (q x)*(q x).
	sqy := (q y)*(q y).
	sqz := (q z)*(q z).
	"invs (inverse square length) is only required if quaternion is not already normalised"
   invs := 1.0 / (sqx + sqy + sqz + sqw).
	m at:1 at:1 put: ( sqx - sqy - sqz + sqw)*invs.
	m at:2 at:2 put: (sqy - sqz + sqw - sqx)*invs.
	m at:3 at:3 put: (sqz + sqw -sqx - sqy)*invs.
    
	tmp1 := (q x)*(q y).
	tmp2 := (q z)*(q w).
    m at:2 at:1 put: 2.0 * (tmp1 + tmp2)*invs.
    m at:1 at:2 put: 2.0 * (tmp1 - tmp2)*invs.
    
    tmp1 := (q x)*(q z).
    tmp2 := (q y)*(q w).
    m at:3 at:1 put:2.0 * (tmp1 - tmp2)*invs.
    m at:1 at:3 put:2.0 * (tmp1 + tmp2)*invs.
    tmp1 := (q y)*(q z).
    tmp2 := (q x)*(q w).
    m at:3 at:2 put: 2.0 * (tmp1 + tmp2)*invs.
    m at:2 at:3 put: 2.0 * (tmp1 - tmp2)*invs.
	^m
]

{ #category : #lookup }
ROSTFListener >> pathFrom: sFrame to: tFrame [
	| n path |
	self listen.
	lock
		critical: [ n := self tree element: sFrame.
			n ifNil: [ ^ {  } ].
			^ path := n path: tFrame]
]

{ #category : #accessing }
ROSTFListener >> proxy [
	^ proxy
]

{ #category : #accessing }
ROSTFListener >> proxy:ap [
	proxy := ap.
]

{ #category : #matrix }
ROSTFListener >> tfToMatrix: tf [
	| m |
	m := self matrixFromQuaternion: tf rotation.
	m at: 1 at: 4 put: tf translation x.
	m at: 2 at: 4 put: tf translation y.
	m at: 3 at: 4 put: tf translation z.
	^ m
]

{ #category : #accessing }
ROSTFListener >> tree [
	^ tree
]

{ #category : #accessing }
ROSTFListener >> tree: anObject [
	tree := anObject
]

{ #category : #scripts }
ROSTFListener >> updateTFTree: msg [
	lock critical: [ tree update: msg ].
	"callback"
	self callbacks do:[:c| c value]
]
