function EV = findEVparameters(chemistry, charging_mode, fitting, netlist)

LFP = 0;
LMO = 0;
NMC = 0;
NCA = 0;
CCCV = 0;
CPCV = 0;

if strcmp(chemistry,'LFP') == 1
    LFP = 1;
elseif strcmp(chemistry,'LMO') == 1
    LMO = 1;
elseif strcmp(chemistry,'NMC') == 1
    NMC = 1;
elseif strcmp(chemistry,'NCA') == 1
    NCA = 1;
else
    disp('One chemistry must be selected among LFP, LMO, NMC, NCA')
end


if strcmp(charging_mode,'CCCV') == 1
    CCCV = 1;
elseif strcmp(charging_mode,'CPCV') == 1
    CPCV = 1;
else
    disp('One charging mode must be selected between CCCV and CPCV')
end

load(fitting)

if LFP
    if CCCV
        EV.aCC = LFP_CCCV_aCC;
        EV.bCC = LFP_CCCV_bCC;
        EV.cCC = LFP_CCCV_cCC;
        EV.dCC = LFP_CCCV_dCC;
        EV.alphaCC = LFP_CCCV_alphaCC;
        EV.aCV = LFP_CCCV_aCV;
        EV.bCV = LFP_CCCV_bCV;
        EV.cCV = LFP_CCCV_cCV;
        EV.dCV = LFP_CCCV_dCV;
        EV.alphaCV = LFP_CCCV_alphaCV;
        EV.SOC_THRESHOLD = LFP_CCCV_SOC_THRESHOLD;
        EV.R_EV          = LFP_CCCV_R;
    else
        EV.aCP = LFP_CPCV_aCP;
        EV.alphaCP = LFP_CPCV_alphaCP;
        EV.betaCP  = LFP_CPCV_betaCP;
        EV.deltaCP = LFP_CPCV_deltaCP;
        EV.gammaCP = LFP_CPCV_gammaCP;
        EV.aCV = LFP_CPCV_aCV;
        EV.bCV = LFP_CPCV_bCV;
        EV.cCV = LFP_CPCV_cCV;
        EV.dCV = LFP_CPCV_dCV;
        EV.alphaCV = LFP_CPCV_alphaCV;
        EV.SOC_THRESHOLD = LFP_CPCV_SOC_THRESHOLD;
        EV.R_EV          = LFP_CPCV_R;
    end

elseif LMO
    if CCCV
        EV.aCC = LMO_CCCV_aCC;
        EV.bCC = LMO_CCCV_bCC;
        EV.cCC = LMO_CCCV_cCC;
        EV.dCC = LMO_CCCV_dCC;
        EV.alphaCC = LMO_CCCV_alphaCC;
        EV.aCV = LMO_CCCV_aCV;
        EV.bCV = LMO_CCCV_bCV;
        EV.cCV = LMO_CCCV_cCV;
        EV.dCV = LMO_CCCV_dCV;
        EV.alphaCV = LMO_CCCV_alphaCV;
        EV.SOC_THRESHOLD = LMO_CCCV_SOC_THRESHOLD;
        EV.R_EV          = LMO_CCCV_R;
    else
        EV.aCP = LMO_CPCV_aCP;
        EV.alphaCP = LMO_CPCV_alphaCP;
        EV.betaCP  = LMO_CPCV_betaCP;
        EV.deltaCP = LMO_CPCV_deltaCP;
        EV.gammaCP = LMO_CPCV_gammaCP;
        EV.aCV = LMO_CPCV_aCV;
        EV.bCV = LMO_CPCV_bCV;
        EV.cCV = LMO_CPCV_cCV;
        EV.dCV = LMO_CPCV_dCV;
        EV.alphaCV = LMO_CPCV_alphaCV;
        EV.SOC_THRESHOLD = LMO_CPCV_SOC_THRESHOLD;
        EV.R_EV          = LMO_CPCV_R;
    end

elseif NMC
    if CCCV
        EV.aCC = NMC_CCCV_aCC;
        EV.bCC = NMC_CCCV_bCC;
        EV.cCC = NMC_CCCV_cCC;
        EV.dCC = NMC_CCCV_dCC;
        EV.alphaCC = NMC_CCCV_alphaCC;
        EV.aCV = NMC_CCCV_aCV;
        EV.bCV = NMC_CCCV_bCV;
        EV.cCV = NMC_CCCV_cCV;
        EV.dCV = NMC_CCCV_dCV;
        EV.alphaCV = NMC_CCCV_alphaCV;
        EV.SOC_THRESHOLD = NMC_CCCV_SOC_THRESHOLD;
        EV.R_EV          = NMC_CCCV_R;
    else
        EV.aCP = NMC_CPCV_aCP;
        EV.alphaCP = NMC_CPCV_alphaCP;
        EV.betaCP  = NMC_CPCV_betaCP;
        EV.deltaCP = NMC_CPCV_deltaCP;
        EV.gammaCP = NMC_CPCV_gammaCP;
        EV.aCV = NMC_CPCV_aCV;
        EV.bCV = NMC_CPCV_bCV;
        EV.cCV = NMC_CPCV_cCV;
        EV.dCV = NMC_CPCV_dCV;
        EV.alphaCV = NMC_CPCV_alphaCV;
        EV.SOC_THRESHOLD = NMC_CPCV_SOC_THRESHOLD;
        EV.R_EV          = NMC_CPCV_R;
    end

else
    if CCCV
        EV.aCC = NCA_CCCV_aCC;
        EV.bCC = NCA_CCCV_bCC;
        EV.cCC = NCA_CCCV_cCC;
        EV.dCC = NCA_CCCV_dCC;
        EV.alphaCC = NCA_CCCV_alphaCC;
        EV.aCV = NCA_CCCV_aCV;
        EV.bCV = NCA_CCCV_bCV;
        EV.cCV = NCA_CCCV_cCV;
        EV.dCV = NCA_CCCV_dCV;
        EV.alphaCV = NCA_CCCV_alphaCV;
        EV.SOC_THRESHOLD = NCA_CCCV_SOC_THRESHOLD;
        EV.R_EV          = NCA_CCCV_R;
    else
        EV.aCP = NCA_CPCV_aCP;
        EV.alphaCP = NCA_CPCV_alphaCP;
        EV.betaCP  = NCA_CPCV_betaCP;
        EV.deltaCP = NCA_CPCV_deltaCP;
        EV.gammaCP = NCA_CPCV_gammaCP;
        EV.aCV = NCA_CPCV_aCV;
        EV.bCV = NCA_CPCV_bCV;
        EV.cCV = NCA_CPCV_cCV;
        EV.dCV = NCA_CPCV_dCV;
        EV.alphaCV = NCA_CPCV_alphaCV;
        EV.SOC_THRESHOLD = NCA_CPCV_SOC_THRESHOLD;
        EV.R_EV          = NCA_CPCV_R;
    end
end

txt = readlines(netlist);


% Find all rows including ElectricVehicle
searched_string = 'ElectricVehicle';

EV.name = string(1);

k = 1;
for i = 1:size(txt,1)
    j = strfind(txt{i},searched_string);
    if ~isempty(j)

        tmp        = txt{i}(j:end);
        idx = find(isspace(tmp) == 1,1,'first');
        EV.name{k} = tmp(1:idx-1);
        k = k + 1;
    end
end


