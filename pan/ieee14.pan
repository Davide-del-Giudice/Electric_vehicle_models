ground electrical gnd

; SELECT CHEMISTRY
;#define LFP
;#define LMO
;#define NMC
;#define NCA

; SELECT CHARGING MODE
;#define CCCV
;#define CPCV

; SELECT IF YOU WANT TO INCLUDE_EVS IN SIMULATION
#define REPLACE_WITH_FEEDER
#define INCLUDE_EV

; SELECT WHETHER YOU WANT TO USE EV FULL MODEL, SYNTHETIC ONE, OR PQ LOAD
;#define FULL
;#define SYNTHETIC
;#define PQ

; SELECT WHETHER YOU WANT TO SAVE DATA OR NOT
;#define SAVE

#ifndef PQ
; DEFINE BATTERY PACK PARAMETERS BASED ON PREVIOUS DEFINITIONS
include "cases.inc"
#endif

;#define CASE1
;#define CASE2
;#define CASE3

options writeparams=yes

parameters D=2 DYN=0
parameters F0=50 VNOM_HV=69k VNOM_MV=13.8k VNOM_LV=240 SCALE_L=1 dev=0.1
parameters SCALE_V=1 SCALE_T=1  
parameters P_FEEDER = 6.08862M
parameters Q_FEEDER = 1.95936M
parameters BAL = 1 TYPE=1

parameters TAP           = 1;
parameters EV_SOC_INIT   = 0.1;
parameters FIXED_STEP    = 0;

#ifdef CASE1
parameters KP_V_DC       = 0.6;
parameters KI_V_DC       = 1;
#endif

#ifdef CASE2
parameters KP_V_DC       = 0.4;
parameters KI_V_DC       = 5;
#endif

#ifdef CASE3
parameters KP_V_DC       = 0.2;
parameters KI_V_DC       = 100;
#endif


parameters P_EV_NOM      = 50k;
parameters V_EV_NOM      = 0.48k/sqrt(3);
parameters BALANCED_PH3DQ = 1;
parameters PL_NOM        = 112M;
parameters QL_NOM        = 75M;
parameters P_FEEDER_NOM  = 6.22M;
parameters Q_FEEDER_NOM  = 1.02M;

parameters LAMBDA        = 22/100;
parameters START_LAMBDA  = 18/100;
parameters END_LAMBDA    = 25/100;
parameters STEP_LAMBDA   = 0.1/100;


;#include "inc/Allocation_factors_K1.inc"
;#define REG
;A1 alter group="ph3load"   param="type" value=1  annotate=0
;A2 alter group="ph3load"   param="limit" value=0 annotate=0
;A3 alter group="powerload" param="limit" value=0 annotate=0


options outintnodes=0 rawkeep=yes writeparams=no
options topcheck=2 digits=8 mindevres=0.1u gmin=1e-20 gground=1e-20


// -------------------------------------------------------------------------  //
// -----------------------     SIMULATION OPTIONS    -----------------------  //
// -------------------------------------------------------------------------  //


#ifndef SAVE
#ifdef PQ
Dc dc nettype=1 print=0 iabstol=10u ireltol=1m vreltol=1m vabstol=1u sparse=2 \
	save="ieee14.dc" uic=2 load="guess_PQ.dc" 
#endif

#ifdef SYNTHETIC
Dc dc nettype=1 print=0 iabstol=10u ireltol=1m vreltol=1m vabstol=1u saman=1 sparse=2 \
	save="ieee14.dc" uic=2 load="guess_SYNTHETIC.dc" 
#endif

#ifdef FULL
Dc dc nettype=1 print=0 iabstol=10u ireltol=1m vreltol=1m vabstol=1u saman=0 sparse=2 \
	save="ieee14.dc" uic=2 load="guess_FULL.dc" fixsm=1 
#endif

Pz pz nettype=1 sparse=2*0+5 solver=0 pf=yes maxm=1e5 shift=8.030027e-01 parsolver=1

