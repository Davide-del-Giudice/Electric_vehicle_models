// ----------------------------------------------------
//
// Netlist of EV_CONTROLLER
//
// ---------------------------------------------------
subckt EV_CONTROLLER v0d_pan v0q_pan i0d_pan i0q_pan ed_pan eq_pan vcs_d vcs_q iev_d iev_q
parameters V_AC_NOM=400 W_NOM=2*pi*50 S_NOM=200k I_AC_NOM=S_NOM/(3*V_AC_NOM) \
           V_DC_NOM=500 I_DC_NOM=S_NOM/(V_DC_NOM) N_EV=1 \
	   N_SERIES=96 N_PARALLEL=2  R_INT=8m Q_NOM=33.1 \
	   SOC_0=0.82  V_THRESHOLD=4.12 SOC_THRESHOLD=0.8  \
	   P_REF=-1k   Q_REF=0	  MAXDCGAIN=1M 		   \
	   KP_PLL=490  KI_PLL=122.5k       \
	   KP_I=0.142  KI_I=43.909         \
	   KP_PQ =0    KI_PQ=33     \
	   KP_VDC=10m KI_VDC=1000*1+100*0+80*0  \
	   KP_DCDC=1m*10 KI_DCDC=1    \
	   L_F_PU=0.02 C_DC=1m L_DC=0.2m C_F=0.5m CP_SIGNAL=0

// ----------------------------------------------------------
// PARK TRANSFORM OF PCC VOLTAGE AND CURRENT (FROM PAN DQ TO ALTERNATIVE DQ) - PSEUDO PLL
// ----------------------------------------------------------

W1   v0d  gnd  v0d_pan  v0q_pan  theta vcvs func=sqrt(v(v0d_pan)^2+v(v0q_pan)^2)/V_AC_NOM *
     cos( atan2(v(v0q_pan),v(v0d_pan)) - v(theta))*sqrt(3)

W2   v0q  gnd  v0d_pan  v0q_pan  theta vcvs func=sqrt(v(v0d_pan)^2+v(v0q_pan)^2)/V_AC_NOM *
     sin( atan2(v(v0q_pan),v(v0d_pan)) - v(theta))*sqrt(3)

V0_ddg v0_ddg gnd     v0d v0q vcvs func=sqrt(v(v0d)^2 + v(v0q)^2)*V_AC_NOM/sqrt(3)

W3    theta   gnd   v0q    gnd  svcvs numer=[KI_PLL, KP_PLL] denom=[0,1] maxdcgain=MAXDCGAIN ic=0

W4    dw   gnd    theta gnd svcvs numer=[0,1] denom=[1,1/(5*2*pi)] ic=0

W5    omega   gnd    dw    gnd vcvs  func=v(dw) + W_NOM

W6   i0d  gnd  i0d_pan  i0q_pan  theta vcvs func=sqrt(v(i0d_pan)^2+v(i0q_pan)^2)/I_AC_NOM *
     cos( atan2(v(i0q_pan),v(i0d_pan)) - v(theta))*1/9*sqrt(3)

W7   i0q  gnd  i0d_pan  i0q_pan  theta vcvs func=sqrt(v(i0d_pan)^2+v(i0q_pan)^2)/I_AC_NOM *
     sin( atan2(v(i0q_pan),v(i0d_pan)) - v(theta))*1/9*sqrt(3)

// ----------------------------------------------------------
// POWER MEASUREMENTS
// ----------------------------------------------------------

;// ADDED CHECK
;POW_PAN pow_pan gnd v0d_pan v0q_pan i0d_pan i0q_pan vcvs \
;    func=v(v0d_pan)*v(i0d_pan)+v(v0q_pan)*v(i0q_pan)

// Power exchange from before converter filter (it includes its losses)
P_PCC p_pcc gnd v0d_pan v0q_pan i0d_pan i0q_pan vcvs \
    func=v(v0d_pan)*v(i0d_pan)+v(v0q_pan)*v(i0q_pan)

Q_PCC q_pcc gnd v0d_pan v0q_pan i0d_pan i0q_pan vcvs \
    func=v(v0q_pan)*v(i0d_pan)-v(v0d_pan)*v(i0q_pan)

// Power exchange from after converter filter (it does not include its losses)
P_CONV p_conv gnd ed_pan eq_pan i0d_pan i0q_pan vcvs \
    func=v(ed_pan)*v(i0d_pan)+v(eq_pan)*v(i0q_pan)

// ----------------------------------------------------------
// DC VOLTAGE AND REACTIVE POWER REGULATION (OUTER LOOP)
// ----------------------------------------------------------
Vdcref vdc_ref gnd vsource vdc=1
Vdcreg id_ref vdc vdc_ref VDC_REG MAX=2 MIN=-2 KP=KP_VDC KI=KI_VDC CF=1M S_NOM=S_NOM
Qref q_ref gnd vsource vdc=0
Qreg iq_ref v0d v0q i0d i0q q_ref Q_REG MAX=2 MIN=-2 KP=KP_PQ KI=KI_PQ CF=1M

