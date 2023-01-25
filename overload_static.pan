ground electrical gnd

parameters DYN=0
parameters D=2

options outintnodes=1 writeparams=no compile=1 mindevres=1u

parameters BASE_CASE = 1;

// DEFINE ONE OF THE THREE CASES ONLY
;#define BASE_CASE
;#define CASE_EV
#define CASE_EV_SYNTH

#ifndef BASE_CASE
parameters BASE_CASE = 0;

; SELECT CHEMISTRY
;#define LFP
;#define LMO
;#define NMC
#define NCA

; SELECT CHARGING MODE
;#define CCCV
#define CPCV

; DEFINE BATTERY PACK PARAMETERS BASED ON PREVIOUS DEFINITIONS
include "cases.txt"
#endif

; SELECT WHETHER YOU WANT TO DO SWEEP ANALYSIS AND SAVE DATA OR NOT
#define SWEEP
#define SAVE

parameters TSTOP         = ceil(2.5*3600);
parameters TAP           = 1;
parameters EV_SOC_INIT   = 0.1;
parameters LAMBDA        = 20/100;

; SWEEPING PARAMETERS
parameters START_SOC     = 0.1;
parameters END_SOC       = 0.9;
parameters STEP_SOC      = 0.1;

#define RESET


#ifndef SWEEP
Dc0    dc nettype=1 sparse=3 print=no uic=1
Tr0  tran nettype=1 sparse=3 tstop=30 uic=1 acntrl=3 iabstol=0.1u tmin=0.1m
Dc1    dc nettype=1 sparse=3 restart=no time=0 print=yes save="Dc.dc" ;load="Dc.dc"
Pz     pz nettype=1 pf=1 shift=8.030027e-01
;Tr1  tran nettype=1 sparse=3 tstop=TSTOP ireltol=0.1m vreltol=0.1m tmin=0.1m
#else
include "save_static.txt"
#endif


// ANALYSES
options rawkeep=yes topcheck=2 writeparams=no

begin power

// Busses
Bus1  bus1  powerbus vb=69k   v0=1.06    theta0= 0        
Bus2  bus2  powerbus vb=69k   v0=1.045   theta0=-4.9841   
Bus3  bus3  powerbus vb=69k   v0=1.01    theta0=-12.7304  
Bus4  bus4  powerbus vb=69k   v0=1.016   theta0=-10.2804  
Bus5  bus5  powerbus vb=69k   v0=1.0185  theta0=-8.7747   
Bus6  bus6  powerbus vb=13.8k v0=1.07    theta0=-14.3704  
Bus7  bus7  powerbus vb=13.8k v0=1.0534  theta0=-13.2851  
Bus8  bus8  powerbus vb=18k   v0=1.09    theta0=-13.2851  
Bus9  bus9  powerbus vb=13.8k v0=1.0394  theta0=-14.8643  
Bus10 bus10 powerbus vb=13.8k v0=1.0373  theta0=-15.0599  
Bus11 bus11 powerbus vb=13.8k v0=1.0499  theta0=-14.8367  
Bus12 bus12 powerbus vb=13.8k v0=1.0539  theta0=-15.2221  
Bus13 bus13 powerbus vb=13.8k v0=1.048   theta0=-15.2724  
Bus14 bus14 powerbus vb=13.9k v0=1.025   theta0=-16.0604  

// Shunt (A COSA SERVE QUESTO?)
;Shunt bus9 powershunt prating=100M vrating=13.8k b=0.19

// Syncronous generators
G1  bus1_0 avr1 gnd omega1 powergenerator slack=true \
             vrating=69.0k vg=1.06 \
             prating=615M pg=100*2.324/615*(1+LAMBDA) \
             pmax=999.9*100/615 pmin=-999.9*100/615 \
	     qmax=9.9*100/615 qmin=-9.9*100/616 \
	     d=D m=10.296 td0p=7.4 td0s=0.03 \
	     tq0s=0.033 xd=0.8979 xdp=0.2995 xds=0.23 \
             xl=0.2396 xq=0.646 xqp=0.646 xqs=0.4 ra=0 \
	     omegab=60*2*pi type=52 

POWER_G1 bus1_0 p_G1 gnd q_G1 gnd bus1 powerec type=4

