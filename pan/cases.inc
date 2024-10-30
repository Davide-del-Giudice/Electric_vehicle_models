// INITIAL PARAMETER DECLARATION 
// THESE PARAMETERS ARE OVERRIDDEN LATER
parameter           aCC = 0;
parameter           bCC = 0;
parameter           cCC = 0;
parameter           dCC = 0;
parameter           aCP = 0;
parameter           aCV = 0;
parameter           bCV = 0;
parameter           cCV = 0;
parameter           dCV = 0;
parameter SOC_THRESHOLD = 0;
parameter   V_THRESHOLD = 0;
parameter          R_EV = 0;
parameter       alphaCC = 0;
parameter       alphaCV = 0;
parameter       alphaCP = 0;
parameter        betaCP = 0;
parameter       deltaCP = 0;
parameter       gammaCP = 0;
parameter       alphaCV = 0;
parameter            R0 = 0;
parameter            R1 = 0;

//GENERIC EV PARAMETER DECLARATION
parameter EV_CAPACITY   = 75k;  //[Wh]
parameter EV_VOLTAGE    = 400;  //[V]
parameter P_CHARGER_TOT = 50k;  //[W]
parameter EV_CHARGER_P  = 50k;  //[W]

#ifdef CCCV
parameter CP_SIGNAL=0;
#else
parameter CP_SIGNAL=1;
#endif


#ifdef LFP
parameter V_NOM       = 3.2;  //[V]
parameter Q_NOM       = 2.6;  //[Ah]
parameter N_SER       = ceil(EV_VOLTAGE/V_NOM);
parameter N_PAR       = ceil(EV_CAPACITY/(EV_VOLTAGE*Q_NOM));
parameter R_INT       = 0.080; //[ohm]

Load control begin
        load("mat5","./AUX_FILES/chemistries.mat");
        SOC  = SoC_ref;

#ifdef CASES_FIT
OCV  = V_LFP_FIT;
#else
OCV  = V_LFP;
#endif

R0   = R0_LFP;
R1   = R1_LFP;


// LOAD PARAMETERS FOR EV SYNTHETIC REPRESENTATION
load("mat5","./AUX_FILES/EV_synthetic_data.mat");
#ifdef CCCV
Alt_aCC           alter param="aCC"           value=LFP_CCCV_aCC
Alt_bCC           alter param="bCC"           value=LFP_CCCV_bCC
Alt_cCC           alter param="cCC"           value=LFP_CCCV_cCC
Alt_dCC           alter param="dCC"           value=LFP_CCCV_dCC
Alt_aCV           alter param="aCV"           value=LFP_CCCV_aCV
Alt_bCV           alter param="bCV"           value=LFP_CCCV_bCV
Alt_cCV           alter param="cCV"           value=LFP_CCCV_cCV
Alt_dCV           alter param="dCV"           value=LFP_CCCV_dCV
Alt_alphaCC       alter param="alphaCC"       value=LFP_CCCV_alphaCC
Alt_alphaCV       alter param="alphaCV"       value=LFP_CCCV_alphaCV
Alt_SOC_THRESHOLD alter param="SOC_THRESHOLD" value=LFP_CCCV_SOC_THRESHOLD
Alt_R             alter param="R_EV"          value=LFP_CCCV_R
#else
Alt_aCP           alter param="aCP"           value=LFP_CPCV_aCP
Alt_aCV           alter param="aCV"           value=LFP_CPCV_aCV
Alt_bCV           alter param="bCV"           value=LFP_CPCV_bCV
Alt_cCV           alter param="cCV"           value=LFP_CPCV_cCV
Alt_dCV           alter param="dCV"           value=LFP_CPCV_dCV
Alt_alphaCP       alter param="alphaCP"       value=LFP_CPCV_alphaCP
Alt_betaCP        alter param="betaCP"        value=LFP_CPCV_betaCP
Alt_deltaCP       alter param="deltaCP"       value=LFP_CPCV_deltaCP
Alt_gammaCP       alter param="gammaCP"       value=LFP_CPCV_gammaCP
Alt_alphaCV       alter param="alphaCV"       value=LFP_CPCV_alphaCV
Alt_SOC_THRESHOLD alter param="SOC_THRESHOLD" value=LFP_CPCV_SOC_THRESHOLD
Alt_R             alter param="R_EV"          value=LFP_CPCV_R
#endif

endcontrol

parameter V_THRESHOLD = 3.5085;

#endif