#ifdef CASE1
TrA1 tran nettype=1 uic=2 sparse=3 tstop=10 acntrl=3 iabstol=1u ireltol=1m \
		  saman=1 tinc=1.5 ltefactor=1 chgcheck=false method=2 \
		  maxord=2 partitioner=0 keepmatrixorder=1 
#endif

#ifdef CASE2
TrA2 tran nettype=1 uic=2 sparse=3 tstop=10 acntrl=3 iabstol=1u ireltol=1m \
		  saman=1 tinc=1.5 ltefactor=1 chgcheck=false method=2 \
		  maxord=2 partitioner=0 keepmatrixorder=1 
#endif

#ifdef CASE3
TrA3 tran nettype=1 uic=2 sparse=3 tstop=10 acntrl=3 iabstol=1u ireltol=1m \
		  saman=1 tinc=1.5 ltefactor=1 chgcheck=false method=2 \
		  maxord=2 partitioner=0 keepmatrixorder=1 
#endif


AlterX alter instance=Ln2 param=pc value=0.217*(1+LAMBDA)*1.1 invalidate=no

#ifdef CASE1
TrB1 tran nettype=1 restart=no sparse=2 tstop=100 acntrl=3 iabstol=1u ireltol=1m \
		  saman=1 tinc=1.5 ltefactor=1 chgcheck=false method=2 \
		  maxord=2 partitioner=0 keepmatrixorder=1 
#endif

#ifdef CASE2
TrB2 tran nettype=1 restart=no sparse=2 tstop=100 acntrl=3 iabstol=1u ireltol=1m \
		  saman=1 tinc=1.5 ltefactor=1 chgcheck=false method=2 \
		  maxord=2 partitioner=0 keepmatrixorder=1 
#endif

#ifdef CASE3
TrB3 tran nettype=1 restart=no sparse=2 tstop=100 acntrl=3 iabstol=1u ireltol=1m \
		  saman=1 tinc=1.5 ltefactor=1 chgcheck=false method=2 \
		  maxord=2 partitioner=0 keepmatrixorder=1 
#endif

#endif SAVE


#ifdef SAVE
Save control begin

	LAMBDA_SIM = START_LAMBDA : STEP_LAMBDA: END_LAMBDA
	for k = 1 : numel(LAMBDA_SIM)
		Alter_LAMBDA alter param="LAMBDA" value=LAMBDA_SIM(k)

#ifdef PQ
Dc dc nettype=1 print=0 iabstol=10u ireltol=1m vreltol=1m vabstol=1u sparse=2 \
	save="ieee14.dc" uic=2 load="guess_PQ.dc" 
#endif

#ifdef SYNTHETIC
Dc dc nettype=1 print=0 iabstol=10u ireltol=1m vreltol=1m vabstol=1u saman=1 sparse=2 \
	save="ieee14.dc" uic=2 load="guess_SYNTHETIC.dc" 
#endif

#ifdef FULL
Dc dc nettype=1 print=0 iabstol=10u ireltol=1m vreltol=1m vabstol=1u saman=0 sparse=2 \
	save="ieee14.dc" uic=2 load="guess_FULL.dc" fixsm=1 
#endif

Pz pz nettype=1 sparse=2 solver=0 pf=0 maxm=1e5 shift=8.030027e-01 annotate=0
		
		Eig = get("Pz.poles");
		Poles(:,k) = Eig;
		Lambda(k)  = LAMBDA_SIM(k);
	end


#ifdef PQ

scenario = "PQ";
name_file = sprintf("./DYN_OVERLOAD_EV/SWEEP_%s.mat",scenario);

#else

#ifdef LFP
chemistry = "LFP";
#endif

#ifdef LMO
chemistry = "LMO";
#endif

#ifdef NMC
chemistry = "NMC";
#endif

#ifdef NCA
chemistry = "NCA";
#endif

#ifdef CCCV
charge = "CCCV";
#endif

#ifdef CPCV
charge = "CPCV";
#endif