G2  bus2_0 avr2 powergenerator vrating=69.0k vg=1.045 \
             prating=60M pg=100*0.4/60*(1+LAMBDA) \
	     pmax=1.0*100/60 pmin=0*100/60 \
             qmax=0.5*100/60 qmin=-0.4*100/60 \
	     d=D m=13.08 td0p=6.1 td0s=0.04 \
	     tq0p=0.3 tq0s=0.099 \
	     ra=0.0031 xd=1.05 xdp=0.185 xds=0.13 xq=0.98 xqp=0.36 xqs=0.13 \
	     omegab=60*2*pi type=6

POWER_G2 bus2_0 p_G2 gnd q_G2 gnd bus2 powerec type=4

G3  bus3_0 avr3 powergenerator vrating=69.0k vg=1.01 \
             prating=60M pg=0*(1+LAMBDA)\
	     pmax=1.0*100/60 pmin=0*100/60 \
             qmax=0.4*100/60 \
	     d=D m=13.08 td0p=6.1 td0s=0.04 \
	     tq0p=0.3 tq0s=0.099 \
	     ra=0.0031 xd=1.05 xdp=0.185 xds=0.13 xq=0.98 xqp=0.36 xqs=0.13 \
	     omegab=60*2*pi type=6

POWER_G3 bus3_0 p_G3 gnd q_G3 gnd bus3 powerec type=4

G6  bus6_0 avr6 powergenerator vrating=13.8k vg=1.07 \
             prating=25M pg=0*(1+LAMBDA) \
	     pmax=1.0*100/25 pmin=0*100/25 \
             qmax=0.24*100/25 qmin=-0.06*100/25 \
	     d=D m=10.12 td0p=4.75 td0s=0.06 \
	     tq0p=1.5 tq0s=0.21 \
	     ra=0.0041 xd=1.25 xdp=0.232 xds=0.12 xl=0.134 xq=1.22 xqp=0.715 \
	     xqs=0.12 omegab=60*2*pi type=6

POWER_G6 bus6_0 p_G6 gnd q_G6 gnd bus6 powerec type=4

G8  bus8_0 avr8 powergenerator vrating=18.0k vg=1.09 \
             prating=25M pg=0*(1+LAMBDA) \
	     pmax=1.0*100/25 pmin=0*100/25 \
             qmax=0.24*100/25 qmin=-0.06*100/25 \
	     d=D m=10.12 td0p=4.75 td0s=0.06 \
	     tq0p=1.5 tq0s=0.21 ra=0.0041 xd=1.25 \
	     xdp=0.232 xds=0.12 xl=0.134 xq=1.22 xqp= 0.715 xqs=0.12 \
	     omegab=60*2*pi type=6

POWER_G8 bus8_0 p_G8 gnd q_G8 gnd bus8 powerec type=4

// Voltage regulators
Avr1  bus1_0 avr1      poweravr ka=180 kf=0.00085 ta=0.02 te=0.19 tf=1.0 ke=1 \
	     vmax=9.99 vmin=0.0 vrating=69k

Avr2  bus2_0 avr2  poweravr ka=20.0 kf=0.001 ta=0.02 te=1.98 tf=1.0 ke=1 \
	     vmax=2.05*0+12 vmin = 0.0 vrating=69k

Avr3  bus3_0 avr3  poweravr Ka=20.0 Kf=0.001 Ta=0.02 Te=1.98 Tf=1.0 ke=1 \
	     vmax=1.8*0+12 vmin=0.0 vrating=69k

Avr6  bus6_0 avr6  poweravr Ka=20.0 Ta=0.02 Kf=0.001 Tf=1.0 Te=0.7 ke=1 \
	     vmax=2.4*0+12 vmin=1.0 vrating=13.8k

Avr8  bus8_0 avr8  poweravr Ka=20.0 Kf=0.001 Ta=0.02 Te=0.7 Tf=1.0 ke=1 \
	     vmax=2.4 vmin=0 vrating=18k


// Lines
Line1#2   bus1   bus2_aux1 powerline prating=100M vrating=69.0k \
			b=0.0528 r=0.01938 x=0.05917 dynamic=DYN
Line1#5   bus1   bus5_aux1 powerline prating=100M vrating=69.0k \
			b=0.0492 r=0.05403 x=0.22304 dynamic=DYN
Line2#3   bus3   bus2_aux2 powerline prating=100M vrating=69.0k \
			b=0.0438 r=0.04699 x=0.19797 dynamic=DYN
Line2#4   bus2   bus4_aux1 powerline prating=100M vrating=69.0k \
			b=0.0374 r=0.05811 x=0.17632 dynamic=DYN
