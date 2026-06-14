class_name Enums

enum AnimContext {
	## Default animation, has no priority
	NONE,
	## Idle animation, lowest priority
	DANCE,
	## Singing, prioritized over `AnimContext.DANCE`
	SING,
	## Missing, acts similarly to `AnimContext.SING`
	MISS,
	## Special, doesn't allow `AnimContext.SING` or `AnimContext.MISS` animations to override
	SPECIAL,
	## Locked, similar to `AnimContext.SPECIAL`, but doesn't return context to `AnimContext.NONE` on finish
	LOCK
}
