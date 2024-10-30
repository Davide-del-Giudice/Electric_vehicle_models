clearvars;
close all;
clc;


opts = detectImportOptions('BusCoords_EV.txt');
opts      = setvartype(opts,{'BusName','XCoord','YCoord'},{'char','double','double'})
Buscoords = readtable('Buscoords_EV.txt',opts);

BusName   = Buscoords.BusName;
XCoord    = Buscoords.XCoord;
YCoord    = Buscoords.YCoord;

idx_load  = 1;
idx_EV    = 1;

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
DSSText.Command = 'Compile [F:\Docs\2023\ev_models\Opendss\Master_EV.dss]';
DSSText.Command = 'Redirect xfmrs_EV.dss';
DSSText.Command = 'Redirect loads_EV.txt';
DSSText.Command = 'set mode=snap';
DSSText.Command = 'solve';  


%always rememeber to include a "solve" command in Master otherwise the plot
%of the circuit won't be displayed 

DSSText.Command = 'Buscoords F:\Docs\2023\ev_models\Opendss\Buscoords_EV.dss';

Plot_transformers         =  0;
Transformer_marker_code  =  1;
Transformer_marker_color = 'Blue';
Transformer_marker_size  = 0.5;

Plot_loads         =  1;
Load_marker_code  =  10;
Load_marker_color = 'Red';
Load_marker_size  = 0.05;

Plot_EVs        =  1;
EV_marker_code  =  25;
EV_marker_color = 'Green';
EV_marker_size  = 0.05;

Transformer_data = [];
Load_data        = [];
EV_data          = [];

Element_Names = DSSCircuit.AllElementNames;
DSSActiveElement = DSSCircuit.ActiveCktElement;



for i = 1:numel(Element_Names)
    if contains(Element_Names(i),'Transformer') == 1 && Plot_transformers == 1

        DSSCircuit.SetActiveElement(string(Element_Names(i)));
        Bus = string(DSSActiveElement.BusNames);
        Bus = Bus(1);

        idx = strfind(Bus,'.');
        if ~isempty(idx)
            Bus = Bus{1}(1:idx-1);
        end

        DSSText.Command = append("AddBusMarker", ...
            " Bus=", Bus,   ...
            " code=",num2str(Transformer_marker_code), ...
            " color=",Transformer_marker_color, ...
            " size=", num2str(Transformer_marker_size));

  



    elseif contains(Element_Names(i),'Load') == 1 && Plot_loads == 1

        DSSCircuit.SetActiveElement(string(Element_Names(i)));
        Bus = string(DSSActiveElement.BusNames);

        idx = strfind(Bus,'.');
        if ~isempty(idx)
            Bus = Bus{1}(1:idx-1);
        end


        idx = find(strcmp(BusName,Bus) == 1);
        Loads.BusName(idx_load,1) = BusName(idx);
        Loads.XCoord(idx_load,1)  = XCoord(idx);
        Loads.YCoord(idx_load,1)  = YCoord(idx);
        idx_load = idx_load + 1;


        DSSText.Command = append("AddBusMarker", ...
            " Bus=", Bus,   ...
            " code=",num2str(Load_marker_code), ...
            " color=",Load_marker_color, ...
            " size=", num2str(Load_marker_size));

    elseif contains(Element_Names(i),'ElectricVehicle') == 1 && Plot_EVs == 1
        DSSCircuit.SetActiveElement(string(Element_Names(i)));
        Bus = string(DSSActiveElement.BusNames);

        idx = strfind(Bus,'.');
        if ~isempty(idx)
            Bus = Bus{1}(1:idx-1);
        end

        idx = find(strcmp(BusName,Bus) == 1);
        EVs.BusName(idx_EV,1) = BusName(idx);
        EVs.XCoord(idx_EV,1)  = XCoord(idx);
        EVs.YCoord(idx_EV,1)  = YCoord(idx);
        idx_EV = idx_EV + 1;

        DSSText.Command = append("AddBusMarker", ...
            " Bus=", Bus,   ...
            " code=",num2str(EV_marker_code), ...
            " color=",EV_marker_color, ...
            " size=", num2str(EV_marker_size));

    end

end

DSSText.Command = 'AddBusMarker Bus=10580818 code=36 color=Purple size=2';
% DSSText.Command = 'AddBusMarker Bus=ld_10549294 code=36 color=Purple size=2';


        idx = find(strcmp(BusName,"10580818") == 1);
        Substation.BusName(1) = BusName(idx);
        Substation.XCoord(1)  = XCoord(idx);
        Substation.YCoord(1)  = YCoord(idx);
        
DSSText.Command = 'set mode=snap';
DSSText.Command = 'solve';

DSSText.Command = 'Plot Daisy dots=n labels=y subs=n C1=Black 1phLinestyle=3 3phLinestyle=1';


%% Additional file

grid_data = readtable('DSSGraph_Output.CSV','Delimiter',{' '});

for i = 1: size(grid_data,1)
    grid_data.X1_{i} = grid_data.X1_{i}(1:end-1); 
    k = strfind(grid_data.X1_{i},',');
    if ~isempty(k)
    grid_data.X1_{i}(k) = '.'; 
    end
    grid_data.X1_{i} = str2double( grid_data.X1_{i}); 

    grid_data.X2_{i} = grid_data.X2_{i}(1:end-1); 
    k = strfind(grid_data.X2_{i},',');
    if ~isempty(k)
    grid_data.X2_{i}(k) = '.'; 
    end
    grid_data.X2_{i} = str2double( grid_data.X2_{i}); 

    grid_data.Y1_{i} = grid_data.Y1_{i}(1:end-1); 
    k = strfind(grid_data.Y1_{i},',');
    if ~isempty(k)
    grid_data.Y1_{i}(k) = '.'; 
    end
    grid_data.Y1_{i} = str2double( grid_data.Y1_{i}); 


    grid_data.Y2_{i} = grid_data.Y2_{i}(1:end-1); 
    k = strfind(grid_data.Y2_{i},',');
    if ~isempty(k)
    grid_data.Y2_{i}(k) = '.'; 
    end
    grid_data.Y2_{i} = str2double( grid_data.Y2_{i}); 

    grid_data.RGBColor_{i} = str2double(grid_data.RGBColor_{i});
    grid_data.Width_{i} = str2double(grid_data.Width_{i});
    % grid_data.StyleCode{i} = str2double(grid_data.StyleCode{i});

end

x1      = cell2mat(grid_data.X1_);
y1      = cell2mat(grid_data.Y1_);
x2      = cell2mat(grid_data.X2_);
y2      = cell2mat(grid_data.Y2_);
width   = cell2mat(grid_data.Width_);
RGB     = cell2mat(grid_data.RGBColor_);
StyleCode = grid_data.StyleCode;


%% Convert colors from RGB to array representation
tmp = dec2hex(RGB);
LineColor = zeros(numel(RGB),3);

for i = 1:numel(RGB)
    str = tmp(i,:);
    LineColor(i,:) = sscanf(str(2:end),'%2x%2x%2x',[1 3])/255;
end

%% Linestyle
LineStyle = strings(numel(x1),1);
for i = 1:numel(StyleCode)
    if StyleCode(i) == 1
    LineStyle(i) = '-';
    elseif StyleCode(i) == 3
    LineStyle(i) = '--';
    end
end

%% Save everything
save('Data_feeder.mat','Loads','EVs','Substation',...
    'x1','x2','y1','y2','width','LineStyle','LineColor')