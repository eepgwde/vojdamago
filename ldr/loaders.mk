## Prep for q/kdb

X_SRCS0 = cwyinventory.load.q fwyinventory.load.q rcia.load.q defects.load.q cwyenquiries.load.q claims.load.q claims0.load.q fcia.load.q traffic0.load.q weather.load.q

view2:
	@echo $(X_SRCS0)

prep-local:: $(X_SRCS0)

cwyinventory.load.q: in/CWY-inventory.csv 
	Qp -file $+ -zh -load csvguess.q 

fwyinventory.load.q: in/FWY-inventory.csv 
	Qp -file $+ -zh -load csvguess.q 

rcia.load.q: in/RCI-A.csv 
	Qp -file $+ -zh -load csvguess.q 

defects.load.q: in/defects.csv 
	Qp -file $+ -zh -load csvguess.q 

cwyenquiries.load.q: in/CWY-enquiries.csv 
	Qp -file $+ -zh -load csvguess.q 

# european dates
claims.load.q: in/claims.csv 
	Qp -file $+ -z1 -zh -load csvguess.q 

claims0.load.q: in/claims0.csv 
	Qp -file $+ -z1 -zh -load csvguess.q 

fcia.load.q: in/fcia.csv 
	Qp -file $+ -zh -load csvguess.q 

weather.load.q: in/weather.csv 
	Qp -file $+ -zh -ss -exit -load csvguess.q

traffic0.load.q: in/traffic0.csv 
	Qp -file $+ -z1 -zh -ss -load csvguess.q

# fwyenq0.load.q: in/fwyenq0.csv 
#	Qp -file $+ -zh -load csvguess.q 

