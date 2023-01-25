ground electrical gnd

parameters DYN=0
parameters D=2

options outintnodes=1 writeparams=no compile=1 mindevres=1u

parameters BASE_CASE = 1;

; SELECT CHEMISTRY
#define LFP
;#define LMO
;#define NMC
;#define NCA

; SELECT CHARGING MODE
;#define CCCV
#define CPCV

; DEFINE BATTERY PACK PARAMETERS BASED ON PREVIOUS DEFINITIONS
include "cases.txt"

; SELECT WHETHER YOU WANT TO DO SWEEP ANALYSIS AND SAVE DATA OR NOT
;#define SWEEP
;#define SAVE

parameters TSTOP         = 15;
parameters TAP           = 1;
parameters EV_SOC_INIT   = 0.1;

; SWEEPING PARAMETERS
parameters START_SOC     = 0.1;
parameters END_SOC       = 0.9;
parameters STEP_SOC      = 0.1/2;
parameters START_TAP     = 1.30;
parameters END_TAP       = 0.80;
parameters STEP_TAP      = -0.05;

#define RESET 
;#define CASE_EV_SYNTH

#ifndef CASE_EV_SYNTH
Ac_ctrl control begin

	Dc0    dc nettype=1 sparse=3 print=no uic=1 //load="ieee39.dc"
	Tr0  tran nettype=1 sparse=3 tstop=10 uic=1 acntrl=3 tmin=0.1u iabstol=1u
	Dc1    dc nettype=1 sparse=3 restart=no time=0
	Pz     pz nettype=1 pf=1 shift=8.030027e-01
	Ac     ac nettype=1 start=1m stop=10M dec=1000*3 
//	Tr1  tran nettype=1 sparse=3 tstop=TSTOP acntrl=3 tmax=0.1m

	FREQ       = get("Ac.freq");
	P_EV       = get("Ac.EV.p_ev");
	P_CS       = get("Ac.EV.p_cs");
	Q_EV       = get("Ac.EV.q_ev");
	TAP        = get("Ac.tap");
	VD_PCC     = get("Ac.EV.v0d_pan");
	VQ_PCC     = get("Ac.EV.v0q_pan");
	ID_PCC     = get("Ac.EV.i0d_pan");
	IQ_PCC     = get("Ac.EV.i0q_pan");


#ifdef CCCV
save("mat5","DYN_CCCV_VF_KI_1000.mat","FREQ",FREQ,"P_EV",P_EV,"P_CS",P_CS,"Q_EV",Q_EV,"TAP",TAP,"VD_PCC",VD_PCC,"VQ_PCC",VQ_PCC,"ID_PCC",ID_PCC,"IQ_PCC",IQ_PCC);
#else
save("mat5","DYN_CPCV_VF_KI_1000.mat","FREQ",FREQ,"P_EV",P_EV,"P_CS",P_CS,"Q_EV",Q_EV,"TAP",TAP,"VD_PCC",VD_PCC,"VQ_PCC",VQ_PCC,"ID_PCC",ID_PCC,"IQ_PCC",IQ_PCC);
#endif

endcontrol 

#else
	Dc1       dc nettype=1 sparse=3 //restart=no time=0
	Pz        pz nettype=1 pf=1 shift=8.030027e-01
	Ac_synth  ac nettype=1 start=1m stop=10M dec=1000*3 
	
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
G1  bus1 avr1 gnd omega1 powergenerator slack=true \
             vrating=69.0k vg=1.06 \
             prating=615M pg=100*2.324/615 \
             pmax=999.9*100/615 pmin=-999.9*100/615 \
	     qmax=9.9*100/615 qmin=-9.9*100/616 \
	     d=D m=10.296 td0p=7.4 td0s=0.03 \
	     tq0s=0.033 xd=0.8979 xdp=0.2995 xds=0.23 \
             xl=0.2396 xq=0.646 xqp=0.646 xqs=0.4 ra=0 \
	     omegab=(60*0+50)*2*pi type=52 