Line2#5   bus2   bus5_aux2 powerline prating=100M vrating=69.0k \
			b=0.034  r=0.05695 x=0.17388 dynamic=DYN
Line3#4   bus3   bus4_aux2 powerline prating=100M vrating=69.0k \
			b=0.0346 r=0.06701 x=0.17103 dynamic=DYN
Line4#5   bus5   bus4_aux3 powerline prating=100M vrating=69.0k \
			b=0.0128 r=0.01335 x=0.04211 dynamic=DYN
Line6#11  bus6  bus11_aux1 powerline prating=100M vrating=13.8k \
			b=0      r=0.09498 x=0.19890 dynamic=DYN
Line6#12  bus6  bus12_aux1 powerline prating=100M vrating=13.8k \
			b=0      r=0.12291 x=0.25581 dynamic=DYN
Line6#13  bus6  bus13_aux1 powerline prating=100M vrating=13.8k \
			b=0      r=0.06615 x=0.13027 dynamic=DYN
Line7#9   bus7   bus9_aux1 powerline prating=100M vrating=13.8k \
			b=0      r=0       x=0.11001 dynamic=DYN
Line9#10  bus9  bus10_aux1 powerline prating=100M vrating=13.8k \
			b=0      r=0.03181 x=0.08450 dynamic=DYN
Line9#14  bus9  bus14_aux1 powerline prating=100M vrating=13.8k \
			b=0      r=0.12711 x=0.27038 dynamic=DYN
Line10#11 bus11 bus10_aux2 powerline prating=100M vrating=13.8k \
			b=0      r=0.08205 x=0.19207 dynamic=DYN
Line12#13 bus12 bus13_aux2 powerline prating=100M vrating=13.8k \
			b=0      r=0.22092 x=0.19988 dynamic=DYN
Line13#14 bus14 bus13_aux3 powerline prating=100M vrating=13.8k \
			b=0      r=0.17093 x=0.34802 dynamic=DYN

I_Line1#2   bus2_aux1  i1_d  gnd i1_q  gnd bus2  powerec type=5
I_Line1#5   bus5_aux1  i2_d  gnd i2_q  gnd bus5  powerec type=5
I_Line2#3   bus2_aux2  i3_d  gnd i3_q  gnd bus2  powerec type=5
I_Line2#4   bus4_aux1  i4_d  gnd i4_q  gnd bus4  powerec type=5
I_Line2#5   bus5_aux2  i5_d  gnd i5_q  gnd bus5  powerec type=5
I_Line3#4   bus4_aux2  i6_d  gnd i6_q  gnd bus4  powerec type=5
I_Line4#5   bus4_aux3  i7_d  gnd i7_q  gnd bus4  powerec type=5
I_Line6#11  bus11_aux1 i8_d  gnd i8_q  gnd bus11 powerec type=5
I_Line6#12  bus12_aux1 i9_d  gnd i9_q  gnd bus12 powerec type=5
I_Line6#13  bus13_aux1 i10_d gnd i10_q gnd bus13 powerec type=5
I_Line7#9   bus9_aux1  i11_d gnd i11_q gnd bus9  powerec type=5
I_Line9#10  bus10_aux1 i12_d gnd i12_q gnd bus10 powerec type=5
I_Line9#14  bus14_aux1 i13_d gnd i13_q gnd bus14 powerec type=5
I_Line10#11 bus10_aux2 i14_d gnd i14_q gnd bus10 powerec type=5
I_Line12#13 bus13_aux2 i15_d gnd i15_q gnd bus13 powerec type=5
I_Line13#14 bus13_aux3 i16_d gnd i16_q gnd bus13 powerec type=5


// Transformers
Tr4#7 bus7 bus4 powertransformer prating=100M vrating=13.8k \
			kt=69.0/13.8 a=0.978 r=0 x=0.20912 dynamic=DYN
Tr4#9 bus9 bus4 powertransformer prating=100M vrating=13.8k \
			kt=69.0/13.8 a=0.969 r=0 x=0.55618 dynamic=DYN
Tr5#6 bus6 bus5 powertransformer prating=100M vrating=13.8k \
			kt=69.0/13.8 a=0.932 r=0 x=0.25202 dynamic=DYN
Tr7#8 bus7 bus8 powertransformer prating=100M vrating=13.8k \
                        kt=18.0/13.8 a=1     r=0 x=0.17615 dynamic=DYN