#ifdef FULL
scenario = "FULL";
#endif

#ifdef SYNTHETIC
scenario = "SYNTH";
#endif

#ifdef CASE1
name_file = sprintf("./DYN_OVERLOAD_EV/SWEEP_%s_%s_%s_KP_600m_KI_1.mat",chemistry,charge,scenario);
#endif

#ifdef CASE2
name_file = sprintf("./DYN_OVERLOAD_EV/SWEEP_%s_%s_%s_KP_400m_KI_5.mat",chemistry,charge,scenario);
#endif

#ifdef CASE3
name_file = sprintf("./DYN_OVERLOAD_EV/SWEEP_%s_%s_%s_KP_200m_KI_100.mat",chemistry,charge,scenario);
#endif


#endif PQ


save("mat5",name_file,"Poles",Poles,"Lambda",Lambda);
endcontrol 
#endif SAVE


// -------------------------------------------------------------------------  //
// -----------------------      ACTUAL SIMULATION    -----------------------  //
// -------------------------------------------------------------------------  //

global tap
tap tap gnd vsource vdc=1


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


// Syncronous generators
G1  bus1 avr1 gnd omega1 powergenerator slack=true \
             vrating=69.0k vg=1.06 \
             prating=615M pg=100*2.324/615*(1+LAMBDA) \
             pmax=999.9*100/615 pmin=-999.9*100/615 \
             qmax=9.9*100/615 qmin=-9.9*100/616 \
             d=2.0 m=10.296 td0p=7.4 td0s=0.03 \
             tq0s=0.033 xd=0.8979 xdp=0.2995 xds=0.23 \
             xl=0.2396 xq=0.646 xqp=0.646 xqs=0.4 ra=0 \
             omegab=60*2*pi type=52

G2  bus2 avr2 powergenerator vrating=69.0k vg=1.045 \
             prating=60M pg=100*0.4/60*(1+LAMBDA) \
             pmax=1.0*100/60 pmin=0*100/60 \
             qmax=0.5*100/60 qmin=-0.4*100/60 \
             d=2.0 m=13.08 td0p=6.1 td0s=0.04 \
             tq0p=0.3 tq0s=0.099 \
             ra=0.0031 xd=1.05 xdp=0.185 xds=0.13 xq=0.98 xqp=0.36 xqs=0.13 \
             omegab=60*2*pi type=6

G3  bus3 avr3 powergenerator vrating=69.0k vg=1.01 \
             prating=60M pg=0*(1+LAMBDA) \
             pmax=1.0*100/60 pmin=0*100/60 \
             qmax=0.4*100/60 \
             d=2.0 m=13.08 td0p=6.1 td0s=0.04 \
             tq0p=0.3 tq0s=0.099 \
             ra=0.0031 xd=1.05 xdp=0.185 xds=0.13 xq=0.98 xqp=0.36 xqs=0.13 \
             omegab=60*2*pi type=6


G6  bus6 avr6 powergenerator vrating=13.8k vg=1.07 \
             prating=25M pg=0*(1+LAMBDA) \
             pmax=1.0*100/25 pmin=0*100/25 \
             qmax=0.24*100/25 qmin=-0.06*100/25 \
             d=2.0 m=10.12 td0p=4.75 td0s=0.06 \
             tq0p=1.5 tq0s=0.21 \
             ra=0.0041 xd=1.25 xdp=0.232 xds=0.12 xl=0.134 xq=1.22 xqp=0.715 \
             xqs=0.12 omegab=60*2*pi type=6

G8  bus8 avr8 powergenerator vrating=18.0k vg=1.09 \
             prating=25M pg=0*(1+LAMBDA) \
             pmax=1.0*100/25 pmin=0*100/25 \
             qmax=0.24*100/25 qmin=-0.06*100/25 \
             d=2.0 m=10.12 td0p=4.75 td0s=0.06 \
             tq0p=1.5 tq0s=0.21 ra=0.0041 xd=1.25 \
             xdp=0.232 xds=0.12 xl=0.134 xq=1.22 xqp= 0.715 xqs=0.12 \
             omegab=60*2*pi type=6

