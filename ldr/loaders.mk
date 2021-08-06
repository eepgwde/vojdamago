## Prep for q/kdb

include ../trns/defs.mk 

X_SRCS0 = cwyinventory.load.q fwyinventory.load.q rcia.load.q defects.load.q cwyenquiries.load.q claims.load.q claims0.load.q fcia.load.q traffic0.load.q weather.load.q imputes0.load.q

all: $(X_SRCS0)

view2:
	@echo $(X_SRCS0)



cwyinventory.load.q: $(X_BASE)/in/CWY-inventory.csv 
	Qp -file $+ -zh -load csvguess.q 

fwyinventory.load.q: $(X_BASE)/in/FWY-inventory.csv 
	Qp -file $+ -zh -load csvguess.q 

rcia.load.q: $(X_BASE)/in/RCI-A.csv 
	Qp -file $+ -zh -load csvguess.q 

defects.load.q: $(X_BASE)/in/defects.csv 
	Qp -file $+ -zh -load csvguess.q 

cwyenquiries.load.q: $(X_BASE)/in/CWY-enquiries.csv 
	Qp -file $+ -zh -load csvguess.q 

# european dates
claims.load.q: $(X_BASE)/in/claims.csv 
	Qp -file $+ -z1 -zh -load csvguess.q 

claims0.load.q: $(X_BASE)/in/claims0.csv 
	Qp -file $+ -z1 -zh -load csvguess.q 

fcia.load.q: $(X_BASE)/in/fcia.csv 
	Qp -file $+ -zh -load csvguess.q 

weather.load.q: $(X_BASE)/in/weather.csv 
	Qp -file $+ -zh -ss -exit -load csvguess.q

traffic0.load.q: $(X_BASE)/in/traffic0.csv 
	Qp -file $+ -z1 -zh -ss -load csvguess.q

imputes0.load.q: $(X_BASE)/in/imputes0.csv 
	Qp -file $+ -z1 -zh -ss -load csvguess.q

# fwyenq0.load.q: $(X_BASE)/in/fwyenq0.csv 
#	Qp -file $+ -zh -load csvguess.q 

# fwyenq0.load.q: $(X_BASE)/in/fwyenq0.csv 
#	Qp -file $+ -zh -load csvguess.q 

# fwyenq0.load.q: $(X_BASE)/in/fwyenq0.csv 
#	Qp -file $+ -zh -load csvguess.q 

