%% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike CC BY-NC-SA License
%%
%% This license lets others remix, tweak, and build upon your work non-commercially, as long as they credit 
%% you and license their new creations under the identical terms.
%%
%% To view a copy of the license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode


%% Programa para la caracterización de Paneles Fotovoltaicos.
%  Fecha: 01/05/18
%
%
%  Llamado: por el GranaSAT-SUITE
%
% v05: (Juan Manuel López Torralba) 01/05/18
%
%   - Minor errors fixed
%   - Added Kethley & HP instrument variables previously lost
%   - Real time measurement data plot
%   - GUI changes:
%           1. New data boxes for real time display.
%           2. maxIteration box is now available.
%
% v04: (Juan Manuel López Torralba) 22/04/18
%
%   - Added the Keithley KUSB-3116 16-Bit USB DAQ Module:
%       - Instrument Menu Section.
%       - Data Acquisition:
%           1. Plot window.
%           2. Acquisition channel window.
%           3. Real Time measurement window.
%           4. Save Plots & data
%
% v03: (Juan Manuel López Torralba) 15/04/18
%
%   - Minor Changes involving the GUI design has been made:
%       - The Stop button has been deleted.
%       - The Run Button has now two functionalities:
%           1. Run the program.
%           2. Stop the program changing its Text field properties.
%               a. The main program can now be stopped before the
%                   Operation begining.
%               b. The main program can now be stopped after the operation
%                   had finished and before the data representation.
%
%
% v02: (Juan Manuel López Torralba) 28/01/18
%
%   - Main Run routine has been modified.
%       - Added a Global var called finished for interruption purposes.
%       - The main process is now inside a while loop with two conditions:
%           1. Global Variable finished == false.
%           2. Run pushbutton Text field = 'Run'.
%
%   - A File menu including the following items has been added:
%       - Load tab: It allows you to load var ('.mat') into the program.
%       - Save tab: It allows you to save important data into a var ('.mat').
%           The data types are saved as struct (including the graphs):
%       - Exit tab: It closes the window.
%
%   - An Instruments menu including the following items has been added:
%       -HP_E3631A tab:
%           1. Power Supply image.
%           2. Datasheet buttons(.txt).
%           3. Close.
%       -KeySight tab:
%           1. Electronic Load image.
%           2. Datasheet buttons(.txt).
%           3. Close.
%   - About menu added:
%       - Credits tab:
%           1. Credits image.
%           2. Author & license info(.txt).
%           3. Close button.
%
%   - Added a global variable called PV_MeasuredValues to store measurement data
%   from the experiment and be then stored in the SAVE tab.
%
%
% v01:
%   - Modificación de la ventana inicial diseñada por Juan Manuel.
%   - Añadido de las variables globales almacenadas en
%    d:\MATLAB\GranaSAT_Tracker_V15\configuration\saved_devices_addresses.mat
%   - Rellenado de los valores de las celdas a partir de las variables
%   guardadaas.
%   - Guardado a fichero.mat con el nombre del fichero  de la ventana.





function varargout = PV_TEST_GUI(varargin)
% PV_TEST_GUI MATLAB code for PV_TEST_GUI.fig
%      PV_TEST_GUI, by itself, creates a new PV_TEST_GUI or raises the existing
%      singleton*.
%
%      H = PV_TEST_GUI returns the handle to a new PV_TEST_GUI or the handle to
%      the existing singleton*.
%
%      PV_TEST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PV_TEST_GUI.M with the given input arguments.
%
%      PV_TEST_GUI('Property','Value',...) creates a new PV_TEST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PV_TEST_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PV_TEST_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PV_TEST_GUI

% Last Modified by GUIDE v2.5 01-May-2018 12:16:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @PV_TEST_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @PV_TEST_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%% Arranque de la Aplicación --- Executes just before PV_TEST_GUI is made visible.
function PV_TEST_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PV_TEST_GUI (see VARARGIN)

% Paths adding