// ----------------------------------------------------------
// INNER LOOP
// ----------------------------------------------------------

LOOP_DP ed i0d v0d i0q id_ref omega INNER_LOOP KP=KP_I KI=KI_I L=L_F_PU GAIN=-1 \
                                 W=W_NOM MAXGAIN=MAXDCGAIN
LOOP_QP eq i0q v0q i0d iq_ref omega INNER_LOOP KP=KP_I KI=KI_I L=L_F_PU GAIN=+1 \
                                 W=W_NOM MAXGAIN=MAXDCGAIN

// ----------------------------------------------------------
// PARK TRANSFORM OF REFERENCE VOLTAGE (FROM ALTERNATIVE DQ TO PAN DQ)
// ----------------------------------------------------------

W8 ed_pan  gnd  ed  eq  theta vcvs func=sqrt(v(ed)^2+v(eq)^2)*V_AC_NOM/sqrt(3) *
                                    cos(v(theta) + atan2(v(eq),v(ed)))

W9 eq_pan  gnd  ed  eq  theta vcvs func=sqrt(v(ed)^2+v(eq)^2)*V_AC_NOM/sqrt(3) *
                                    sin(v(theta) + atan2(v(eq),v(ed))) 

;POW_MIN pow_min gnd ed_pan eq_pan i0d_pan i0q_pan vcvs \
;    func=v(ed_pan)*v(i0d_pan)+v(eq_pan)*v(i0q_pan)

// USE CONTROLLED CURRENT SOURCES TO REPLICATE IDENTICAL EVs BEING CHARGED
ID vcs_d gnd iev_d gnd vccs gain1=-max(0,N_EV-1)
IQ vcs_q gnd iev_q gnd vccs gain1=-max(0,N_EV-1)


N_EV number gnd vsource vdc=N_EV

// ----------------------------------------------------------
// DC SIDE
// ----------------------------------------------------------

ACDC_COUPLER a gnd nport \
    sensen="ed_pan" sensen="eq_pan" sensen="i0d_pan" sensen="i0q_pan" \
	func1=i(p1)*max(V_DC_NOM,v(p1)) - (v(ed_pan)*v(i0d_pan) + v(eq_pan)*v(i0q_pan))

Vdc   vdc gnd a gnd vcvs gain=1/V_DC_NOM
Ildc ildc gnd ccvs sensedev="Ldc" gain1=1

Cdc a gnd capacitor c=C_DC ic=V_DC_NOM

Ix  a   b Dsw5 ildc vccs func=v(Dsw5)*v(ildc)
Vx  b gnd Dsw5 a    vcvs func=v(Dsw5)*v(a)
Ldc b   c inductor  l=L_DC
Cf  c gnd capacitor C=C_F
Rx  c   d resistor  r=0.01m
;Dx  d   e DIO
Dx  d  e vsource vdc=0

;R_parasite a c resistor r=1M

BAT e  i_batt_raw v_cell i_cell soc BATTERY \
	N_SERIES=N_SERIES N_PARALLEL=N_PARALLEL \
	R_INT=R_INT Q_NOM=Q_NOM SOC_0=SOC_0


// ----------------------------------------------------------
// DC/DC CONVERTER CONTROL
// ----------------------------------------------------------

CP_signal CP_signal gnd vsource vdc=CP_SIGNAL

Ibref i_batt_ref gnd vsource vdc=(S_NOM/(V_THRESHOLD*N_SERIES))/I_DC_NOM
Ib    i_batt     gnd i_batt_raw gnd vcvs gain=1/(I_DC_NOM)
Vbref v_batt_ref gnd vsource vdc=V_THRESHOLD*N_SERIES/V_DC_NOM
Vb    v_batt     gnd e gnd vcvs gain=1/(V_DC_NOM)
Pbref p_batt_ref gnd vsource vdc=1
Pb    p_batt gnd v_batt i_batt vcvs func=v(v_batt)*v(i_batt)

vbraw  v_batt_raw  gnd e gnd vcvs gain=1
pbraw  p_batt_raw  gnd p_batt gnd vcvs gain=S_NOM

BATTERY_CONTROL p_batt_ref CP_signal v_cell soc \
		status_CP status_CC status_CV DCDC_CONTROL \
		V_THRESHOLD=V_THRESHOLD SOC_THRESHOLD=SOC_THRESHOLD \
		I_NOM=I_DC_NOM/N_PARALLEL R_INT=R_INT

P_ref p_ref gnd i_batt_ref v_batt_ref p_batt_ref v_batt i_batt status_CC status_CV status_CP vcvs \
	func=v(p_batt_ref)*v(status_CP) + \
	     v(v_batt)*v(i_batt_ref)*v(status_CC) + \
	     v(v_batt_ref)*v(i_batt)*v(status_CV)

Err_p err_p gnd p_ref p_batt vcvs func=v(p_ref,p_batt)
Reg_p Dsw5 err_p gnd PI_REG KP=KP_DCDC KI=KI_DCDC MAX=0.998 MIN=10m CF=1M

ends