G2  bus2 avr2 powergenerator vrating=69.0k vg=1.045 \
             prating=60M pg=100*0.4/60 \
	     pmax=1.0*100/60 pmin=0*100/60 \
             qmax=0.5*100/60 qmin=-0.4*100/60 \
	     d=D m=13.08 td0p=6.1 td0s=0.04 \
	     tq0p=0.3 tq0s=0.099 \
	     ra=0.0031 xd=1.05 xdp=0.185 xds=0.13 xq=0.98 xqp=0.36 xqs=0.13 \
	     omegab=(60*0+50)*2*pi type=6

G3  bus3 avr3 powergenerator vrating=69.0k vg=1.01 \
             prating=60M pg=0 \
	     pmax=1.0*100/60 pmin=0*100/60 \
             qmax=0.4*100/60 \
	     d=D m=13.08 td0p=6.1 td0s=0.04 \
	     tq0p=0.3 tq0s=0.099 \
	     ra=0.0031 xd=1.05 xdp=0.185 xds=0.13 xq=0.98 xqp=0.36 xqs=0.13 \
	     omegab=(60*0+50)*2*pi type=6

G6  bus6 avr6 powergenerator vrating=13.8k vg=1.07 \
             prating=25M pg=0 \
	     pmax=1.0*100/25 pmin=0*100/25 \
             qmax=0.24*100/25 qmin=-0.06*100/25 \
	     d=D m=10.12 td0p=4.75 td0s=0.06 \
	     tq0p=1.5 tq0s=0.21 \
	     ra=0.0041 xd=1.25 xdp=0.232 xds=0.12 xl=0.134 xq=1.22 xqp=0.715 \
	     xqs=0.12 omegab=(60*0+50)*2*pi type=6

G8  bus8 avr8 powergenerator vrating=18.0k vg=1.09 \
             prating=25M pg=0 \
	     pmax=1.0*100/25 pmin=0*100/25 \
             qmax=0.24*100/25 qmin=-0.06*100/25 \
	     d=D m=10.12 td0p=4.75 td0s=0.06 \
	     tq0p=1.5 tq0s=0.21 ra=0.0041 xd=1.25 \
	     xdp=0.232 xds=0.12 xl=0.134 xq=1.22 xqp= 0.715 xqs=0.12 \
	     omegab=(60*0+50)*2*pi type=6

// Voltage regulators
Avr1  bus1 avr1      poweravr ka=180 kf=0.00085 ta=0.02 te=0.19 tf=1.0 ke=1 \
	     vmax=9.99 vmin=0.0 vrating=69k

Avr2  bus2 avr2  poweravr ka=20.0 kf=0.001 ta=0.02 te=1.98 tf=1.0 ke=1 \
	     vmax=2.05*0+12 vmin = 0.0 vrating=69k

Avr3  bus3 avr3  poweravr Ka=20.0 Kf=0.001 Ta=0.02 Te=1.98 Tf=1.0 ke=1 \
	     vmax=1.8*0+12 vmin=0.0 vrating=69k

Avr6  bus6 avr6  poweravr Ka=20.0 Ta=0.02 Kf=0.001 Tf=1.0 Te=0.7 ke=1 \
	     vmax=2.4*0+12 vmin=1.0 vrating=13.8k

Avr8  bus8 avr8  poweravr Ka=20.0 Kf=0.001 Ta=0.02 Te=0.7 Tf=1.0 ke=1 \
	     vmax=2.4 vmin=0 vrating=18k


// Lines
Line1#2   bus1   bus2 powerline prating=100M vrating=69.0k \
			b=0.0528 r=0.01938 x=0.05917 dynamic=DYN
Line1#5   bus1   bus5 powerline prating=100M vrating=69.0k \
			b=0.0492 r=0.05403 x=0.22304 dynamic=DYN
Line2#3   bus3   bus2 powerline prating=100M vrating=69.0k \
			b=0.0438 r=0.04699 x=0.19797 dynamic=DYN
Line2#4   bus2   bus4 powerline prating=100M vrating=69.0k \
			b=0.0374 r=0.05811 x=0.17632 dynamic=DYN
Line2#5   bus2   bus5 powerline prating=100M vrating=69.0k \
			b=0.034  r=0.05695 x=0.17388 dynamic=DYN
Line3#4   bus3   bus4 powerline prating=100M vrating=69.0k \
			b=0.0346 r=0.06701 x=0.17103 dynamic=DYN
Line4#5   bus5   bus4 powerline prating=100M vrating=69.0k \
			b=0.0128 r=0.01335 x=0.04211 dynamic=DYN