// Loads
Ln1   bus2 powerload prating=100M vrating=69k   pc=0.217*(1+LAMBDA*BASE_CASE) qc=0.127  limit=false
Ln2   bus3 powerload prating=100M vrating=69k   pc=0.942*(1+LAMBDA*BASE_CASE) qc=0.19   limit=false
Ln3   bus4 powerload prating=100M vrating=69k   pc=0.478*(1+LAMBDA*BASE_CASE) qc=-0.039 limit=false
Ln4   bus5 powerload prating=100M vrating=69k   pc=0.076*(1+LAMBDA*BASE_CASE) qc=0.016  limit=false
Ln5   bus6 powerload prating=100M vrating=13.8k pc=0.112*(1+LAMBDA*BASE_CASE) qc=0.075  limit=false
Ln6   bus9 powerload prating=100M vrating=13.8k pc=0.295*(1+LAMBDA*BASE_CASE) qc=0.116  limit=false
Ln7  bus10 powerload prating=100M vrating=13.8k pc=0.090*(1+LAMBDA*BASE_CASE) qc=0.058  limit=false
Ln8  bus11 powerload prating=100M vrating=13.8k pc=0.035*(1+LAMBDA*BASE_CASE) qc=0.018  limit=false
Ln9  bus12 powerload prating=100M vrating=13.8k pc=0.061*(1+LAMBDA*BASE_CASE) qc=0.016  limit=false
Ln10 bus13 powerload prating=100M vrating=13.8k pc=0.135*(1+LAMBDA*BASE_CASE) qc=0.058  limit=false
Ln11 bus14 powerload prating=100M vrating=13.8k pc=0.149*(1+LAMBDA*BASE_CASE) qc=0.050  limit=false

#ifdef CASE_EV_SYNTH
EV1  bus2 EV_POW V1_NOM=69k V2_NOM=400/sqrt(3) S_NOM=100M*0.217*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV2  bus3 EV_POW V1_NOM=69k V2_NOM=400/sqrt(3) S_NOM=100M*0.942*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV3  bus4 EV_POW V1_NOM=69k V2_NOM=400/sqrt(3) S_NOM=100M*0.478*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV4  bus5 EV_POW V1_NOM=69k V2_NOM=400/sqrt(3) S_NOM=100M*0.076*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV5  bus6 EV_POW V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=100M*0.112*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV6  bus9 EV_POW V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=100M*0.295*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV7  bus10 EV_POW V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=100M*0.090*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV8  bus11 EV_POW V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=100M*0.035*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV9  bus12 EV_POW V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=100M*0.061*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV10  bus13 EV_POW V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=100M*0.135*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL

EV11  bus14 EV_POW V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=100M*0.149*LAMBDA \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL
#endif

#ifdef CASE_EV
EV1  bus2 EV \
	V1_NOM=69k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.217*LAMBDA/EV_CHARGER_P)

EV2  bus3 EV \
	V1_NOM=69k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.942*LAMBDA/EV_CHARGER_P)

EV3  bus4 EV \
	V1_NOM=69k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT \ 
	N_EV=floor(100M*0.478*LAMBDA/EV_CHARGER_P)

EV4  bus5 EV \
	V1_NOM=69k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.076*LAMBDA/EV_CHARGER_P)

EV5  bus6 EV \
	V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.112*LAMBDA/EV_CHARGER_P)

EV6  bus9 EV \
	V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.295*LAMBDA/EV_CHARGER_P)


EV7  bus10 EV \
	V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.090*LAMBDA/EV_CHARGER_P)

EV8  bus11 EV \
	V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.035*LAMBDA/EV_CHARGER_P)

EV9  bus12 EV \
	V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.061*LAMBDA/EV_CHARGER_P)

EV10  bus13 EV \
	V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.135*LAMBDA/EV_CHARGER_P)

EV11  bus14 EV \
	V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	\ 
	N_EV=floor(100M*0.149*LAMBDA/EV_CHARGER_P)

#endif

// Include subckt of EV and its synthetic representation
include EV.txt

end

global tap
Vto   tap   gnd  vsource vdc=1

include EV.mod

model DIO diode imax=10k rs=1m
model SW vswitch ron=1m roff=1M voff=0.4 von=0.6
model LOOKUP_TABLE  nport veriloga="lookup_table.va"     verilogaprotected=yes 
model CELL          nport veriloga="cell.va"             verilogaprotected=yes 
model DCDC_CONTROL  nport veriloga="DCDC.va"             verilogaprotected=yes
model EV_LOAD       nport veriloga="EV_LOAD.va" 	 verilogaprotected=yes