path('measure\solar_panels\Config_instruments\',path);

% Global variables adding

global PV_Solar_Panel_Measurement;
global HP_E3631A_PowerSupply;
global KEYSIGHT_6063B_ElecLoad;

% Para acceder a las lecturas y seleccionar el canal del Keithley KUSB-3116 16-Bit USB DAQ Module
global ai;
global ch;

%Para poder acceder al texto y el indicador de progreso de la Barra de
%Estado.
global statusbarObj;
global jProgressBar;

load('.\Config_instruments\KeySight_6063B_config.mat');
load('.\Config_instruments\HP_E3631A_config.mat');

% DATA PRESENTATION

set(handles.edit_Vmax,'string',[ num2str(PV_Solar_Panel_Measurement.Vmax) ' V']);
set(handles.edit_Vmin,'string',[ num2str(PV_Solar_Panel_Measurement.Vmin) ' V']);
set(handles.edit_Imax,'string',[ num2str(PV_Solar_Panel_Measurement.Imax) ' A']);
set(handles.edit_Imin,'string',[ num2str(PV_Solar_Panel_Measurement.Imin) ' A']);
set(handles.edit_Samples,'string',num2str(PV_Solar_Panel_Measurement.n_samples_voltage));
set(handles.edit_Delay,'string',[ num2str(PV_Solar_Panel_Measurement.Delay_Between_Samples) ' s']);
set(handles.edit_VStep,'string',[ num2str(PV_Solar_Panel_Measurement.Voltage_step) ' V']);
set(handles.edit_kusb_channel,'string',[ num2str(PV_Solar_Panel_Measurement.kusb_channel) ' Ch' ]);
set(handles.edit_maxIterations,'string',num2str(PV_Solar_Panel_Measurement.maxIterations));
set(handles.edit_DataFileName,'string',PV_Solar_Panel_Measurement.DataFileName);


set(handles.MPP_edit,'string','-');
set(handles.FillFactor_edit,'string','-');
set(handles.Voc_edit,'string','-');
set(handles.Isc_edit,'string','-');
set(handles.edit_kusb_measurement,'string','-');
set(handles.edit_measuredCurrent,'string','-');

% Checking the DAQ status

try
    ai = analoginput ('dtol',0);
    ch = addchannel (ai, 0);
    testvar=getsample(ai);
catch
    errordlg('Connect the Keithley KUSB DAQ Module to an avalaible USB port and then restart MATLAB','Keithley KUSB DAQ Module not found');
end

clear testvar ch ;

%Vamos a meter una barra de STATUS en la parte inferior de la ventana
hfig=figure(handles.figure_PV_TEST);

jFrame = get(hfig,'JavaFrame');
jFigPanel = get(jFrame,'FigurePanelContainer');
jRootPane = jFigPanel.getComponent(0).getRootPane;
% If invalid RootPane, retry up to N times
tries = 10;
while isempty(jRootPane) & tries>0  %#ok for Matlab 6 compatibility - might happen if figure is still undergoing rendering...
    drawnow; pause(0.001);
    tries = tries - 1;
    jRootPane = jFigPanel.getComponent(0).getRootPane;
end
jRootPane = jRootPane.getTopLevelAncestor;

% Get the existing statusbarObj
statusbarObj = jRootPane.getStatusBar;

% If no statusbarObj yet, create it
if isempty(statusbarObj)
    statusbarObj = com.mathworks.mwswing.MJStatusBar;
    jProgressBar = javax.swing.JProgressBar;
    jProgressBar.setVisible(false);
    statusbarObj.add(jProgressBar,'West');  % 'West' => left of text; 'East' => right
    % Beware: 'East' also works but doesn't resize automatically
    jRootPane.setStatusBar(statusbarObj);
end

%Mensaje a salir en la parte inferior
statusbarObj.setText('Status Bar Messages');
jRootPane.setStatusBarVisible(1);
set(jProgressBar, 'Minimum',0, 'Maximum',10, 'Value',0);
jProgressBar.setVisible(true);
jProgressBar.setStringPainted(true);
jProgressBar.setIndeterminate(false);
%      set(sb.CornerGrip, 'visible',false);
%      set(sb.TextPanel, 'Foreground',java.awt.Color(1,0,0), 'Background',java.awt.Color.cyan, 'ToolTipText','tool tip...')
%      set(sb, 'Background',java.awt.Color.cyan);

%Con esto actualizamos el indicador de progreso de la barra de Status
set(jProgressBar,'Value',get(jProgressBar,'Value')+1);

%   Examples customizing the status-bar appearance:
%      sb = statusbar('text');
%      set(sb.CornerGrip, 'visible',false);
%      set(sb.TextPanel, 'Foreground',java.awt.Color(1,0,0), 'Background',java.awt.Color.cyan, 'ToolTipText','tool tip...')
%      set(sb, 'Background',java.awt.Color.cyan);

% Choose default command line output for PV_TEST_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PV_TEST_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure_PV_TEST);


