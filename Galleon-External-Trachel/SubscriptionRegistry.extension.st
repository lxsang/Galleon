Extension { #name : #SubscriptionRegistry }

{ #category : #'*Galleon-External-Trachel' }
SubscriptionRegistry >> getInteractionForClass: eventClass [
	"Return true if the receiver has a callback subscripbed for the event class"
	subscriptions do: [ :sub | 
		((sub subscriber class == eventClass) or: 
			[ sub subscriber class inheritsFrom: eventClass ]) ifTrue: [ ^ sub subscriber ] ].

	self error: 'Please, use handleEventClass: before getting the interaction'	

]

{ #category : #'*Galleon-External-Trachel' }
SubscriptionRegistry >> getInteractionsForClass: eventClass [
	"Return the list of subscription for a given Event class"
	| answer |
	answer := OrderedCollection new.
	subscriptions do: [ :sub | 
		((sub subscriber class == eventClass) or: 
			[ sub subscriber class inheritsFrom: eventClass ]) ifTrue: [ answer add: sub subscriber ] ].
	^ answer
]

{ #category : #'*Galleon-External-Trachel' }
SubscriptionRegistry >> handleEventClass: eventClass [
	"Return true if the receiver has a callback subscripbed for the event class"
	^ subscriptions anySatisfy: [ :sub | 
		(sub announcementClass == eventClass) or: 
			[ sub announcementClass inheritsFrom: eventClass ] ]
]

{ #category : #'*Galleon-External-Trachel' }
SubscriptionRegistry >> handleSubscriberClass: eventClass [
	"Return true if the receiver has a callback subscripbed for the event class"
	^ subscriptions anySatisfy: [ :sub | 
		(sub subscriber class == eventClass) or: 
			[ sub subscriber class inheritsFrom: eventClass ] ]
]

{ #category : #'*Galleon-External-Trachel' }
SubscriptionRegistry >> trSubscriptions [
	^ subscriptions 
]