Line6#11  bus6  bus11 powerline prating=100M vrating=13.8k \
			b=0      r=0.09498 x=0.19890 dynamic=DYN
Line6#12  bus6  bus12 powerline prating=100M vrating=13.8k \
			b=0      r=0.12291 x=0.25581 dynamic=DYN
Line6#13  bus6  bus13 powerline prating=100M vrating=13.8k \
			b=0      r=0.06615 x=0.13027 dynamic=DYN
Line7#9   bus7   bus9 powerline prating=100M vrating=13.8k \
			b=0      r=0       x=0.11001 dynamic=DYN
Line9#10  bus9  bus10 powerline prating=100M vrating=13.8k \
			b=0      r=0.03181 x=0.08450 dynamic=DYN
Line9#14  bus9  bus14 powerline prating=100M vrating=13.8k \
			b=0      r=0.12711 x=0.27038 dynamic=DYN
Line10#11 bus11 bus10 powerline prating=100M vrating=13.8k \
			b=0      r=0.08205 x=0.19207 dynamic=DYN
Line12#13 bus12 bus13 powerline prating=100M vrating=13.8k \
			b=0      r=0.22092 x=0.19988 dynamic=DYN
Line13#14 bus14 bus13 powerline prating=100M vrating=13.8k \
			b=0      r=0.17093 x=0.34802 dynamic=DYN

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
Ln1   bus2 powerload prating=100M vrating=69k   pc=0.217 qc=0.127  limit=false
Ln2   bus3 powerload prating=100M vrating=69k   pc=0.942 qc=0.19   limit=false
Ln3   bus4 powerload prating=100M vrating=69k   pc=0.478 qc=-0.039 limit=false
Ln4   bus5 powerload prating=100M vrating=69k   pc=0.076 qc=0.016  limit=false
Ln5   bus6 powerload prating=100M vrating=13.8k pc=0.112 qc=0.075  limit=false
Ln6   bus9 powerload prating=100M vrating=13.8k pc=0.295 qc=0.116  limit=false
Ln7  bus10 powerload prating=100M vrating=13.8k pc=0.090 qc=0.058  limit=false
Ln8  bus11 powerload prating=100M vrating=13.8k pc=0.035 qc=0.018  limit=false
Ln9  bus12 powerload prating=100M vrating=13.8k pc=0.061 qc=0.016  limit=false
Ln10 bus13 powerload prating=100M vrating=13.8k pc=0.135 qc=0.058  limit=false
Ln11 bus14 powerload prating=100M vrating=13.8k pc=0.149 qc=0.050  limit=false

#ifndef CASE_EV_SYNTH
EV  bus10 EV \
	V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT SOC_THRESHOLD=0.90 Q_NOM=Q_NOM V_THRESHOLD=V_THRESHOLD \
	N_SERIES=N_SER N_PARALLEL=N_PAR CP_SIGNAL=CP_SIGNAL R_INT=R_INT	N_EV=1
#else
EVBIS  bus10 EV_POW V1_NOM=13.8k V2_NOM=400/sqrt(3) S_NOM=EV_CHARGER_P \
	SOC_0=EV_SOC_INIT ap=ap bp=bp np=np cp=cp dp=dp ep=ep fp=fp CP_SIGNAL=CP_SIGNAL
#endif

// Include subckt of EV and its synthetic representation
include EV.txt

end

// TAP 
global tap

TAP tap  gnd tap_dc tap_ac  vcvs func=v(tap_dc) + v(tap_ac)

TAP_DC tap_dc  gnd   vsource v1=1 v2=1 td=0.1*0+1 tr=1p \
                         width=TSTOP+1 period=TSTOP+2

TAP_AC tap_ac gnd vsource vdc=0 mag=1*0+0.03

include EV.mod

model DIO diode imax=10k rs=1m
model SW vswitch ron=1m roff=1M voff=0.4 von=0.6
model LOOKUP_TABLE  nport veriloga="lookup_table.va"     verilogaprotected=yes 
model CELL          nport veriloga="cell.va"             verilogaprotected=yes 
model DCDC_CONTROL  nport veriloga="DCDC.va"             verilogaprotected=yes
model EV_LOAD       nport veriloga="EV_LOAD.va" 	 verilogaprotected=yes