#ifdef LMO
parameter V_NOM       = 3.7;
parameter Q_NOM       = 2.0;
parameter N_SER       = ceil(EV_VOLTAGE/V_NOM);
parameter N_PAR       = ceil(EV_CAPACITY/(EV_VOLTAGE*Q_NOM));
parameter R_INT       = 0.08*0+0.0870; //[ohm]

Load control begin
        load("mat5","./AUX_FILES/chemistries.mat");
        SOC  = SoC_ref;

#ifdef CASES_FIT
OCV  = V_LMO_FIT;
#else
OCV  = V_LMO;
#endif
        
	R0   = R0_LMO;
        R1   = R1_LMO;

// LOAD PARAMETERS FOR EV SYNTHETIC REPRESENTATION
load("mat5","./AUX_FILES/EV_synthetic_data.mat");
#ifdef CCCV
Alt_aCC           alter param="aCC"           value=LMO_CCCV_aCC
Alt_bCC           alter param="bCC"           value=LMO_CCCV_bCC
Alt_cCC           alter param="cCC"           value=LMO_CCCV_cCC
Alt_dCC           alter param="dCC"           value=LMO_CCCV_dCC
Alt_aCV           alter param="aCV"           value=LMO_CCCV_aCV
Alt_bCV           alter param="bCV"           value=LMO_CCCV_bCV
Alt_cCV           alter param="cCV"           value=LMO_CCCV_cCV
Alt_dCV           alter param="dCV"           value=LMO_CCCV_dCV
Alt_alphaCC       alter param="alphaCC"       value=LMO_CCCV_alphaCC
Alt_alphaCV       alter param="alphaCV"       value=LMO_CCCV_alphaCV
Alt_SOC_THRESHOLD alter param="SOC_THRESHOLD" value=LMO_CCCV_SOC_THRESHOLD
Alt_R             alter param="R_EV"          value=LMO_CCCV_R
#else
Alt_aCP           alter param="aCP"           value=LMO_CPCV_aCP
Alt_aCV           alter param="aCV"           value=LMO_CPCV_aCV
Alt_bCV           alter param="bCV"           value=LMO_CPCV_bCV
Alt_cCV           alter param="cCV"           value=LMO_CPCV_cCV
Alt_dCV           alter param="dCV"           value=LMO_CPCV_dCV
Alt_alphaCP       alter param="alphaCP"       value=LMO_CPCV_alphaCP
Alt_betaCP        alter param="betaCP"        value=LMO_CPCV_betaCP
Alt_deltaCP       alter param="deltaCP"       value=LMO_CPCV_deltaCP
Alt_gammaCP       alter param="gammaCP"       value=LMO_CPCV_gammaCP
Alt_alphaCV       alter param="alphaCV"       value=LMO_CPCV_alphaCV
Alt_SOC_THRESHOLD alter param="SOC_THRESHOLD" value=LMO_CPCV_SOC_THRESHOLD
Alt_R             alter param="R_EV"          value=LMO_CPCV_R
#endif

endcontrol

parameter V_THRESHOLD = 4.1869;

#endif

#ifdef NMC
parameter V_NOM       = 3.6;
parameter Q_NOM       = 2.0;
parameter N_SER       = ceil(EV_VOLTAGE/V_NOM);
parameter N_PAR       = ceil(EV_CAPACITY/(EV_VOLTAGE*Q_NOM));
parameter R_INT       = 0.08*0+0.088; //[ohm]

Load control begin
        load("mat5","./AUX_FILES/chemistries.mat");
        SOC  = SoC_ref;

#ifdef CASES_FIT
OCV  = V_NMC_FIT;
#else
OCV  = V_NMC;
#endif

	R0   = R0_NMC;
        R1   = R1_NMC;

