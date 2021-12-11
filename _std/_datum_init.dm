var/global/waiting_inits = null
var/global/init_paused = 0

// TODO refactor this into a single state var with disposed and qdeled
/datum/var/tmp/init_finished = FALSE

proc/pause_init()
	global.init_paused++
	if(global.init_paused > 1)
		return
	global.waiting_inits = list()

proc/unpause_init()
	global.init_paused--
	if(global.init_paused > 0)
		return
	var/list/inits_to_process = global.waiting_inits
	global.waiting_inits = null // to make sure things happen correctly if some Init() pauses again
	for(var/datum/D as anything in inits_to_process)
		if(!QDELETED(D))
			D.Init(arglist(inits_to_process[D]))
			D.init_finished = TRUE

/datum/New(...)
	SHOULD_CALL_PARENT(TRUE)
	..()
	if(global.init_paused)
		global.waiting_inits[src] = args.Copy()
	else
		Init(arglist(args))
		src.init_finished = TRUE

/datum/proc/Init(...)
	SHOULD_CALL_PARENT(TRUE)
	// SHOULD_NOT_SLEEP(TRUE) // uncomment when the 300+ issues are fixed

#define INIT(ARGS...) New(ARGS) ..(); Init(ARGS)
#define INIT_TYPE(TYPE, ARGS...) TYPE/New(ARGS) ..(); TYPE/Init(ARGS)