% --- Outputs from this function are returned to the command line.
function varargout = PV_TEST_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RUN_pushbutton.
function RUN_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RUN_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% HP-E3631A

global HP_E3631A_PowerSupply;
global KEYSIGHT_6063B_ElecLoad;
global PV_Solar_Panel_Measurement;
global PV_MeasuredValues;
global finished;

global jProgressBar
global statusbarObj

global ai;
global ch;

% Bootstrap color definition
red = hex2rgb('d9534f');
blue = hex2rgb('428bca');
white = hex2rgb('f9f9f9');
purple = hex2rgb('aa66cc');

if strcmp(get(handles.RUN_pushbutton,'string'),'Stop')
    finished=true;
else
    finished = false;
end

statusbarObj.setText('Initializing variables...');
%% Interruptible is On by default

while (strcmp(get(handles.RUN_pushbutton,'string'),'Run') && (finished==false))
    
    set(handles.RUN_pushbutton,'string','Stop','ForegroundColor','white','BackgroundColor',red,'enable','on');
    drawnow
    disp('Now is running')
    
    %Updating from windows GUI variables to Global variables.
    
    PV_Solar_Panel_Measurement.Vmax=sscanf(get(handles.edit_Vmax,'string'),'%f');
    PV_Solar_Panel_Measurement.Vmin=sscanf(get(handles.edit_Vmin,'string'),'%f');
    PV_Solar_Panel_Measurement.Imax=sscanf(get(handles.edit_Imax,'string'),'%f');
    PV_Solar_Panel_Measurement.Imin=sscanf(get(handles.edit_Imin,'string'),'%f');
    PV_Solar_Panel_Measurement.n_samples_voltage=sscanf(get(handles.edit_Samples,'string'),'%f');
    %PV_Solar_Panel_Measurement.n_samples_voltage=sscanf(get(handles.popupmenu_nSamplesVoltage_solarPanel,'string'),'%f');
    PV_Solar_Panel_Measurement.Delay_Between_Samples=sscanf(get(handles.edit_Delay,'string'),'%f');
    PV_Solar_Panel_Measurement.Voltage_step=sscanf(get(handles.edit_VStep,'string'),'%f');
    PV_Solar_Panel_Measurement.DataFileName=get(handles.edit_DataFileName,'string');
    % Keithley KUSB-3116 variables
    PV_Solar_Panel_Measurement.kusb_channel=sscanf(get(handles.edit_kusb_channel,'string'),'%f');
    PV_Solar_Panel_Measurement.maxIterations=sscanf(get(handles.edit_maxIterations,'string'),'%f');
    save('.\configuration\saved_devices_addresses.mat','PV_Solar_Panel_Measurement','-append')
    
    curr=[];
    volt=[];
    diff_volt_read_set=[]; % Diferencia entre el voltaje leido y el que habiamos fijado a la carga
    Verbose=2;
    var_V=[]; %Varianza de las muestras de tensión
    var_I=[]; %Varianza de las muestras de corriente
    date_x=[];
    
    solar_kusb = [];
    
    try
        if PV_Solar_Panel_Measurement.kusb_channel < 15 && ...
                (rem(PV_Solar_Panel_Measurement.kusb_channel,fix(PV_Solar_Panel_Measurement.kusb_channel)) == 0)
            ch = addchannel (ai, PV_Solar_Panel_Measurement.kusb_channel);
        else
            warndlg('The channel entry must be an Integer between 0 & 15 ',' Warning !')
        end
    catch
        errordlg('Please fill the form','Not enough arguments');
    end
    
    %Clear all error messages
    clc;
    
    %Con esto actualizamos el indicador de progreso de la barra de Status
    set(jProgressBar,'Value',get(jProgressBar,'Value')+2);
    statusbarObj.setText('Instruments Comm');
    
    
    % Stop the execution before Operation
    if finished
        if (strcmp(get(handles.RUN_pushbutton,'string'),'Stop'))
            set(handles.RUN_pushbutton,'string','Run','ForegroundColor',white,'BackgroundColor',blue,'enable','on'); % ver si debería poner enable off
        end
        %Con esto actualizamos el indicador de progreso de la barra de Status
        set(jProgressBar,'Value',get(jProgressBar,'Value')-2);
        statusbarObj.setText('Pause');
        %  clear all
        break
    end
    
    %% Operation
 
    %kpib(Instrument, command, value, channel, aux, verbose)
    
    % Power Supply HP-E3631A: BOOST OPERATION (1/2)
    
    kpib(HP_E3631A_PowerSupply, 'init',0,0,0,Verbose);
    kpib(HP_E3631A_PowerSupply, 'instrument_id',0,0,0,Verbose);
    kpib(HP_E3631A_PowerSupply, 'on',0,HP_E3631A_PowerSupply.Channel,0,Verbose);
    kpib(HP_E3631A_PowerSupply, 'setV',HP_E3631A_PowerSupply.Boost_Voltage,HP_E3631A_PowerSupply.Channel,0,Verbose);      % set the voltage
    
    
    % Electronic Load KEYSIGHT-6063B: Sweep Voltage - Measure Current
    
    kpib(KEYSIGHT_6063B_ElecLoad, 'init',0,0,0,Verbose);
    kpib(KEYSIGHT_6063B_ElecLoad, 'instrument_id',0,0,0,Verbose);
    kpib(KEYSIGHT_6063B_ElecLoad, 'on',0,0,0,Verbose);
    kpib(KEYSIGHT_6063B_ElecLoad, 'mode','cv',0,0,Verbose);
    
    % Lanza un error: -420, "QueryUnterminated"                 SOLVED
    % kpib(KEYSIGHT_6063B_ElecLoad, 'error',0,0,0,Verbose);
    
    condition = true;
    numIterations = 0;
    maxIterations = PV_Solar_Panel_Measurement.maxIterations;
    %maxIterations = 540; % More than you ever expect to have.
    %Voltage_step=0.01;    % 0.3 V
    
    set(jProgressBar,'Value',get(jProgressBar,'Value')+2);
    statusbarObj.setText('Performing test ...');
    
    
    %Creamos la barra de progreso
    d = com.mathworks.mlwidgets.dialog.ProgressBarDialog.createProgressBar('test...', []);
    d.setValue(0.0);                        % default = 0
    d.setProgressStatusLabel('testing...');  % default = 'Please Wait'
    d.setSpinnerVisible(true);               % default = true
    d.setCircularProgressBar(false);         % default = false  (true means an indeterminate (looping) progress bar)
    d.setCancelButtonVisible(true);          % default = true
    d.setVisible(true);                      % default = false
    
    while condition
        % do something
        
        kpib(KEYSIGHT_6063B_ElecLoad.Name, 'setV',KEYSIGHT_6063B_ElecLoad.Voltage,0,0,Verbose);       % set VOLTAGE
        pause(PV_Solar_Panel_Measurement.Delay_Between_Samples);
        % read CURRENT
        for i=1:PV_Solar_Panel_Measurement.n_samples_voltage
            I_read_samples(i)=kpib(KEYSIGHT_6063B_ElecLoad.Name, 'read','curr',0,0,Verbose);
            pause(PV_Solar_Panel_Measurement.Delay_Between_Samples);
            V_read_samples(i)=kpib(KEYSIGHT_6063B_ElecLoad.Name, 'read','volt',0,0,Verbose);
            pause(PV_Solar_Panel_Measurement.Delay_Between_Samples);
            
        end
        
        aux_V=mean(V_read_samples);
        var_V=[var_V var(V_read_samples)]; % Varianza de las muestras de tension
        aux_I=mean(I_read_samples);
        var_I=[var_I var(I_read_samples)]; % Varianza de las muestras de corriente
        diff_volt_read_set=[diff_volt_read_set aux_V-KEYSIGHT_6063B_ElecLoad.Voltage];% read VOLTAGE
        %     aux_V=KEYSIGHT_6063B_Voltage;
        
        % Updating progress bar
        d.setValue(get(d,'Value')+0.01);
        
        % Storage the data
        curr=[curr aux_I];
        volt=[volt aux_V-HP_E3631A_PowerSupply.Boost_Voltage];    % debemos restar el boost supply
        date_x=[date_x now]
        
        
        % DAQ Acquisition samples
        solar_kusb(numIterations) = getsample(ai);
        % Updating DAQ window
        set(handles.edit_kusb_measurement,'string',[solar_kusb(numIterations)*5.0 ' W/m^{2}']);
        
        % Updating Current measurement window
        set(handles.edit_measuredCurrent,'string',[curr(numIterations) ' A']);
        
        
        
        % Real time PV plot (EXPERIMENTAL)
        axes(handles.DataPlot)
        plot(volt,curr,red);       % Introduced before R2006a
        xlabel('Voltage [V]')
        ylabel('Current [A]')
        hold on
        drawnow
        
        % Real time pyranometer plot (EXPERIMENTAL)
        axes(handles.pyranometerPlot)
        plot(date_x,solar_kusb.*5,blue);       % Introduced before R2006a
        datetick('x', 'yyyy-mm-dd')
        xlabel('Timestamp')
        ylabel(' W/m^{2}')
        hold on
        drawnow
        
        
        % Increment eload voltage.
        
        KEYSIGHT_6063B_ElecLoad.Voltage = KEYSIGHT_6063B_ElecLoad.Voltage + PV_Solar_Panel_Measurement.Voltage_step;
        
        % Increment loop counter.
        numIterations = numIterations + 1;
        
        % Recompute condition for continuing.
        condition = (numIterations < maxIterations) &  (aux_I > 0 & aux_V < PV_Solar_Panel_Measurement.Vmax);          %your while test here.
    end
    
    d.setValue(8.3);
    set(jProgressBar,'Value',get(jProgressBar,'Value')+2);
    statusbarObj.setText('Performing test ...');
    
    
    % Power Supply HP-E3631A: BOOST OPERATION (2/2) (Reverse Bias Region)
    
    % for cont=3:0.1:5
    %
    %     kpib(HP_E3631A_PowerSupply, 'setV',cont,HP_E3631A_PowerSupply.Channel,0,Verbose);      % set the voltage
    %     aux_I_reverse=kpib(KEYSIGHT_6063B_ElecLoad, 'read','curr',0,0,Verbose);
    %
    %     curr_reverse=[curr aux_I_reverse];
    %     volt_reverse=[volt aux_V_reverse];
    % end
    
    % elimino indice negativo de corriente errónea
    
    curr=curr(1:length(curr)-1);
    volt=volt(1:length(curr));
    
    % genero una gráfica de potencia
    
    power=curr.*volt;
    
    %% CALCULATIONS
    
    d.setValue(9.9);
    d.setVisible(false);
    
    set(jProgressBar,'Value',get(jProgressBar,'Value')+1);
    statusbarObj.setText('Data representation');
    
    index_voc=length(curr);    % find the position in the array
    [v_min index_isc]=min(volt);
    
    Voc=volt(index_voc);   % Voc
    Isc=curr(index_isc);   % Isc
    solar_kusb_watt = 5.*solar_kusb;
    
    %MPP_Data=0.25*Voc*Isc;
    MPP_Data=max(power);
    FillFactor=0.25;   % buscar la información
    
    %% DATA PRESENTATION
    set(handles.MPP_edit,'string',[MPP_Data ' W']);
    set(handles.FillFactor_edit,'string',FillFactor);
    set(handles.Voc_edit,'string',[Voc ' V']);
    set(handles.Isc_edit,'string',[Isc ' A']);
    
    
    % Stop the execution before the plot commands if desired
    if finished
        if (strcmp(get(handles.RUN_pushbutton,'string'),'Stop'))
            set(handles.RUN_pushbutton,'string','Run','ForegroundColor',white,'BackgroundColor',blue,'enable','on'); % ver si debería poner enable off
        end
        clear all
        break
    end
    
    %% IV & PV plotyy
    
    % Delete previous DataPlot axes
    
    hold off
    cla reset
    cla (handles.DataPlot,'reset')
    clear axes(handles.DataPlot)
    
    % PLOTyy Creates graph with two y-axes
    axes(handles.DataPlot)
    
    [ax,h1,h2] = plotyy(volt,curr,volt,power,'plot');       % Introduced before R2006a
    %axis([0 20 0 0.06]);
    %set(ax(1),'YLim',[-0.03 0.06])
    %set(ax(2),'YLim',[-0.03 0.6])
    xlabel('Voltage [V]')
    set(get(ax(1), 'YLabel'), 'String', 'Current [A]')
    set(get(ax(2), 'YLabel'), 'String', 'Power [W]')
    set(h1, 'Color', blue,'LineStyle','-','LineWidth',1) % si no funciona cambiar a 'blue'
    set(h2, 'Color', red,'LineStyle','-','LineWidth',1) % si no funciona cambiar a 'red'
    
    
    % Figur for saving plot
    h_figure=figure;
    
    [ax,h1,h2] = plotyy(volt,curr,volt,power,'plot');
    % axis([0 20 0 0.06]);
    xlabel('Voltage [V]')
    title('I-V P-V Curve')
    set(get(ax(1), 'YLabel'), 'String', 'Current [A]')
    set(get(ax(2), 'YLabel'), 'String', 'Power [W]')
    set(h1, 'Color', 'blue','LineStyle','-','LineWidth',1)
    set(h2, 'Color', 'red','LineStyle','-','LineWidth',1)
    
    % Guardar la gráfica obtenida en formato PNG
    image_FolderFile=[pwd '\' date '\' 'IV_Curve_measured.png'];
    saveas(gcf ,image_FolderFile);
    
    %Guardar la imagen en PDF
    set(ax,'Units','Inches');
    pos = get(h_figure,'Position');
    set(h_figure,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(h_figure,'filename','-dpdf','-r0')
    
    %% Solar shortwave plot
    
    % Delete previous pyranometer axes
    
    hold off
    cla reset
    cla (handles.pyranometerPlot,'reset')
    clear axes(handles.pyranometerPlot)
    
    % Experimental
    axes(handles.pyranometerPlot)
    [ax,h1,h2] = plot(date_x,solar_kusb_watt); 
    datetick('x', 'yyyy-mm-dd')
    xlabel('Timestamp')
    set(get(ax(1), 'YLabel'), 'String', 'Solar Irradiance [W / m^{2}]')
    set(h1, 'Color', purple,'LineStyle','-','LineWidth',1)
    
    % Figure for saving plot
    kusb_figure=figure;
    
    [ax2,h3,h4] = plotyy(volt,curr,volt,power,'plot');
    % axis([0 20 0 0.06]);
    ylabel('Solar Irradiance [W / m^{2}')
    title('Solar Shortwave Radiation')
    set(h3, 'Color', purple,'LineStyle','-','LineWidth',1)
    
    % Guardar la gráfica obtenida en formato PNG
    image_FolderFile=[pwd '\' date '\' 'Solar_shortwave_kusb.png'];
    saveas(gcf ,image_FolderFile);
    
    %Guardar la imagen en PDF
    set(ax2,'Units','Inches');
    pos = get(kusb_figure,'Position');
    set(kusb_figure,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
    print(kusb_figure,'filename','-dpdf','-r0')
    
    set(jProgressBar,'Value',9.9);
    %% Save data
    
    % Guardar datos obtenidos y gráficas
    data_FolderFile=[pwd '\' date '\' PV_Solar_Panel_Measurement.DataFileName];
    save(data_FolderFile,'curr','volt','MPP_Data','FillFactor','Voc','Isc','solar_kusb_watt');
    
    % guardar datos en variable global
    
    PV_MeasuredValues.Current = curr;
    PV_MeasuredValues.Voltage = volt;
    PV_MeasuredValues.Power = power;
    PV_MeasuredValues.MaxPowerPoint = MPP_Data;
    PV_MeasuredValues.FillFactor = FillFactor;
    PV_MeasuredValues.Voc = Voc;
    PV_MeasuredValues.Isc = Isc;
    PV_MeasuredValues.VoltageVariance = var_V;
    PV_MeasuredValues.CurrentVariance = var_I;
    PV_MeasuredValues.solar_irradiance = solar_kusb_watt;
    
    finished=true;
    if (strcmp(get(handles.RUN_pushbutton,'string'),'Stop'))
        set(handles.RUN_pushbutton,'string','Run','ForegroundColor',white,'BackgroundColor',blue,'enable','on');
        break;
    end
end

function MPP_edit_Callback(hObject, eventdata, handles)
% hObject    handle to MPP_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MPP_edit as text
%        str2double(get(hObject,'String')) returns contents of MPP_edit as a double


% --- Executes during object creation, after setting all properties.
function MPP_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MPP_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FillFactor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FillFactor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FillFactor_edit as text
%        str2double(get(hObject,'String')) returns contents of FillFactor_edit as a double


% --- Executes during object creation, after setting all properties.
function FillFactor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FillFactor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Voc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Voc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Voc_edit as text
%        str2double(get(hObject,'String')) returns contents of Voc_edit as a double


% --- Executes during object creation, after setting all properties.
function Voc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Voc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Isc_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Isc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Isc_edit as text
%        str2double(get(hObject,'String')) returns contents of Isc_edit as a double


% --- Executes during object creation, after setting all properties.
function Isc_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Isc_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menu_1_Callback(hObject, eventdata, handles)
% hObject    handle to menu_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function GranaSat_logo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GranaSat_logo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate GranaSat_logo
a=imread('GranaSAT_logo.png');
image(a);
axis off


% --- Executes on button press in pushbutton_STOP.
function pushbutton_STOP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_STOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Imax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Imax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Imax as text
%        str2double(get(hObject,'String')) returns contents of edit_Imax as a double


% --- Executes during object creation, after setting all properties.
function edit_Imax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Imax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Vmax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Vmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Vmax as text
%        str2double(get(hObject,'String')) returns contents of edit_Vmax as a double


% --- Executes during object creation, after setting all properties.
function edit_Vmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Vmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Imin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Imin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Imin as text
%        str2double(get(hObject,'String')) returns contents of edit_Imin as a double


% --- Executes during object creation, after setting all properties.
function edit_Imin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Imin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Delay_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Delay as text
%        str2double(get(hObject,'String')) returns contents of edit_Delay as a double


% --- Executes during object creation, after setting all properties.
function edit_Delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Vmin_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Vmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Vmin as text
%        str2double(get(hObject,'String')) returns contents of edit_Vmin as a double


% --- Executes during object creation, after setting all properties.
function edit_Vmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Vmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Samples_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Samples as text
%        str2double(get(hObject,'String')) returns contents of edit_Samples as a double


% --- Executes during object creation, after setting all properties.
function edit_Samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_VStep_Callback(hObject, eventdata, handles)
% hObject    handle to edit_VStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_VStep as text
%        str2double(get(hObject,'String')) returns contents of edit_VStep as a double


% --- Executes during object creation, after setting all properties.
function edit_VStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_VStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_DataFileName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DataFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_DataFileName as text
%        str2double(get(hObject,'String')) returns contents of edit_DataFileName as a double




% --- Executes during object creation, after setting all properties.
function edit_DataFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DataFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Instruments_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Instruments_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function About_menu_Callback(hObject, eventdata, handles)
% hObject    handle to About_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Credits_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Credits_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Se añade el path dónde se encuentra la GUI de créditos
addpath('.\measure\solar_panels\About');

% Llama a los créditos.
creditsSolarPanel;


% --------------------------------------------------------------------
function Load_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Se carga el fichero y se muestra en la GUI de matlab.
% uiopen('*.mat');

[file,folder] = uigetfile('*.mat');
filename = fullfile(folder,file);
data=load(filename);

% --------------------------------------------------------------------
function Save_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global PV_Solar_Panel_Measurement;
global PV_MeasuredValues;

% Se creará la variable 'data' con todos los datos de la ejecución del
% programa, así como de las gráficas.

try
    data.Vmax = PV_Solar_Panel_Measurement.Vmax;
    data.Voc = PV_MeasuredValues.Voc;
    data.Voltage = PV_MeasuredValues.Voltage;
    data.VoltageVariance = PV_MeasuredValues.VoltageVariance;
    
    data.Current = PV_MeasuredValues.Current;
    data.Isc = PV_MeasuredValues.Isc;
    data.CurrentVariance = PV_MeasuredValues.CurrentVariance;
    
    data.Power = PV_MeasuredValues.Power;
    data.MaxPowerPoint = PV_MeasuredValues.MaxPowerPoint;
    data.FillFactor = PV_MeasuredValues.FillFactor;
    
    data.n_samples_voltage = PV_Solar_Panel_Measurement.n_samples_voltage;
    
    data.solar_irradiance = PV_Solar_Panel_Measurement.solar_irradiance
    
    data.PlotIV_PV = get(handles.DataPlot);
    data.Plot_solarIrradiance = get(handles.pyranometerPlot);
    
    % Fecha y hora del guardado. El formato de la fecha y hora será: 'yyyymmddTHHMMSS'
    date = datestr(now,30);
    filename = strcat('DATA-',date);
    uisave('data', filename);
catch ex
    if (strcmp(ex.identifier,'MATLAB:structRefFromNonStruct'))
        disp('No data measured yet');
    end
end





% --------------------------------------------------------------------
function Exit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Exit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hfig=figure(handles.figure_PV_TEST); %en test
delete(hfig);
%delete(hObject);


% --- Executes on selection change in popupmenu_nSamplesVoltage_solarPanel.
function popupmenu_nSamplesVoltage_solarPanel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_nSamplesVoltage_solarPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_nSamplesVoltage_solarPanel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_nSamplesVoltage_solarPanel

switch get(handles.popupmenu_nSamplesVoltage_solarPanel,'Value');
    case 1 % 1 sample
        PV_Solar_Panel_Measurement.n_samples_voltage = 1;
    case 2 % 5 samples
        PV_Solar_Panel_Measurement.n_samples_voltage = 5;
    case 3 % 10 samples
        PV_Solar_Panel_Measurement.n_samples_voltage = 10;
    case 4 % 50 samples
        PV_Solar_Panel_Measurement.n_samples_voltage = 50;
end

set(handles.edit_Samples,'string',num2str(PV_Solar_Panel_Measurement.n_samples_voltage));





% --- Executes during object creation, after setting all properties.
function popupmenu_nSamplesVoltage_solarPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_nSamplesVoltage_solarPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function HP_E3631A_PowerSupply_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to HP_E3631A_PowerSupply_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Se añade el path dónde se encuentra la GUI de créditos
addpath('.\measure\solar_panels\Instruments');
% Llama a al datasheet.
HP_E3631A_info;

% --------------------------------------------------------------------
function KEYSIGHT_6063B_ElecLoad_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to KEYSIGHT_6063B_ElecLoad_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
addpath('.\measure\solar_panels\Instruments');

% Llama a al datasheet.
KeySight_6063B_info;



function edit_kusb_channel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_kusb_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_kusb_channel as text
%        str2double(get(hObject,'String')) returns contents of edit_kusb_channel as a double


% --- Executes during object creation, after setting all properties.
function edit_kusb_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_kusb_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_kusb_measurement_Callback(hObject, eventdata, handles)
% hObject    handle to edit_kusb_measurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_kusb_measurement as text
%        str2double(get(hObject,'String')) returns contents of edit_kusb_measurement as a double


% --- Executes during object creation, after setting all properties.
function edit_kusb_measurement_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_kusb_measurement (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Keithley_KUSB_DAQ_Module_Callback(hObject, eventdata, handles)
% hObject    handle to Keithley_KUSB_DAQ_Module (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

addpath('.\measure\solar_panels\Instruments');

% Llama a al datasheet.
Keithley_KUSB_info;



function edit_maxIterations_Callback(hObject, eventdata, handles)
% hObject    handle to edit_maxIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_maxIterations as text
%        str2double(get(hObject,'String')) returns contents of edit_maxIterations as a double


% --- Executes during object creation, after setting all properties.
function edit_maxIterations_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_maxIterations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_measuredCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to edit_measuredCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_measuredCurrent as text
%        str2double(get(hObject,'String')) returns contents of edit_measuredCurrent as a double


% --- Executes during object creation, after setting all properties.
function edit_measuredCurrent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_measuredCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
