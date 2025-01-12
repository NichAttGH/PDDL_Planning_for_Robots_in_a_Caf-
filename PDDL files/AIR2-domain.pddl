(define (domain AIR2-domain)
	(:requirements :adl :typing :fluents :time)

	(:types
		location order waiter - object
		Bar Table - location
		Drink - order
	)

	(:predicates
		(waiter-at ?w - waiter ?t - location)
		(start-moving-to ?w - waiter ?to - location)

		(tray-taken)
		(tray-empty)

		(carrying-3-drinks ?w - waiter)
		(carrying-2-drinks ?w - waiter)
		(carrying-1-drink ?w - waiter)
		(free-grippers ?w - waiter)

		(drink-ordered ?d - Drink ?t - location)

		(barista-free)
		(waiter-free ?w - waiter)

		(start-preparing-order ?d - Drink)
		(cold-drink ?d - Drink)
		(warm-drink ?d - Drink)
		(prepared-order ?d - Drink)
		(ready-order ?d - Drink)
		(carried-order ?d - order ?w - waiter)
		(delivered-cold-order ?d - order ?t - Table)
		(delivered-warm-order ?d - order ?t - Table)

		(table-clean ?t - location)
		(start-table-cleaning ?w - waiter ?t - location)

		(free-table ?t - location)
	)

	(:functions
		(distance ?t1 - location ?t2 - location)
		(table-size ?t - location)
		(drink-temp ?d - Drink)
		(velocity-with-tray ?w - waiter)
		(time-for-order)
		(time-to-clean-table ?w - waiter)
		(distance-from-goal ?w)

		(count-ready-on-bar)
		(cooldown-warm-drink)
	)

	; ---------- Action for the preparation of an order ----------

	(:action act-starting-to-prepare-cold
		:parameters (?d - order)
		:precondition (and
			(barista-free)
			(not (prepared-order ?d))
			(not (start-preparing-order ?d))
			(cold-drink ?d)
		)
		:effect (and
			(not (barista-free))
			(start-preparing-order ?d)
			(assign (time-for-order) 0)
		)
	)

	(:action act-starting-to-prepare-warm
		:parameters (?d - order)
		:precondition (and
			(barista-free)
			(not (prepared-order ?d))
			(not (start-preparing-order ?d))
			(warm-drink ?d)
		)
		:effect (and
			(not (barista-free))
			(start-preparing-order ?d)
			(assign (time-for-order) 0)

			(assign (cooldown-warm-drink) 5)
		)
	)

	(:process prs-preparing-order
		:parameters (?d - Drink)
		:precondition (start-preparing-order ?d)
		:effect (increase (time-for-order) #t)
	)

	(:event evt-order-preparation-terminated
		:parameters (?d - Drink)
		:precondition (and
			(start-preparing-order ?d)
			(>= (time-for-order) (+ 3 (* 2 (drink-temp ?d))))
		)
		:effect (and
			(not (start-preparing-order ?d))
			(prepared-order ?d)
			(ready-order ?d)
			(barista-free)
			(increase (count-ready-on-bar) 1)
		)
	)

	; ---------- Control of the time within which the warm drink becomes cold ----------

	(:process prs-cooldown-to-cold
		:parameters (?d - Drink)
		:precondition (and
			(warm-drink ?d)
			(ready-order ?d)
		)
		:effect (and
			(decrease (cooldown-warm-drink) (*#t 1))
		)
	)

	(:event evt-cooldown-warm-drink
		:parameters (?d - Drink)
		:precondition (and
			(< (cooldown-warm-drink) 1)
			(warm-drink ?d)
		)
		:effect (and
			(not (warm-drink ?d))
		)
	)

	; ---------- Actions to delivery the order ----------

	(:action act-pick-up-cold-order-prepared
		:parameters (?t - Bar ?w - waiter ?d - order)
		:precondition (and
			(= (velocity-with-tray ?w) 0)
			(waiter-at ?w ?t)
			(ready-order ?d)
			(free-grippers ?w)
			(cold-drink ?d)
		)
		:effect (and
			(not (ready-order ?d))
			(not (free-grippers ?w))
			(carried-order ?d ?w)
			(decrease (count-ready-on-bar) 1)
		)
	)

	(:action act-pick-up-warm-order-prepared
		:parameters (?t - Bar ?w - waiter ?d - order)
		:precondition (and
			(= (velocity-with-tray ?w) 0)
			(waiter-at ?w ?t)
			(ready-order ?d)
			(free-grippers ?w)
			(warm-drink ?d)

			(= (cooldown-warm-drink) 5)
		)
		:effect (and
			(not (ready-order ?d))
			(not (free-grippers ?w))
			(carried-order ?d ?w)
			(decrease (count-ready-on-bar) 1)
		)
	)

	(:action act-put-down-cold-order-prepared
		:parameters (?t - Table ?w - waiter ?d - order)
		:precondition (and
			(drink-ordered ?d ?t)
			(= (velocity-with-tray ?w) 0)
			(waiter-at ?w ?t)
			(carried-order ?d ?w)
			(cold-drink ?d)
		)
		:effect (and
			(delivered-cold-order ?d ?t)
			(not (carried-order ?d ?w))
			(free-grippers ?w)
		)
	)

	(:action act-put-down-warm-order-prepared
		:parameters (?t - Table ?w - waiter ?d - order)
		:precondition (and
			(drink-ordered ?d ?t)
			(= (velocity-with-tray ?w) 0)
			(waiter-at ?w ?t)
			(carried-order ?d ?w)
			(warm-drink ?d)

			(>= (cooldown-warm-drink) 1)
		)
		:effect (and
			(delivered-warm-order ?d ?t)
			(not (carried-order ?d ?w))
			(free-grippers ?w)
		)
	)

	; ---------- Action for the movements of the waiter ----------

	(:action act-starting-the-movement
		:parameters (?from - location ?to - location ?w - waiter)
		:precondition (and
			(waiter-free ?w)
			(waiter-at ?w ?from)
		)
		:effect (and
			(free-table ?from)
			(not (waiter-free ?w))
			(not (waiter-at ?w ?from))
			(start-moving-to ?w ?to)
			(assign
				(distance-from-goal ?w)
				(distance ?from ?to))
		)
	)

	(:process prs-movement
		:parameters (?w - waiter ?to - location)
		:precondition (start-moving-to ?w ?to)
		:effect (decrease
			(distance-from-goal ?w)
			(* #t (- 2 (velocity-with-tray ?w))))
	)

	(:event evt-movement-finished
		:parameters (?w - waiter ?to - location)
		:precondition (and
			(free-table ?to)
			(start-moving-to ?w ?to)
			(<= (distance-from-goal ?w) 0)
		)
		:effect (and
			(not (free-table ?to))
			(not (start-moving-to ?w ?to))
			(waiter-at ?w ?to)
			(waiter-free ?w)
		)
	)

	; ---------- Action to clean the table ----------

	(:action act-clean-table
		:parameters (?t - location ?w - waiter)
		:precondition (and
			(waiter-free ?w)
			(not (table-clean ?t))
			(waiter-at ?w ?t)
			(free-grippers ?w)
		)
		:effect (and
			(start-table-cleaning ?w ?t)
			(assign
				(time-to-clean-table ?w)
				(* 2 (table-size ?t)))
			(not (waiter-free ?w))
		)
	)

	(:process prs-cleaning-table
		:parameters (?t - location ?w - waiter)
		:precondition (start-table-cleaning ?w ?t)
		:effect (decrease (time-to-clean-table ?w) #t)
	)

	(:event evt-end-clean-table
		:parameters (?t - location ?w - waiter)
		:precondition (and
			(start-table-cleaning ?w ?t)
			(<= (time-to-clean-table ?w) 0)
		)
		:effect (and
			(not (start-table-cleaning ?w ?t))
			(table-clean ?t)
			(waiter-free ?w)
		)
	)

	; ---------- Actions to carry on tray ----------

	(:action act-pick-2-drinks-with-tray
		:parameters (?t - Bar ?w - waiter ?d1 - order ?d2 - order)
		:precondition (and
			(waiter-at ?w ?t)
			(free-grippers ?w)
			(not (tray-taken))(tray-empty)
			(ready-order ?d1)(ready-order ?d2)
			(and (cold-drink ?d1) (cold-drink ?d2))
			(>= (count-ready-on-bar) 2)
		)
		:effect (and
			(not (ready-order ?d1))
			(not (ready-order ?d2))
			(not (free-grippers ?w))
			(tray-taken)
			(not (tray-empty))
			(assign (velocity-with-tray ?w) 1)
			(carried-order ?d1 ?w)
			(carried-order ?d2 ?w)
			(carrying-2-drinks ?w)
			(decrease (count-ready-on-bar) 2)
		)
	)

	(:action act-pick-3-drinks-with-tray
		:parameters (?t - Bar ?w - waiter ?d3 - order)
		:precondition (and
			(carrying-2-drinks ?w)
			(waiter-at ?w ?t)
			(ready-order ?d3)
			(cold-drink ?d3)
			(>= (count-ready-on-bar) 1)
		)
		:effect (and
			(not(ready-order ?d3))
			(carried-order ?d3 ?w)
			(not (carrying-2-drinks ?w))
			(carrying-3-drinks ?w)
			(decrease (count-ready-on-bar) 1)
		)
	)

	; ---------- Actions to put down drinks ----------

	(:action act-put-down-third-drink
		:parameters (?t - Table ?w - waiter ?d3 - order)
		:precondition (and
			(carrying-3-drinks ?w)
			(waiter-at ?w ?t)
			(drink-ordered ?d3 ?t)
			(carried-order ?d3 ?w)
			(cold-drink ?d3)
		)
		:effect (and
			(not (carrying-3-drinks ?w))
			(carrying-2-drinks ?w)
			(not (carried-order ?d3 ?w))
			(delivered-cold-order ?d3 ?t)
		)
	)

	(:action act-put-down-second-drink
		:parameters (?t - Table ?w - waiter ?d2 - order)
		:precondition (and
			(carrying-2-drinks ?w)
			(waiter-at ?w ?t)
			(drink-ordered ?d2 ?t)
			(carried-order ?d2 ?w)
			(cold-drink ?d2)
		)
		:effect (and
			(not (carrying-2-drinks ?w))
			(carrying-1-drink ?w)
			(not (carried-order ?d2 ?w))
			(delivered-cold-order ?d2 ?t)
		)
	)

	(:action act-put-down-first-drink
		:parameters (?t - Table ?w - waiter ?d1 - order)
		:precondition (and
			(carrying-1-drink ?w)
			(waiter-at ?w ?t)
			(drink-ordered ?d1 ?t)
			(carried-order ?d1 ?w)
			(cold-drink ?d1)
		)
		:effect (and
			(tray-empty)
			(not (carrying-1-drink ?w))
			(not (carried-order ?d1 ?w))
			(delivered-cold-order ?d1 ?t)
		)
	)

	; ---------- Action to put down the tray ----------

	(:action act-to-leave-the-tray
		:parameters (?t - Bar ?w - waiter)
		:precondition (and
			(= (velocity-with-tray ?w) 1)
			(tray-empty)
			(waiter-at ?w ?t)
		)
		:effect (and
			(assign (velocity-with-tray ?w) 0)
			(not (tray-taken))
			(free-grippers ?w)
		)
	)
)