// Voltage regulators
Avr1  bus1 avr1      poweravr ka=180 kf=0.00085 ta=0.02 te=0.19 tf=1.0 ke=1 \
             vmax=9.99 vmin=0.0 vrating=69k

Avr2  bus2 avr2  poweravr ka=20.0 kf=0.001 ta=0.02 te=1.98 tf=1.0 ke=1 \
             vmax=6 vmin = 0.0 vrating=69k

Avr3  bus3 avr3  poweravr Ka=20.0 Kf=0.001 Ta=0.02 Te=1.98 Tf=1.0 ke=1 \
             vmax=6 vmin=0.0 vrating=69k

Avr6  bus6 avr6  poweravr Ka=20.0 Ta=0.02 Kf=0.001 Tf=1.0 Te=0.7 ke=1 \
             vmax=6 vmin=1.0 vrating=13.8k

Avr8  bus8 avr8  poweravr Ka=20.0 Kf=0.001 Ta=0.02 Te=0.7 Tf=1.0 ke=1 \
             vmax=6 vmin=0 vrating=18k

/*
Avr2  bus2 avr2  poweravr ka=20.0 kf=0.001 ta=0.02 te=1.98 tf=1.0 ke=1 \
             vmax=2.05 vmin = 0.0 vrating=69k

Avr3  bus3 avr3  poweravr Ka=20.0 Kf=0.001 Ta=0.02 Te=1.98 Tf=1.0 ke=1 \
             vmax=1.8 vmin=0.0 vrating=69k

Avr6  bus6 avr6  poweravr Ka=20.0 Ta=0.02 Kf=0.001 Tf=1.0 Te=0.7 ke=1 \
             vmax=2.4 vmin=1.0 vrating=13.8k

Avr8  bus8 avr8  poweravr Ka=20.0 Kf=0.001 Ta=0.02 Te=0.7 Tf=1.0 ke=1 \
             vmax=2.4 vmin=0 vrating=18k
*/

// Loads
Ln2   bus2  powerload prating=100M vrating=69k  pc=0.217*(1+LAMBDA) qc=0.127*(1+LAMBDA)  
Ln3   bus3  powerload prating=100M vrating=69k  pc=0.942*(1+LAMBDA) qc=0.19*(1+LAMBDA)   
Ln4   bus4  powerload prating=100M vrating=69k  pc=0.478*(1+LAMBDA) qc=-0.039*(1+LAMBDA) 
Ln5   bus5  powerload prating=100M vrating=69k  pc=0.076*(1+LAMBDA) qc=0.016*(1+LAMBDA)  

#ifndef REPLACE_WITH_FEEDER
Ln6    bus6  powerload prating=100M vrating=13.8k pc=0.112*(1+LAMBDA) qc=0.075*(1+LAMBDA) 
Ln9    bus9  powerload prating=100M vrating=13.8k pc=0.295*(1+LAMBDA) qc=0.116*(1+LAMBDA)
Ln10   bus10 powerload prating=100M vrating=13.8k pc=0.090*(1+LAMBDA) qc=0.058*(1+LAMBDA)
Ln11   bus11 powerload prating=100M vrating=13.8k pc=0.035*(1+LAMBDA) qc=0.018*(1+LAMBDA)
Ln12   bus12 powerload prating=100M vrating=13.8k pc=0.061*(1+LAMBDA) qc=0.016*(1+LAMBDA)
Ln13   bus13 powerload prating=100M vrating=13.8k pc=0.135*(1+LAMBDA) qc=0.058*(1+LAMBDA)
Ln14   bus14 powerload prating=100M vrating=13.8k pc=0.149*(1+LAMBDA) qc=0.050*(1+LAMBDA)
#else
Ln6    bus6  loadwithfeeder prating=100M vrating=13.8k pc=0.112*(1+LAMBDA) qc=0.075*(1+LAMBDA)
Ln9    bus9  loadwithfeeder prating=100M vrating=13.8k pc=0.295*(1+LAMBDA) qc=0.116*(1+LAMBDA)
Ln10   bus10 loadwithfeeder prating=100M vrating=13.8k pc=0.090*(1+LAMBDA) qc=0.058*(1+LAMBDA)
Ln11   bus11 loadwithfeeder prating=100M vrating=13.8k pc=0.035*(1+LAMBDA) qc=0.018*(1+LAMBDA)
Ln12   bus12 loadwithfeeder prating=100M vrating=13.8k pc=0.061*(1+LAMBDA) qc=0.016*(1+LAMBDA)
Ln13   bus13 loadwithfeeder prating=100M vrating=13.8k pc=0.135*(1+LAMBDA) qc=0.058*(1+LAMBDA)
Ln14   bus14 loadwithfeeder prating=100M vrating=13.8k pc=0.149*(1+LAMBDA) qc=0.050*(1+LAMBDA)
#endif

