(define (problem AIR2-problem2)   
	(:domain AIR2-domain)
	(:objects 
		bar - Bar
		tab1 tab2 tab3 tab4 - Table 
        d1 d2 d3 d4 - Drink
        w - waiter
	)

	(:init
		(free-grippers w)
		(waiter-at w bar)
		(barista-free)
		(waiter-free w)
		(tray-empty)
		
		(= (velocity-with-tray w) 0)

		; --------- Temperature of drinks will be = 0 for cold drink and 1 for warm drink ---------

		(cold-drink d1)
		(cold-drink d2)
		(warm-drink d3)
		(warm-drink d4)

		(= (drink-temp d1) 0)
		(= (drink-temp d2) 0)
		(= (drink-temp d3) 1)
		(= (drink-temp d4) 1)

		; --------- Distances ---------

		(= (distance bar tab1) 2) 		(= (distance tab1 bar) 2)
		(= (distance bar tab2) 2) 		(= (distance tab2 bar) 2)
		(= (distance tab1 tab2) 1)		(= (distance tab2 tab1) 1)
		
		(= (distance bar tab3) 3) 		(= (distance tab3 bar) 3)
		(= (distance tab1 tab3) 1) 		(= (distance tab3 tab1) 1)
		(= (distance tab3 tab2) 1)		(= (distance tab2 tab3) 1)
		
		(= (distance bar tab4) 3) 		(= (distance tab4 bar) 3)
		(= (distance tab1 tab4) 1) 		(= (distance tab4 tab1) 1)
		(= (distance tab4 tab2) 1)		(= (distance tab2 tab4) 1)
		(= (distance tab4 tab3) 1)		(= (distance tab3 tab4) 1)

		; --------- Table sizes ---------

		(= (table-size tab1) 1)
		(= (table-size tab2) 1)
		(= (table-size tab3) 2)
		(= (table-size tab4) 1)

		; --------- Assignment of drinks for each table ---------

        (drink-ordered d1 tab3)
       	(drink-ordered d2 tab3)
		(drink-ordered d3 tab3)
		(drink-ordered d4 tab3)

		(free-table tab1)
		(free-table tab2)
		(free-table tab3)
		(free-table tab4)
    )
        
	(:goal 	
		(and 
			(delivered-cold-order d1 tab3)
			(delivered-cold-order d2 tab3)
			(delivered-warm-order d3 tab3)
			(delivered-warm-order d4 tab3)

			(table-clean tab1)
		)
	)
)
