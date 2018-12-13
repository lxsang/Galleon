Class {
	#name : #ROSTFListener,
	#superclass : #InterVMChannel,
	#instVars : [
		'proxy',
		'tree',
		'lock',
		'isListening',
		'callbacks'
	],
	#category : #'Galleon-ROS'
}

{ #category : #matrix }
ROSTFListener class >> inverseOf: a4x4Matrix [
	"you've been warned: this is not a good implementation c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15"
	|a b c d e f g h i j k l m n o p  f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16 f17 det coll|
	a := a4x4Matrix at:1 at:1.
	b := a4x4Matrix at:1 at:2.
	c := a4x4Matrix at:1 at:3.
	d := a4x4Matrix at:1 at:4.
	e := a4x4Matrix at:2 at:1.
	f := a4x4Matrix at:2 at:2.
	g := a4x4Matrix at:2 at:3.
	h := a4x4Matrix at:2 at:4.
	i := a4x4Matrix at:3 at:1.
	j := a4x4Matrix at:3 at:2.
	k := a4x4Matrix at:3 at:3.
	l := a4x4Matrix at:3 at:4.
	m := a4x4Matrix at:4 at:1.
	n := a4x4Matrix at:4 at:2.
	o := a4x4Matrix at:4 at:3.
	p := a4x4Matrix at:4 at:4.
	f0 := (k*p) - (l*o).
	f1 := (j*p) - (l*n).
	f2 := (j*o) - (k*n).
	f3 := (g*p) - (h*o).
	f4 := (f*p) - (h*n).
	f5 := (f*o) - (g*n).
	f6 := (g*l) - (h*k).
	f7 := (f*l) - (h*j).
	f8 := (f*k) - (g*j).
	f9 := (i*p) - (l*m).
	f10 := (i*o) - (k*m).
	f11 := (e*p) - (h*m).
	f12 := (e*o) - (g*m).
	f13 := (e*l) - (h*i).
	f14 := (e*k) - (g*i).
	f15 := (i*n) - (j*m).
	f16 := (e*n) - (f*m).
	f17 := (e*j) - (f*i).
	coll := OrderedCollection new.
	coll add: (f*f0) - (g*f1) + (h*f2).
	coll add: (c*f1) - (b*f0) - (d*f2).
	coll add: (b*f3) - (c*f4) + (d*f5).
	coll add: (c*f7) - (b*f6) - (d*f8).
	coll add: (g*f9) - (e*f0) - (h*f10).
	coll add: (a*f0) - (c*f9) + (d*f10).
	coll add: (c*f11) - (a*f3) - (d*f12).
	coll add: (a*f6) - (c*f13) + (d*f14).
	coll add: (e*f1) - (f*f9) + (h*f15).
	coll add: (b*f9) - (a*f1) - (d*f15).
	coll add: (a*f4) - (b*f11) + (d*f16).
	coll add: (b*f13) - (a*f7) - (d*f17).
	coll add: (f*f10) - (e*f2) - (g*f15).
	coll add: (a*f2) - (b*f10) + (c*f15).
	coll add: (b*f12) - (a*f5) - (c*f16).
	coll add: (a*f8) - (b*f14) + (c*f17).
	det := (a*(coll at:1)) + (b*(coll at:5)) + (c*(coll at:9)) + (d*(coll at:13)).
	det = 0 ifTrue:[^ self error: 'Matrix is not inversible'].
	^(Matrix rows: 4 columns: 4 contents: coll ) / det
]

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
	|mat|
	mat := self getTBTFMatrix: path.
	mat ifNil: [ ^nil ].
	^self class inverseOf:mat

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
	self lock critical: [
		self iostream nextPut: (MessageSend receiver: nil selector: #getTree).
		[self iostream atEnd] whileTrue: [ 1 milliSeconds wait ].
		aBlock value: (self iostream next at:2)
	]
]

{ #category : #initialization }
ROSTFListener >> initialize [
	super initialize.
	tree := TFTree new.
	lock := Semaphore forMutualExclusion .
	self isListening: false.
	callbacks := OrderedCollection new.
	proxy := PhaROSPackage new.
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
								for: [ :msg | tree update: msg ];
								connect .
	(self proxy controller node buildConnectionFor: '/tf_static' ) 
		typedAs: 'tf2_msgs/TFMessage'; 
								for: [ :msg | tree update: msg ];
								connect.
	self isListening: true.

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
	| n path hash |
	self listen.
	hash := (sFrame , '->' , tFrame) hash.
	n := self tree element: sFrame.
			n
				ifNil: [ ^ self iostream
						nextPut:
							{hash.
							nil} ].
			path := n path: tFrame.
			path isEmpty
				ifTrue: [ n := self tree element: tFrame.
					n
						ifNil: [ ^ self iostream
								nextPut:
									{hash.
									nil} ].
					^ self iostream
						nextPut:
							{hash.
							(self getBTTFMatrix: (n path: sFrame))} ]
				ifFalse: [ "]"
					^ self iostream
						nextPut:
							{hash.
							(self getTBTFMatrix: path)} ] 
]

{ #category : #matrix }
ROSTFListener >> matrixFromQuaternion: q [
	^self class matrixFromQuaternion: q
]

{ #category : #lookup }
ROSTFListener >> pathFrom: sFrame to: tFrame [
	| n path |
	self listen.
	"lock
		critical: [" n := self tree element: sFrame.
			n ifNil: [ ^ {  } ].
			^ path := n path: tFrame"]"
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
	|data|
	"ones add: (self tfFrom: aFrame to: otherFrame  do: aBlock)."
	self lock critical: [
		self iostream nextPut: (MessageSend receiver: nil selector: #lookupTFFrom:to: arguments:{aFrame. otherFrame } ).
		[self iostream atEnd] whileTrue: [ 1 milliSeconds wait ].
		data := self iostream next.
		aBlock value:(data at:2)
	].
	"block until there is data"
	
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

{ #category : #'master-action' }
ROSTFListener >> waitForData [
	|data cbs|
	<master>
	[[ self iostream isOpen ] whileTrue: [ 
		self iostream atEnd ifFalse:[
			data := self iostream next.
			"check hash"
			cbs := self callbacks select:[:e| e key = (data at:1)].
			cbs do:[:e|e value value: (data at:2)]
		] ifTrue:[100 milliSeconds  wait]]
	] forkAt: Processor userBackgroundPriority  
]