// -----------------------------
//  INNER_LOOP
//  Current regulation
//  Inner current loop
// ----------------------------

subckt INNER_LOOP u_out i_mea v_mea i_comp i_ref omega
parameters KP=1 KI=1 MAXGAIN=1 W=1 L=1 GAIN=1

Error err   gnd i_ref i_mea  svcvs numer=[KI,KP] denom=[0,1] \
                                   maxdcgain=MAXGAIN ic=0 
Uout  u_out gnd err   i_comp omega v_mea vcvs \
         func=v(v_mea) + v(err) + v(i_comp)*v(omega)*GAIN*L/W

ends

// -----------------------------
//  P_REG
//  Active power regulation
//  d_axis outer loop
// ----------------------------

subckt P_REG idp_ref vd vq id iq p_ref 
parameters KP=1 KI=1 MAX=1 MIN=1 CF=1

Pmod a_pwr gnd vd vq id iq vcvs func=v(vd)*v(id) + v(vq)*v(iq)

Pmea p_mea gnd a_pwr gnd svcvs numer=[1] denom=[1] 
Idpi idp_ref  p_ref p_mea PI_REG  KP=KP KI=KI MAX=MAX MIN=MIN CF=CF

ends

//  DC power regulation
//  d_axis outer loop
// ----------------------------

subckt P_REG_DC idp_ref vdc idc p_ref 
parameters KP=1 KI=1 MAX=1 MIN=1 CF=1 S_NOM=1

Pmod a_pwr gnd vdc idc vcvs func=-v(vdc)*v(idc)/S_NOM

Pmea p_mea gnd a_pwr gnd svcvs numer=[1] denom=[1] 
;Pmea p_mea gnd a_pwr gnd svcvs numer=[WN^2] denom=[WN^2,2*XI*WN,1] ;ic=0
Idpi idp_ref  p_ref p_mea PI_REG  KP=KP KI=KI MAX=MAX MIN=MIN CF=CF

ends

// -----------------------------
//  VDC_REG
//  DC voltage regulation
//  d_axis outer loop
// ----------------------------

subckt VDC_REG idp_ref vdc vdc_ref 
parameters KP=1 KI=1 MAX=1 MIN=1 CF=1 S_NOM=1

Vdcmea vdc_mea gnd vdc gnd vcvs gain=1
Idtmp idp_tmp  vdc_ref vdc_mea PI_REG  KP=KP KI=KI MAX=MAX MIN=MIN CF=CF
Idpi idp_ref  gnd idp_tmp gnd vcvs gain=-1


ends

// -----------------------------
//  Q_REG
//  Reactive power regulation
//  q_axis outer loop
// ----------------------------

subckt Q_REG iqp_ref vd vq id iq q_ref
parameters KP=1 KI=1 MAX=1 MIN=1 CF=1

Qmod r_pwr gnd vd vq id iq vcvs func= v(vq)*v(id) - v(vd)*v(iq) 

Qmea  q_mea gnd r_pwr gnd svcvs numer=[1] denom=[1] 
Iqpi  iqp_ref  q_mea q_ref PI_REG  KP=KP KI=KI MAX=MAX MIN=MIN CF=CF

ends

// -----------------------------
//  PI_REG
//  PI Regulator
//  (Anti Wind-up included)
// ----------------------------

subckt PI_REG out ref mea 
parameters KP=1 KI=1 MAX=1 MIN=-1 CF=1k MAXDCGAIN=1M

Ecor  e_cor  gnd   in out ref mea vcvs func=v(out,in)*CF+v(ref,mea)
Err_i err_i  gnd e_cor gnd     svcvs numer=[1] denom=[0,1] maxdcgain=MAXDCGAIN
In       in  gnd   err_i   ref mea vcvs func=KP*v(ref,mea)+KI*v(err_i)
Out     out  gnd    in         vcvs func=limit(v(in),MIN,MAX)

ends

// -----------------------------
//  BATTERY
//  Battery
//  Still under development
//  To do: describe parameters
// ----------------------------

subckt BATTERY a i_batt v_cell i_cell soc 
parameters N_SERIES=1 N_PARALLEL=1 R_INT=1 Q_NOM=1 SOC_0=0.5 ;ETA_CHARGE=1

V1 a   gnd b gnd  vcvs gain=N_SERIES
I1 gnd b          cccs sensedev="V1" gain1=1/N_PARALLEL 

ICELL i_cell gnd  ccvs sensedev="V1" gain1=1/N_PARALLEL

;R  b   ocv   resistor r=R_INT

#ifdef RESET
E1 b gnd ocv i_cell soc CELL SOC_0=SOC_0 Q_NOM=Q_NOM R_INT=R_INT RESET=1 ;ETA_CHARGE=ETA_CHARGE
#else
E1 b gnd ocv i_cell soc CELL SOC_0=SOC_0 Q_NOM=Q_NOM R_INT=R_INT RESET=0 ;ETA_CHARGE=ETA_CHARGE
#endif

IBATT i_batt gnd  ccvs sensedev="V1" gain1=1
VCELL v_cell gnd  b gnd vcvs gain=1

ends


