ground electrical gnd

// ANALYSES
options rawkeep=yes topcheck=2 outintnodes=1 writeparams=no mindevres=1u 

; SELECT CHEMISTRY
;#define LFP
;#define LMO
;#define NMC
;#define NCA

; SELECT CHARGING MODE
;#define CCCV
;#define CPCV

; SELECT WHETHER YOU WANT TO USE EV SYNTHETIC MODEL OR NOT
;#define SYNTHETIC

; SELECT WHETHER YOU WANT TO DO SWEEP ANALYSIS AND SAVE DATA OR NOT
;#define SWEEP
;#define SAVE

; DEFINE BATTERY PACK PARAMETERS BASED ON PREVIOUS DEFINITIONS
include "cases.inc"


parameters TSTOP         = ceil(2.5*3600);
parameters TAP           = 0.85;
parameters EV_SOC_INIT   = 0.1;

; SWEEPING PARAMETERS
parameters START_SOC_1   = 0.1;
parameters END_SOC_1     = 0.9;
parameters STEP_SOC_1    = 0.1;
//parameters STEP_SOC_2    = 0.001;
//parameters START_SOC_2   = END_SOC_1 + STEP_SOC_2;
//parameters END_SOC_2     = 1;
parameters START_TAP     = 1.20;
parameters END_TAP       = 0.80;
parameters STEP_TAP      = -0.005;

#ifndef SWEEP
Dc0    dc nettype=1 sparse=1 print=yes uic=2 iabstol=1u
Tr0  tran nettype=1 sparse=2 tstop=20  acntrl=3 iabstol=0.1u uic=2
#else
Sweep control begin

	SOC_A 	= START_SOC_1 : STEP_SOC_1 : END_SOC_1;
//	SOC_B 	= START_SOC_2 : STEP_SOC_2 : END_SOC_2;
//	SOC_SIM = transpose([transpose(SOC_A), transpose(SOC_B), 1]);
	SOC_SIM = transpose([transpose(SOC_A)]);
	for k = 1:numel(SOC_SIM)
	      j = 0;
	      Alter_SOC alter param="EV_SOC_INIT" value=SOC_SIM(k)      	
	      SWEEP_TAP sweep start=START_TAP step=STEP_TAP stop=END_TAP param="TAP" begin
				Dc_full dc nettype=1 sparse=1 print=no uic=2 annotate=0 
				j 		= j +1;
				p_EV(k,j)   	= get("Dc_full.EV1.p_EV");
				soc(k)   	= get("Dc_full.EV1.soc");
				status_EV(k,j) 	= get("Dc_full.EV1.status");
				tap(j)   	= get("Dc_full.tap");
				vd_PCC	 	= get("Dc_full.EV1.bus2d");
				vq_PCC	 	= get("Dc_full.EV1.bus2q");
				v_PCC(k,j) 	= sqrt((vd_PCC)^2 + (vq_PCC)^2);
	     end
end

#ifdef SAVE

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

name_file = sprintf("./SWEEP_SINGLE_EV/SWEEP_%s_%s_%s.mat",chemistry,charge,scenario);

save("mat5",name_file,...
	"p_EV",p_EV,"soc",soc,				...
	"tap",tap,"v_PCC",v_PCC,"status_EV",status_EV);

#endif
endcontrol 

#endif

Bus1d bus1d gnd vsource vdc=400/sqrt(3)
Bus1q bus1q gnd vsource vdc=0

#ifndef SYNTHETIC
EV1  bus1d bus1q tap EV                                                                 \
        V_AC_1=400/sqrt(3) V_AC_2=400/sqrt(3) P_EV_NOM=50k                              \
        V_THRESHOLD=V_THRESHOLD SOC_0=EV_SOC_INIT CPCV=CP_SIGNAL                        \
        R_INT=R_INT Q_NOM=Q_NOM N_SERIES=N_SER N_PARALLEL=N_PAR                         \
        R_ACDC_PU=0.01/3 L_ACDC_PU=0.059 W_NOM=2*pi*50
#else
EV1  bus1d bus1q tap EV_SYNTH                                                           \
        V_AC_1=400/sqrt(3) V_AC_2=400/sqrt(3) P_EV_NOM=50k R_EV=0.01/9 		        \
	CPCV=CP_SIGNAL SOC_0=EV_SOC_INIT SOC_THRESHOLD=SOC_THRESHOLD                    \
	aCC=aCC bCC=bCC cCC=cCC dCC=dCC aCP=aCP                                         \
	alphaCC=alphaCC alphaCP=alphaCP betaCP=betaCP deltaCP=deltaCP gammaCP=gammaCP   \
	aCV=aCV bCV=bCV cCV=cCV dCV=dCV alphaCV=alphaCV                                 
#endif

global tap
Vto   tap   gnd   vsource vdc=TAP

model EV       nport veriloga="./AUX_FILES/EV.va"                  verilogaprotected=yes
model EV_SYNTH nport veriloga="./AUX_FILES/EV_SYNTH_FINAL.va" verilogaprotected=yes

