Class {
	#name : #ROSTFListener,
	#superclass : #InterVMChannel,
	#instVars : [
		'proxy',
		'tree',
		'lock',
		'isListening',
		'callbacks',
		'ones'
	],
	#category : #'Galleon-ROS'
}

{ #category : #matrix }
ROSTFListener class >> matrixFromQuaternion: q [
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

{ #category : #matrix }
ROSTFListener class >> tfToMatrix: tf [
	| m |
	m := self matrixFromQuaternion: tf rotation.
	m at: 1 at: 4 put: tf translation x.
	m at: 2 at: 4 put: tf translation y.
	m at: 3 at: 4 put: tf translation z.
	^ m
]

{ #category : #'master-action' }
ROSTFListener >> addCallback: aBlock [
	<master>
	callbacks add: aBlock.
	^ aBlock
]

{ #category : #'master-action' }
ROSTFListener >> callbacks [
	<master>
	^ callbacks
]

{ #category : #lookup }
ROSTFListener >> getBTTFMatrix: path [
	self shouldBeImplemented.
	^(self getTBTFMatrix: path) inverse
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

{ #category : #accessing }
ROSTFListener >> getTree [
	self listen.
	self iostream nextPut: {#getTree hash. tree}.
	
]

{ #category : #'master-action' }
ROSTFListener >> getTreeDo: aBlock [
	<master>
	^self addCallback: #getTree hash -> aBlock.
]

{ #category : #'master-action' }
ROSTFListener >> getTreeDoOnce: aBlock [
	<master>
	ones add:(self getTreeDo: aBlock).
	self iostream nextPut: (MessageSend receiver: nil selector: #getTree)
]

{ #category : #initialization }
ROSTFListener >> initialize [
	super initialize.
	tree := TFTree new.
	lock := Semaphore forMutualExclusion .
	self isListening: false.
	callbacks := OrderedCollection new.
	proxy := PhaROSPackage new.
	ones := OrderedCollection new.
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
	| n path hash|
	self listen.
	hash := (sFrame,'->', tFrame) hash.
	lock
		critical: [ n := self tree element: sFrame.
			n ifNil: [ ^ nil ].
			path := n path: tFrame.
			path isEmpty
				ifTrue: [ n := self tree element: tFrame.
					n ifNil: [ ^ nil ].
					^self iostream nextPut:{hash. ( self getBTTFMatrix: (n path: sFrame))} ]
				ifFalse: [ ^ self iostream nextPut:{hash. (self getTBTFMatrix: path)}] ]
]

{ #category : #matrix }
ROSTFListener >> matrixFromQuaternion: q [
	^self class matrixFromQuaternion: q
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

{ #category : #'master-action' }
ROSTFListener >> tfFrom: aFrame to: otherFrame do:aBlock [
	<master>
	^self addCallback: (aFrame,'->', otherFrame) hash -> aBlock
]

{ #category : #'master-action' }
ROSTFListener >> tfFrom: aFrame to: otherFrame doOnce:aBlock [
	<master>
	ones add: (self tfFrom: aFrame to: otherFrame  do: aBlock).
	self iostream nextPut: (MessageSend receiver: nil selector: #lookupTFFrom:to: arguments:{aFrame. otherFrame } )
]

{ #category : #matrix }
ROSTFListener >> tfToMatrix: tf [
	^self class tfToMatrix: tf
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
]

{ #category : #'master-action' }
ROSTFListener >> waitForData [
	|data cbs|
	<master>
	[[ self iostream isOpen ] whileTrue: [ 
		self iostream atEnd ifFalse:[
			data := self iostream next.
			"check hash"
			cbs := self callbacks select:[:e| e key = (data at:1)].
			cbs do:[:e|
				e value value: (data at:2).
				(ones includes: e) ifTrue:[
					callbacks remove: e.
					ones remove:e
				].
				].
		] ifTrue:[100 milliSeconds  wait]]
	] forkAt: Processor userBackgroundPriority  
]
