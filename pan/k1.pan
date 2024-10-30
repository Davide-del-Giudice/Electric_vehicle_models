ground electrical gnd
parameters F0=60 VNOM_HV=69k VNOM_MV=13.8k VNOM_LV=240 SCALE_L=1 dev=0.1
parameters SCALE_V=1 SCALE_T=1 SCALE_S=1 

; SELECT CHEMISTRY
;#define LFP
;#define LMO
;#define NMC
;#define NCA

; SELECT CHARGING MODE
;#define CCCV
;#define CPCV

; SELECT IF YOU WANT TO INCLUDE_EVS IN SIMULATION
;#define INCLUDE_EV

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

parameters TSTOP         = ceil(2.5*3600);
parameters TDELAY        = 0.1*0+ 5k*1;
parameters TAP           = 1;
parameters EV_SOC_INIT   = 0.1;
parameters FIXED_STEP    = 0;
parameters KP_V_DC       = 0.6;
parameters KI_V_DC       = 1;
parameters P_EV_NOM      = 50k;
parameters V_EV_NOM      = 0.48k/sqrt(3);
parameters START_SOC_1   = 0.1;
parameters END_SOC_1     = 0.9;
parameters STEP_SOC_1    = 0.01;

parameters BALANCED_PH3DQ = 1;

;#include "inc/Allocation_factors_K1.inc"
;#define REG
;A1 alter group="ph3load" param="type" value=1
A2 alter group="ph3load" param="limit" value=0


options topcheck=2 digits=8 mindevres=0.1u gmin=1e-20 gground=1e-20 maxcputime=2000

#ifndef SAVE
Dc dc nettype=1 sparse=2 print=0 uic=2 ireltol=1m iabstol=10u vreltol=1m vabstol=1u load="k1.dc" save="k1_new.dc" mem=["losses"]
/*
Pz pz nettype=1 pf=1 shift=8.030027e-01 maxm=1e4 sparse=2
Tr tran nettype=1 sparse=2 method=2 maxord=2 tstop=TSTOP \
	acntrl=3 uic=2 iabstol=1u ltefactor=1k tinc=0.5 keepmatrixorder=yes \
	chgcheck=no forcetps=FIXED_STEP timepoints=100m partitioner=1*0 
*/
#endif SAVE


#ifdef SAVE

Save control begin

tmp = 1;
#ifdef PQ
tmp = 0;
#endif

	SOC_SIM = START_SOC_1 : STEP_SOC_1 : END_SOC_1;
	for k = 1:numel(SOC_SIM)
		Alter_SOC alter param="EV_SOC_INIT" value=SOC_SIM(k)
		Dc dc nettype=1 sparse=2 print=0 uic=2 ireltol=1m iabstol=10u vreltol=1m mem=["losses"] load="k1.dc"

		I1a = get("Dc.E1ar:i") + 1i*get("Dc.E1ai:i");
		I1b = get("Dc.E1br:i") + 1i*get("Dc.E1bi:i");
		I1c = get("Dc.E1cr:i") + 1i*get("Dc.E1ci:i");

		Ea = get("Dc.ext:ar") + 1i*get("Dc.ext:ai");
		Eb = get("Dc.ext:br") + 1i*get("Dc.ext:bi");
		Ec = get("Dc.ext:cr") + 1i*get("Dc.ext:ci");

		Aa = Ea*conj(I1a);
		Ab = Eb*conj(I1b);
		Ac = Ec*conj(I1c);
		At = Aa + Ab + Ac;
		Pt(k) = real(At);
		Qt(k) = imag(At);
		soc(k)= SOC_SIM(k);
 
 	        Ia(k) = abs(get("Dc.E2ar:i") + 1i*get("Dc.E2ai:i"));
		Ib(k) = abs(get("Dc.E2br:i") + 1i*get("Dc.E2bi:i"));
		Ic(k) = abs(get("Dc.E2cr:i") + 1i*get("Dc.E2ci:i"));

		Losses = get("Dc.losses");
		Line_losses(k)  = -(Losses(1) + Losses(3));
		Trafo_losses(k) = -(Losses(2) + Losses(4));
		Total_losses(k) = Line_losses(k) + Trafo_losses(k);

		if (tmp == 0)
			P_single_EV(k) = P_EV_NOM;
		else
			P_single_EV(k) = get("Dc.EV_10548933.p_EV");
		end

	end

#ifdef PQ

scenario  = "PQ";
name_file = sprintf("./SWEEP_FLEET_EV/SWEEP_%s.mat",scenario);

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

#ifndef SYNTHETIC
scenario = "FULL";
#else
scenario = "SYNTH";
#endif
name_file = sprintf("./SWEEP_FLEET_EV/SWEEP_%s_%s_%s.mat",chemistry,charge,scenario);

#endif PQ

save("mat5",name_file,"soc",soc,"Pt",Pt,"Qt",Qt,"Ia",Ia,"Ib",Ib,"Ic",Ic,"Line_losses",Line_losses,"Trafo_losses",Trafo_losses,"Total_losses",Total_losses,"P_single_EV",P_single_EV);


endcontrol

#endif SAVE

E1ar    ext:ar   gnd   vsource vdc=SCALE_V*VNOM_HV/sqrt(3)
E1ai    ext:ai   gnd   vsource vdc=0
E1br    ext:br   gnd   vsource vdc=SCALE_V*VNOM_HV/sqrt(3)*cos(-2*pi/3)
E1bi    ext:bi   gnd   vsource vdc=SCALE_V*VNOM_HV/sqrt(3)*sin(-2*pi/3)
E1cr    ext:cr   gnd   vsource vdc=SCALE_V*VNOM_HV/sqrt(3)*cos( 2*pi/3)
E1ci    ext:ci   gnd   vsource vdc=SCALE_V*VNOM_HV/sqrt(3)*sin( 2*pi/3)

"TR" Trans_equiv K21_aux PH3_TRAFO \
	pphases="abc" sphases="abc" kv1=VNOM_HV/1k kv2=VNOM_MV/1k \ 
	kva=12000 rs=0.50 gm=10*0+1u ls=7.904196143

E2ar    K21_aux:ar   K21:ar   vsource vdc=0
E2ai    K21_aux:ai   K21:ai   vsource vdc=0
E2br    K21_aux:br   K21:br   vsource vdc=0
E2bi    K21_aux:bi   K21:bi   vsource vdc=0
E2cr    K21_aux:cr   K21:cr   vsource vdc=0
E2ci    K21_aux:ci   K21:ci   vsource vdc=0

begin power

Ext_line   ext Trans_equiv  "EXT_LINE" length=1 phases1="abc" phases2="abc"
Gnd1 ext ph3gnd

#include "inc/Lines_K1.inc"
#include "inc/Transformers_K1.inc"
#include "inc/Services_K1.inc"
#include "inc/Loads_K1_with_allocfactor.txt"

#ifdef INCLUDE_EV
#include "inc/Transformers_EV_K1.inc"
begin electrical
#include "inc/EV_K1.inc"
end electrical
#endif


end power

global tap
tap tap gnd vsource vdc=1

// MODEL DECLARATION
model VECT_GROUP  nport   veriloga="inc/vector_group.va" verilogaprotected=yes
model REG         nport   veriloga="inc/reg.va"
model SW          vswitch ron=1m roff=1G voff=0.3 von=0.6
model EV          nport veriloga="./AUX_FILES/EV.va"             verilogaprotected=yes
model EV_SYNTH    nport veriloga="./AUX_FILES/EV_SYNTH_FINAL.va" verilogaprotected=yes


#include "inc/line_models.txt"
#include "inc/transformer_models.txt"

