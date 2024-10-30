clearvars;
close all;
clc;

cd
addpath Data_retrieval/

addpath ../Matlab_new

charging_mode_list  = {'CCCV','CPCV'};
chemistry_list      = {'LFP','LMO','NMC','NCA'};

%% Select charging mode.

for idx1 = 1:2
    charging_mode = charging_mode_list{idx1};

    for idx2  = 1:4
        chemistry = chemistry_list{idx2};

        %% Beware: Load:K_22_Aggregate in loads.dss was deleted.
        %% Beware: Line K22_feeder in substation.dss was deleted.
        S_NOM       = 50; % Nominal EV power in kW
        DEC_SOC0    = 0.01;
        soc         = 0.1:DEC_SOC0:0.9;
        PLOT        = 1;
        SAVE        = 1;

        %% NECESSARY SETUP FOR THE OPENDSS INTERFACE
        DSSObj = actxserver('OpenDSSEngine.DSS');
        if ~DSSObj.Start(0)
            disp('Unable to start the OpenDSS Engine');
            return
        end
        DSSText         = DSSObj.Text;
        DSSCircuit      = DSSObj.ActiveCircuit;
        DSSLoadShapes   = DSSCircuit.LoadShapes;
        DSSMonitors     = DSSCircuit.Monitors;
        DSSPVSystems    = DSSCircuit.PVSystems;
        DSSTransformers = DSSCircuit.Transformers;


        %% DEFINE MAIN CIRCUIT
        DSSText.Command = 'Compile [F:\Docs\2023\ev_models\OpenDSS\Master_EV.dss]';
        DSSText.Command = 'Redirect xfmrs_EV.dss';
        DSSText.Command = 'Redirect loads_EV.txt';
        DSSText.Command = 'set mode=snap';
        DSSText.Command = 'solve';

        %always rememeber to include a "solve" command in Master otherwise the plot
        %of the circuit won't be displayed
        % DSSText.Command = 'Buscoords F:\Desktop\EV_new_submission\OpenDSS\Buscoords_EV.dss';

        %% EDIT EV DATA
        myElementNames = DSSCircuit.AllElementNames;

        Pt              = zeros(numel(soc),1);
        Qt              = zeros(numel(soc),1);
        P_single_EV     = zeros(numel(soc),1);
        Q_single_EV     = zeros(numel(soc),1);
        Ia              = zeros(numel(soc),1);
        Ib              = zeros(numel(soc),1);
        Ic              = zeros(numel(soc),1);
        In              = zeros(numel(soc),1);
        Line_losses     = zeros(numel(soc),1);
        Trafo_losses    = zeros(numel(soc),1);
        Total_losses    = zeros(numel(soc),1);

        EV  = findEVparameters(chemistry,charging_mode,...
            'EV_synthetic_data.mat','loads_EV.txt');

        % UPDATE EV PARAMETERS BASED ON CHARGING MODE AND CHEMISTRY
        for k = 1:size(EV.name,2)
            if strcmp(charging_mode,'CCCV') == 1
                DSSText.Command = ...
                    append("Edit ", EV.name{1,k},                   ...
                    " model=9",                                     ...
                    " aCC=",          num2str(EV.aCC),        ...
                    " bCC=",          num2str(EV.bCC),        ...
                    " cCC=",          num2str(EV.cCC),        ...
                    " dCC=",          num2str(EV.dCC),        ...
                    " aCV=",          num2str(EV.aCV),        ...
                    " bCV=",          num2str(EV.bCV),        ...
                    " cCV=",          num2str(EV.cCV),        ...
                    " dCV=",          num2str(EV.dCV),        ...
                    " alphaCC=",      num2str(EV.alphaCC),    ...
                    " alphaCV=",      num2str(EV.alphaCV),    ...
                    " ChargeType=",   num2str(0),                   ...
                    " SOC_THRESHOLD=", num2str(EV.SOC_THRESHOLD), ...
                    " R_F=",         num2str(EV.R_EV),          ...
                    " kW=",           num2str(S_NOM));
            else
                DSSText.Command = ...
                    append("Edit ", EV.name{k},                     ...
                    " model=9",                                     ...
                    " aCP=",           num2str(EV.aCP),        ...
                    " aCV=",           num2str(EV.aCV),        ....
                    " bCV=",           num2str(EV.bCV),        ...
                    " cCV=",           num2str(EV.cCV),        ...
                    " dCV=",           num2str(EV.dCV),        ...
                    " alphaCP=",       num2str(EV.alphaCP),    ...
                    " betaCP=",        num2str(EV.betaCP),     ...
                    " deltaCP=",       num2str(EV.deltaCP),    ...
                    " gammaCP=",       num2str(EV.gammaCP),    ...
                    " alphaCV=",       num2str(EV.alphaCV),    ...
                    " ChargeType=",    num2str(1),                   ...
                    " SOC_THRESHOLD=", num2str(EV.SOC_THRESHOLD), ...
                    " R_F=",         num2str(EV.R_EV),          ...
                    " kW=",            num2str(S_NOM));
            end
        end

        tic
        for n = 1:numel(soc)
            EV.SOC0 = soc(n);

            % UDPATE EV INITIAL SOC
            for k = 1:size(EV.name,2)
                DSSText.Command = ...
                    append("Edit ",EV.name{1,k}," SOC0=",num2str(EV.SOC0));
            end

            DSSText.Command = 'solve';
            DSSActiveElement = DSSCircuit.ActiveCktElement;
            DSSCircuit.SetActiveElement('ElectricVehicle.EV_10548933');
            tmp = DSSActiveElement.TotalPowers;
            P_single_EV(n) = tmp(1)*1e3; %without 1e3 they are expressed in [kW]
            Q_single_EV(n) = tmp(2)*1e3; %without 1e3 they are expressed in [kW]

            DSSCircuit.SetActiveElement('Transformer.T2');
            myCurr = DSSActiveElement.CurrentsMagAng;
            myPow = DSSActiveElement.Powers;

            Ia(n)  = myCurr(9);  % phase a current at transformer
            Ib(n)  = myCurr(11); % phase b current at transformer
            Ic(n)  = myCurr(13); % phase c current at transformer
            In(n)  = myCurr(15);

            Pt(n)  = -(sum(myPow(9:2:13)));
            Qt(n)  = -(sum(myPow(10:2:14)));

            DSSCircuit.SetActiveElement('Line.OH_10580818');
            myCurr = DSSActiveElement.CurrentsMagAng;

            tmp      = DSSCircuit.LineLosses*1e3;  %without 1e3 they are expressed in [kW]
            Line_losses(n) = tmp(1) + 1i*tmp(2);


            tmp      = DSSCircuit.Losses;
            Trafo_losses(n) = tmp(1) + 1i*tmp(2) - Line_losses(n);
            Total_losses(n) = tmp(1) + 1i*tmp(2);

            % myNodes = DSSCircuit.AllNodeNames;
            % myVolt = DSSCircuit.AllBusVmagPu;
            %
            % V1_min_mag(i,j)  = min(myVolt,[],'all');
            % idx              = find(myVolt == V1_min_mag(i,j));
            % Vmin_bus_name{i,j} = myNodes{idx};
        end
        toc

        %% SAVE RESULTS
        if SAVE
            name = strcat('../Matlab_new/Data/sweep_feeder/SWEEP_',...
                chemistry,'_',charging_mode,'_OPENDSS.mat');
            save(name,'soc','Pt','Qt','Ia','Ib','Ic',...
                'Line_losses','Trafo_losses','Total_losses','P_single_EV');
        end

    end
end