end power

begin power

subckt loadwithfeeder t1
parameters prating=100M vrating=13.8k pc=1 qc=1
parameters PL_NOM=pc*prating QL_NOM=qc*prating
parameters VNOM_HV=vrating VNOM_MV=13.8k/sqrt(3) VNOM_LV=400 SCALE_S=1 BALANCED_3PHDQ=1 

QL t1 powerload prating=prating vrating=vrating \
	pc=0 qc=(QL_NOM - PL_NOM/P_FEEDER_NOM*Q_FEEDER_NOM)/prating

;QL t1 powerload prating=prating vrating=vrating \
;	pc=0 qc=(-QL_NOM + PL_NOM/P_FEEDER_NOM*Q_FEEDER_NOM)/prating

begin electrical
; REPLICAS OF FEEDER
Id3 t3_d gnd i4_d vccs \
        func=PL_NOM/P_FEEDER_NOM*v(i4_d)

Iq3 t3_q gnd i4_q vccs \
        func=PL_NOM/P_FEEDER_NOM*v(i4_q)

end electrical

PEC_P1   t1      P_L             gnd  Q_L             gnd  t2 powerec type=4 vrating=VNOM_HV
PEC_P2   t2      P_feeder_mult   gnd  Q_feeder_mult   gnd  t3 powerec type=4 vrating=VNOM_HV
PEC_V3   t3      t3_d            gnd  t3_q            gnd     powerec type=0
PEC_P3   t3      P_feeder_single gnd  Q_feeder_single gnd  t4 powerec type=4 vrating=VNOM_HV
PEC_I4   t4      i4_d            gnd  i4_q            gnd  t5 powerec type=5 vrating=VNOM_HV

Y1   ext t5  ph3dq vrating=VNOM_HV balance=BALANCED_PH3DQ
Gnd1 ext ph3gnd
Ext_line   ext Trans_equiv  "EXT_LINE" length=1 phases1="abc" phases2="abc"

"TR" Trans_equiv K21 PH3_TRAFO \
	pphases="abc" sphases="abc" kv1=VNOM_HV/1k kv2=VNOM_MV/1k \ 
	kva=12000 rs=0.50 gm=10*0+1u ls=7.904196143


begin electrical
#ifdef INCLUDE_EV
#include "inc/EV_K1.inc"
#endif
end electrical

#include "inc/Lines_K1.inc"
#include "inc/Transformers_K1.inc"
#include "inc/Services_K1.inc"
#include "inc/Loads_K1_with_allocfactor.txt"

#ifdef INCLUDE_EV
#include "inc/Transformers_EV_K1.inc"
#endif

ends

end power

// MODEL DECLARATION
model EV          nport veriloga="./AUX_FILES/EV.va"             verilogaprotected=yes
model EV_SYNTH    nport veriloga="./AUX_FILES/EV_SYNTH_FINAL.va" verilogaprotected=yes


#include "inc/line_models.txt"
#include "inc/transformer_models.txt"


