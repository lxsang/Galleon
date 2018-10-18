Class {
	#name : #RHGoalListener,
	#superclass : #RHModule,
	#instVars : [
		'goalpub',
		'goalspub',
		'goalidxpub',
		'goalidxsub',
		'goals',
		'status_topic',
		'currentGoal',
		'hibernate',
		'counter',
		'goals_topic',
		'automatic_switch_goal',
		'next_goal_topic',
		'queueing_reached_goal',
		'goalsub',
		'nextgoalsub',
		'goals_index_topic'
	],
	#category : #'Galleon-GUI'
}

{ #category : #'as yet unclassified' }
RHGoalListener class >> readMe [
	^ 'i am listening to the goal set by user using the toolbox, and publish it to a dedicated topic'
]

{ #category : #adding }
RHGoalListener >> addGoal: aGoal [ 
	| st |
	[ ^ self ] if: (goals includes: aGoal).
	goals add: aGoal.
	st := goals size.
	aGoal status: st asString.
	self publishGoals
]

{ #category : #converting }
RHGoalListener >> asJSONObject [
	| d |
	d := super asJSONObject.
	d at: 'status_topic' put: self status_topic.
	d at: 'goals_topic' put: self goals_topic.
	d at: 'automatic_switch_goal' put: self automatic_switch_goal.
	d at: 'next_goal_topic' put: self next_goal_topic.
	d at: 'queueing_reached_goal' put: self queueing_reached_goal.
	d at: 'goals_index_topic' put: self goals_index_topic .
	^ d
]

{ #category : #accessing }
RHGoalListener >> automatic_switch_goal [
	^ automatic_switch_goal
]

{ #category : #accessing }
RHGoalListener >> automatic_switch_goal: anObject [
	automatic_switch_goal := anObject
]

{ #category : #'as yet unclassified' }
RHGoalListener >> clearGoals [
	self goals do:[:g | g status: nil].
	goals := OrderedCollection new.
	
]

{ #category : #accessing }
RHGoalListener >> counter [
	^ counter
]

{ #category : #accessing }
RHGoalListener >> counter: anObject [
	counter := anObject
]

{ #category : #accessing }
RHGoalListener >> currentGoal [
	currentGoal > goals size ifTrue:[currentGoal := 1].
	^currentGoal
]

{ #category : #accessing }
RHGoalListener >> currentGoal: anObject [
	currentGoal := anObject
]

{ #category : #sync }
RHGoalListener >> desynchronize [
	"super desynchronize."
	self proxy controller node unsubscribe: goalsub .
	self proxy controller node unsubscribe: nextgoalsub .
	self proxy controller node unsubscribe: goalidxsub.
	self announcer unsubscribe: self."RHGoalSetEvent thoroughlyfor: self"
]

{ #category : #accessing }
RHGoalListener >> goalpub [
	^ goalpub
]

{ #category : #accessing }
RHGoalListener >> goals [
	^ goals
]

{ #category : #accessing }
RHGoalListener >> goals_index_topic [
	^ goals_index_topic
]

{ #category : #accessing }
RHGoalListener >> goals_index_topic: anObject [
	goals_index_topic := anObject
]

{ #category : #accessing }
RHGoalListener >> goals_topic [
	^ goals_topic
]

{ #category : #accessing }
RHGoalListener >> goals_topic: anObject [
	goals_topic := anObject
]

{ #category : #accessing }
RHGoalListener >> goalspub [
	^ goalspub
]

{ #category : #accessing }
RHGoalListener >> hibernate [
	^ hibernate
]

{ #category : #accessing }
RHGoalListener >> hibernate: anObject [
	hibernate := anObject
]

{ #category : #initialization }
RHGoalListener >> initialize [
	super initialize.
	topic := '/move_base_simple/goal'.
	status_topic := '/move_base/status'.
	goals_topic := '/robotcmd/goals'.
	next_goal_topic := '/robotcmd/next_goal'.
	goals_index_topic := '/robotcmd/goal_idx'.
	goalpub := nil.
	goals := OrderedCollection new.
	automatic_switch_goal := false.
	queueing_reached_goal := false.
	hibernate := true.
	counter := 0.
	currentGoal := 0.
]

{ #category : #accessing }
RHGoalListener >> name [
	^ 'Goal listener'
]

{ #category : #'as yet unclassified' }
RHGoalListener >> nextGoal [
	|  goal |
	[ self hibernate: true.
	^ self ] if: self goals isEmpty.
	[ ^self ] if: (self queueing_reached_goal = false and:[ self currentGoal = goals size ]).
	goal := self goals at: self nextGoalIndex.
	self counter: 10.	"ignore next 10 messages"
	self
		publishGoal:
			{goal getWorldPosition.
			goal orientation.
			self nextGoalIndex }.
	"2 seconds wait."
	self hibernate: false
]

{ #category : #'as yet unclassified' }
RHGoalListener >> nextGoalIndex [
	(self currentGoal + 1) > goals size ifTrue: [ ^1 ].
	^ self currentGoal + 1
]

{ #category : #accessing }
RHGoalListener >> next_goal_topic [
	^ next_goal_topic
]

{ #category : #accessing }
RHGoalListener >> next_goal_topic: anObject [
	next_goal_topic := anObject
]

{ #category : #initialization }
RHGoalListener >> propList [
	^ super propList
		,
			{(RHProperty
				from:
					{(#name -> #queueing_reached_goal ).
					(#type -> Boolean)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #next_goal_topic).
					(#type -> String)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #automatic_switch_goal).
					(#type -> Boolean)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #topic).
					(#type -> String)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #status_topic).
					(#type -> String)}
				holder: self).
			(RHProperty
				from:
					{(#name -> #goals_topic).
					(#type -> String)}
				holder: self).
			(RHProperty 
				from:
					{
						(#name -> #goals_index_topic).
						(#type -> String)
					} holder: self)}
]

{ #category : #'as yet unclassified' }
RHGoalListener >> publishGoal: arr [
	| q o |
	q := arr at: 1.
	o := (PhaROSRPYOrientation roll: 0 pitch: 0 yaw: (arr at: 2)) asQuaternion.
	goalpub
		send: [ :msg | 
			msg header stamp: PhaROSTimestamp new.
			msg header frame_id: self parent localframe.
			msg pose position x: q x.
			msg pose position y: 0 - q y.
			msg pose position z: 0.0.
			msg pose orientation x: o x.
			msg pose orientation y: o y.
			msg pose orientation z: o z.
			msg pose orientation w: o w ].
	arr size = 2 ifTrue: [ ^self ].
	goalidxpub send:[:msg| msg data: (arr at:3)].
]

{ #category : #'as yet unclassified' }
RHGoalListener >> publishGoals [
	| q o |
	[ ^self ] if: goalspub isNil.
	goalspub
		send: [ :msg | 
			msg header stamp: PhaROSTimestamp new.
			msg header frame_id: self parent localframe.
			self goals
				do: [ :g | 
					| m |
					q := g getWorldPosition.
					o := o := (PhaROSRPYOrientation roll: 0 pitch: 0 yaw: g orientation) asQuaternion.
					m := Geometry_msgsPose new.
					m position x: q x.
					m position y: 0 - q y.
					m position z: 0.0.
					m orientation x: o x.
					m orientation y: o y.
					m orientation z: o z.
					m orientation w: o w.
					msg poses add: m ] ]
]

{ #category : #accessing }
RHGoalListener >> queueing_reached_goal [
	^ queueing_reached_goal
]

{ #category : #accessing }
RHGoalListener >> queueing_reached_goal: anObject [
	queueing_reached_goal := anObject
]

{ #category : #removing }
RHGoalListener >> removeAllGoal [
	self goals removeAll.
	self publishGoals
]

{ #category : #removing }
RHGoalListener >> removeGoal: aGoal [
	[
	aGoal status: nil.
	self goals remove: aGoal.
	self resetGoalStatus ] if: (self goals includes: aGoal).
	self publishGoals
]

{ #category : #'as yet unclassified' }
RHGoalListener >> resetGoalStatus [
	| i |
	i := 1.
	self goals
		do: [ :g | 
			g status: i asString.
			i := i + 1 ]
]

{ #category : #initialization }
RHGoalListener >> setGoal: aGoal [
	"lock down the automatic goal allocation system"
	self hibernate: true.
	"do nothing if it is the current goal"
	[ ^ self hibernate: false ] if: aGoal = (goals at: self currentGoal ifAbsent:[nil]).
	goals isEmpty
		ifTrue: [ self addGoal: aGoal ].
	self currentGoal: (goals indexOf: aGoal) - 1.
	"call for the next goal"
	[self nextGoal] fork
]

{ #category : #'as yet unclassified' }
RHGoalListener >> statusCallback: msg [
	| busy	"fails" |
	busy := false.
	[ ^ self ] if: self hibernate.
	[ ^ self ] if: msg status_list isEmpty.
	[ self counter: self counter - 1.
	^ self ] if: self counter > 0.
	"Fail to reach the goal; simply go to the next goal"
	"fails := msg status_list select: [ :el | el status = 4 or: [ el status = 5 ] ].
	[ ^ self nextGoal ] unless: fails isEmpty."
	"verify if it is busy"
	msg status_list do: [ :stat | [ busy := true ] if: stat status ~= 3 ].
	[ ^ self ] if: busy.
	goals isEmpty ifFalse:[self announcer announce: (RHGoalReached for: (goals at:(self currentGoal)))].
	[ ^ self ] unless: self automatic_switch_goal.
	self nextGoal
]

{ #category : #accessing }
RHGoalListener >> status_topic [
	^ status_topic
]

{ #category : #accessing }
RHGoalListener >> status_topic: anObject [
	status_topic := anObject
]

{ #category : #sync }
RHGoalListener >> synchronize [
	goalpub ifNil: [ goalpub := self proxy controller node topicPublisher: self topic typedAs: 'geometry_msgs/PoseStamped' ].
	goalspub ifNil: [ goalspub := self proxy controller node topicPublisher: self goals_topic typedAs: 'geometry_msgs/PoseArray' ].
	goalidxpub ifNil: [ goalidxpub := self proxy controller node topicPublisher: self goals_index_topic typedAs: 'std_msgs/Int32' ].
	self announcer
		when: RHGoalSetEvent
		do: [ :e | 
			e type = #position
				ifTrue: [ "self clearGoals."
					e type = #onestop ifTrue:[ self automatic_switch_goal: false ].
					self publishGoal: e data ]
				ifFalse: [ self setGoal: e data ] ].
	self announcer when: RHGoalAddEvent do: [ :e | self addGoal: e data ].
	self announcer when: RHGoalRemoveEvent do: [ :e | self removeGoal: e data ].
	self announcer when: RHAnnotationClearEvent do:[:e| self removeAllGoal].
	goalsub := (self proxy controller node buildConnectionFor: status_topic)
		typedAs: 'actionlib_msgs/GoalStatusArray';
		for: [ :msg | self statusCallback: msg ];
		connect.
	nextgoalsub := (self proxy controller node buildConnectionFor: next_goal_topic )
		typedAs: 'std_msgs/Bool';
		for: [ :msg | [self nextGoal ] if: msg data ];
		connect.
	goalidxsub := (self proxy controller node buildConnectionFor: goals_index_topic )
		typedAs: 'std_msgs/Int32';
		for: [ :msg| self currentGoal: msg data ];
		connect
]
