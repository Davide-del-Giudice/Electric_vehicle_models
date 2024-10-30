ground electrical gnd

// ANALYSES
options rawkeep=yes topcheck=2 outintnodes=1 writeparams=no mindevres=1u

; SELECT CHEMISTRY
#define LFP
;#define LMO
;#define NMC
;#define NCA

; SELECT CHARGING MODE
;#define CCCV
;#define CPCV

; SELECT WHETHER YOU WANT TO USE EV SYNTHETIC MODEL OR NOT
;#define SYNTHETIC

; SELECT WHETHER YOU WANT TO SAVE DATA OR NOT
;#define SAVE

;#define TWO_DISTURBANCES

; DEFINE BATTERY PACK PARAMETERS BASED ON PREVIOUS DEFINITIONS
include "cases.inc"

; INCLUDE LINE BETWEEN INFINITE BUS AND EV
;#define LINE

parameters TSTOP         = ceil(2.5*3600);
parameters TDELAY        = 0.1*0+ 5k*1;
parameters TAP           = 0.9;
parameters EV_SOC_INIT   = 0.2;
parameters FIXED_STEP    = 0;
parameters KP_V_DC       = 0.6*0 + 0.2;
parameters KI_V_DC       = 1*0 + 100;


#ifndef SAVE
Dc0    dc nettype=1 sparse=1 print=yes uic=2 iabstol=1u
#else
Dc0    dc nettype=1 sparse=1 print=no uic=2 iabstol=1u
#endif

#ifndef SYNTHETIC
Tr_full    tran nettype=1 sparse=2 method=2 maxord=2 tstop=TSTOP \
		acntrl=3 uic=2 forcetps=FIXED_STEP timepoints=1e-3 iabstol=1u ;tmax=[500-1m,10u,500+10]
#else
Tr_synth    tran nettype=1 sparse=2 method=2 maxord=2 tstop=TSTOP \
		acntrl=3 uic=2 forcetps=FIXED_STEP timepoints=1e-3 iabstol=1u
#endif

#ifdef SAVE

Save control begin
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



#ifndef SYNTHETIC
	t            = get("Tr_full.time");
	p_EV         = get("Tr_full.EV1.p_EV");
	soc          = get("Tr_full.EV1.soc");
	d_soc        = get("Tr_full.EV1.d_soc");
	vr           = get("Tr_full.busxd");
	vi           = get("Tr_full.busxq");
#else
	t            = get("Tr_synth.time");
	p_EV         = get("Tr_synth.EV1.p_EV");
	soc          = get("Tr_synth.EV1.soc");
	d_soc        = get("Tr_synth.EV1.d_soc");
	vr           = get("Tr_synth.busxd");
	vi           = get("Tr_synth.busxq");
#endif

name_file = sprintf("./CHARGE_COMPARISON/CHARGE_%s_%s_%s.mat",chemistry,charge,scenario);

save("mat5",name_file,...
        "time",t,"p_EV",p_EV,"soc",soc,"d_soc",d_soc,"vr",vr,"vi",vi);



endcontrol
#endif SAVE

;Vm    ph   gnd   vsource v1=0 v2=10/180*pi td=0.02*TSTOP tr=1m tf=1m \
;                         width=TSTOP/20*2 period=TSTOP/4*10

Vm    ph   gnd     vsource vdc=45*pi/180*0

#ifdef TWO_DISTURBANCES
Vmag  vmag   gnd   vsource mag=1 v=0    t=0 \
				 v=0    t=500-1u \
				 v=-0.15 t=500 \
				 v=-0.15 t=4500-1u \
				 v=0    t=4500 \
				 v=0    t=8000 
#else
Vmag  vmag   gnd   vsource mag=1 v=0    t=0 \
				 v=0    t=500-1u \
				 v=0.15 t=500 \
				 v=0.15 t=4000-1u \
				 v=0    t=4000    \
				 v=0    t=5100-1u \
				 v=-0.15 t=5100 \
				 v=-0.15 t=8000 
#endif


#ifndef LINE
Bus1d busxd gnd vmag ph vcvs func=400/sqrt(3)*(1+v(vmag))*cos(v(ph))
Bus1q busxq gnd vmag ph vcvs func=400/sqrt(3)*(1+v(vmag))*sin(v(ph))

Sh1   busxd bus1d vsource vdc=0
Sh2   busxq bus1q vsource vdc=0
#else
Busxd busxd gnd vmag ph vcvs func=400/sqrt(3)*(1+v(vmag))*cos(v(ph))
Busxq busxq gnd vmag ph vcvs func=400/sqrt(3)*(1+v(vmag))*sin(v(ph))


begin power
BX busx busxd gnd busxq gnd powerec type=0
RL busx bus1 powerline r=0.01 x=0.018 prating=50k vrating=400/sqrt(3)
B1 bus1 bus1d gnd bus1q gnd powerec type=0
end power 

#endif

#ifndef SYNTHETIC
EV1  bus1d bus1q tap EV                                                                 \
        V_AC_1=400/sqrt(3) V_AC_2=400/sqrt(3) P_EV_NOM=50k                              \
        V_THRESHOLD=V_THRESHOLD SOC_0=EV_SOC_INIT CPCV=CP_SIGNAL                        \
        R_INT=R_INT Q_NOM=Q_NOM N_SERIES=N_SER N_PARALLEL=N_PAR                         \
        R_ACDC_PU=0.01 L_ACDC_PU=0.059 W_NOM=2*pi*50					\
	KP_V_DC=KP_V_DC KI_V_DC=KI_V_DC
#else
EV1  bus1d bus1q tap EV_SYNTH                                                           \
        V_AC_1=400/sqrt(3) V_AC_2=400/sqrt(3) P_EV_NOM=50k R_EV=R_EV		        \
	CPCV=CP_SIGNAL SOC_0=EV_SOC_INIT SOC_THRESHOLD=SOC_THRESHOLD                    \
	aCC=aCC bCC=bCC cCC=cCC dCC=dCC aCP=aCP                                         \
	alphaCC=alphaCC alphaCP=alphaCP betaCP=betaCP deltaCP=deltaCP gammaCP=gammaCP   \
	aCV=aCV bCV=bCV cCV=cCV dCV=dCV alphaCV=alphaCV          			\
	KP_V_DC=KP_V_DC KI_V_DC=KI_V_DC
#endif

global tap
tap tap gnd tap_dc tap_ac  vcvs func=v(tap_dc) + v(tap_ac)
tap1 tap_ac gnd vsource vdc=0 mag=1
tap2   tap_dc   gnd   vsource vdc=1

/*
tap2   tap_dc   gnd   vsource v=1   t=0     \
			  v=1   t=TDELAY    \
			  v=TAP t=TDELAY+1u \
			  v=TAP t=TSTOP
*/

model EV       nport veriloga="./AUX_FILES/EV.va"                  verilogaprotected=yes
model EV_SYNTH nport veriloga="./AUX_FILES/EV_SYNTH_FINAL.va" verilogaprotected=yes



