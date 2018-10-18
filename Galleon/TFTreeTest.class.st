Class {
	#name : #TFTreeTest,
	#superclass : #TestCase,
	#category : #'Galleon-Test'
}

{ #category : #'as yet unclassified' }
TFTreeTest >> testUpdateSecondTF [
	| tf2 gtf tree tree2 c|
	tf2 := Tf2_msgsTFMessage new.
	
	gtf := Geometry_msgsTransformStamped new.
	gtf header frame_id: 'base_foot_print'.
	gtf child_frame_id: 'base_link'.
	tf2 transforms: { gtf }.
	
	tree := self testUpdateTF.
	tree update:tf2.
	
	"now test if it work"
	tree2 := tree children at:1.
	self assert: tree2 root = tree.
	self assert: tree2 parent = tree.
	self assert: tree2 frameid = 'odom'.
	self assert: tree2 children size = 1.
	c := tree2 children at:1.
	self assert: c isNotNil.
	self assert: c parent = tree2.
	self assert: c root = tree.
	self assert: c frameid = 'base_foot_print'.
	self assert: c children size = 1.
	self assert: (c children at:1) parent = c.
	self assert: (c children at:1) root = tree.
	self assert: (c children at:1) children size = 0.
	self assert: (c children at:1) frameid = 'base_link'.
	^tree2
]

{ #category : #'as yet unclassified' }
TFTreeTest >> testUpdateTF [
	|tf1 tf2 tf3 gtf tree c|
	tf1 := Tf2_msgsTFMessage new.
	
	
	gtf := Geometry_msgsTransformStamped new.
	gtf header frame_id: 'odom'.
	gtf child_frame_id: 'base_foot_print'.
	tf1 transforms: (Array new:1).
	tf1 transforms at:1 put: gtf.
	
	tree := TFTree new.
	"first add to the tf tree"
	tree update: tf1.
	self assert: tree root = tree.
	self assert: tree parent = nil.
	self assert: tree frameid = nil.
	self assert: tree children size = 1.
	c := tree children at:1.
	self assert: c isNotNil.
	self assert: c parent = tree.
	self assert: c root = tree.
	self assert: c frameid = 'odom'.
	self assert: c children size = 1.
	self assert: (c children at:1) parent = c.
	self assert: (c children at:1) root = tree.
	self assert: (c children at:1) children size = 0.
	self assert: (c children at:1) frameid = 'base_foot_print'.
	
	^tree
	
]

{ #category : #'as yet unclassified' }
TFTreeTest >> testUpdateThirdTF [
	| tf3 gtf tree tree3 c|
	tf3 := Tf2_msgsTFMessage new.
	
	gtf := Geometry_msgsTransformStamped new.
	gtf header frame_id: 'map'.
	gtf child_frame_id: 'odom'.
	tf3 transforms: { gtf }.
	
	tree := self testUpdateSecondTF.
	tree update:tf3.
	
	"now test if it work"
	tree3 := tree root.
	self assert: tree3 isNotNil.
	self assert: tree3 root = tree3.
	self assert: tree3 parent = nil.
	self assert: tree3 frameid = nil.
	self assert: tree3 children size = 1.
	c := tree3 children at:1.
	self assert: c isNotNil.
	self assert: c parent = tree3.
	self assert: c root = tree3.
	self assert: c frameid = 'map'.
	self assert: c children size = 1.
	self assert: (c children at:1) parent = c.
	self assert: (c children at:1) root = tree3.
	self assert: (c children at:1) children size = 1.
	self assert: (c children at:1) frameid = 'odom'.
	Transcript show: tree3 asString; cr.
]