// LOAD PARAMETERS FOR EV SYNTHETIC REPRESENTATION
load("mat5","./AUX_FILES/EV_synthetic_data.mat");
#ifdef CCCV
Alt_aCC           alter param="aCC"           value=NMC_CCCV_aCC
Alt_bCC           alter param="bCC"           value=NMC_CCCV_bCC
Alt_cCC           alter param="cCC"           value=NMC_CCCV_cCC
Alt_dCC           alter param="dCC"           value=NMC_CCCV_dCC
Alt_aCV           alter param="aCV"           value=NMC_CCCV_aCV
Alt_bCV           alter param="bCV"           value=NMC_CCCV_bCV
Alt_cCV           alter param="cCV"           value=NMC_CCCV_cCV
Alt_dCV           alter param="dCV"           value=NMC_CCCV_dCV
Alt_alphaCC       alter param="alphaCC"       value=NMC_CCCV_alphaCC
Alt_alphaCV       alter param="alphaCV"       value=NMC_CCCV_alphaCV
Alt_SOC_THRESHOLD alter param="SOC_THRESHOLD" value=NMC_CCCV_SOC_THRESHOLD
Alt_R             alter param="R_EV"          value=NMC_CCCV_R
#else
Alt_aCP           alter param="aCP"           value=NMC_CPCV_aCP
Alt_aCV           alter param="aCV"           value=NMC_CPCV_aCV
Alt_bCV           alter param="bCV"           value=NMC_CPCV_bCV
Alt_cCV           alter param="cCV"           value=NMC_CPCV_cCV
Alt_dCV           alter param="dCV"           value=NMC_CPCV_dCV
Alt_alphaCP       alter param="alphaCP"       value=NMC_CPCV_alphaCP
Alt_betaCP        alter param="betaCP"        value=NMC_CPCV_betaCP
Alt_deltaCP       alter param="deltaCP"       value=NMC_CPCV_deltaCP
Alt_gammaCP       alter param="gammaCP"       value=NMC_CPCV_gammaCP
Alt_alphaCV       alter param="alphaCV"       value=NMC_CPCV_alphaCV
Alt_SOC_THRESHOLD alter param="SOC_THRESHOLD" value=NMC_CPCV_SOC_THRESHOLD
Alt_R             alter param="R_EV"          value=NMC_CPCV_R
#endif

endcontrol

parameter V_THRESHOLD = 4.1861;

#endif


#ifdef NCA
parameter V_NOM       = 3.6;
parameter Q_NOM       = 3.2;
parameter N_SER       = ceil(EV_VOLTAGE/V_NOM);
parameter N_PAR       = ceil(EV_CAPACITY/(EV_VOLTAGE*Q_NOM));
parameter R_INT       = 0.060; //[ohm]

Load control begin
        load("mat5","./AUX_FILES/chemistries.mat");
        SOC  = SoC_ref;

#ifdef CASES_FIT
OCV  = V_NCA_FIT;
#else
OCV  = V_NCA;
#endif

	R0   = R0_NCA;
        R1   = R1_NCA;

// LOAD PARAMETERS FOR EV SYNTHETIC REPRESENTATION
load("mat5","./AUX_FILES/EV_synthetic_data.mat");
#ifdef CCCV
Alt_aCC           alter param="aCC"           value=NCA_CCCV_aCC
Alt_bCC           alter param="bCC"           value=NCA_CCCV_bCC
Alt_cCC           alter param="cCC"           value=NCA_CCCV_cCC
Alt_dCC           alter param="dCC"           value=NCA_CCCV_dCC
Alt_aCV           alter param="aCV"           value=NCA_CCCV_aCV
Alt_bCV           alter param="bCV"           value=NCA_CCCV_bCV
Alt_cCV           alter param="cCV"           value=NCA_CCCV_cCV
Alt_dCV           alter param="dCV"           value=NCA_CCCV_dCV
Alt_alphaCC       alter param="alphaCC"       value=NCA_CCCV_alphaCC
Alt_alphaCV       alter param="alphaCV"       value=NCA_CCCV_alphaCV
Alt_SOC_THRESHOLD alter param="SOC_THRESHOLD" value=NCA_CCCV_SOC_THRESHOLD
Alt_R             alter param="R_EV"          value=NCA_CCCV_R
#else
Alt_aCP           alter param="aCP"           value=NCA_CPCV_aCP
Alt_aCV           alter param="aCV"           value=NCA_CPCV_aCV
Alt_bCV           alter param="bCV"           value=NCA_CPCV_bCV
Alt_cCV           alter param="cCV"           value=NCA_CPCV_cCV
Alt_dCV           alter param="dCV"           value=NCA_CPCV_dCV
Alt_alphaCP       alter param="alphaCP"       value=NCA_CPCV_alphaCP
Alt_betaCP        alter param="betaCP"        value=NCA_CPCV_betaCP
Alt_deltaCP       alter param="deltaCP"       value=NCA_CPCV_deltaCP
Alt_gammaCP       alter param="gammaCP"       value=NCA_CPCV_gammaCP
Alt_alphaCV       alter param="alphaCV"       value=NCA_CPCV_alphaCV
Alt_SOC_THRESHOLD alter param="SOC_THRESHOLD" value=NCA_CPCV_SOC_THRESHOLD
Alt_R             alter param="R_EV"          value=NCA_CPCV_R
#endif

endcontrol

parameter V_THRESHOLD = 4.1793;


#endif

