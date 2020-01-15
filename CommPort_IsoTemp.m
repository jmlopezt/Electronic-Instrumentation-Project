%% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike CC BY-NC-SA License
%%
%% This license lets others remix, tweak, and build upon your work non-commercially, as long as they credit 
%% you and license their new creations under the identical terms.
%%
%% To view a copy of the license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode




function retval=CommPort_IsoTemp(Instrument,serialPort,Tiempo,verbose,RW_command,actionCommand,value)

% Versión 1: (1/1/2018 Juan Manuel López Torralba
%           AC Serial Communications Protocol IsoTemp 6200 R35
%           Driver


%Once the serial port reference is created, it will be accessible the next time the file is used.
global serialObject;

%%

if (ischar(Instrument))
    instrument=Instrument;
else
    instrument=Instrument.Name;
    serialPort=Instrument.serialPort;
end
%% Serial Object Definition

serialObject = serial(serialPort, 'baud', 19200,...
    'StopBits',1 ,...
    'DataBits', 8,...
    'Parity', 'none',...
    'Timeout', Tiempo,...
    'Terminator','CR',...
    'FlowControl', 'none');
%                'ReadAsyncMode', 'Continuous',...
%                'ReadAsyncMode', 'manual',...
%                'Timeout', 1,...
%
fopen(serialObject);
%A=fread(serialObject);

%% BEGIN CODE

if (strcmpi(instrument, 'isotemp') || strcmpi(instrument, 'all'))
    
    switch RW_command
        case 'read'
            switch actionCommand
                
                case 'temperature'                     % Read: Internal Temperature in ºC/F/K (it depends on the Instrument internal configuration)
                    fprintf(serialObject,'RT');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Internal Temperature [ºC/F/K]:',retval); end
                    
                case 'temperature_2'                   % Read: External Temperature in ºC/F/K (it depends on the Instrument internal configuration)
                    fprintf(serialObject,'RT2');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: External Temperature [ºC/F/K]:',retval); end
                    
                case 'displayed_setpoint'              % Read: Displayed Setpoint Temperature in ºC/F/K (it depends on the Instrument internal configuration)
                    fprintf(serialObject,'RS');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Displayed Setpoint [ºC/F/K]:',retval); end
                    
                case 'internal_RTA1'                   % Read: Real (internal) Temperature Adjustments (RTA 1) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RIRTA1');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Internal RTA 1 [ºC/F/K]:',retval); end
                    
                case 'internal_RTA2'                   % Read: Real (internal) Temperature Adjustments (RTA 2) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RIRTA2');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Internal RTA 2 [ºC/F/K]:',retval); end
                    
                case 'internal_RTA3'                   % Read: Real (internal) Temperature Adjustments (RTA 3) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RIRTA3');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Internal RTA 3 [ºC/F/K]:',retval); end
                    
                case 'internal_RTA4'                   % Read: Real (internal) Temperature Adjustments (RTA 4) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RIRTA4');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Internal RTA 4 [ºC/F/K]:',retval); end
                    
                case 'internal_RTA5'                   % Read: Real (internal) Temperature Adjustments (RTA 5) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RIRTA5');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Internal RTA 5 [ºC/F/K]:',retval); end
                    
                case 'external_RTA1'     % Read: Real (external) Temperature Adjustments (RTA 1) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RERTA1');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: External RTA 1 [ºC/F/K]:',retval); end
                    
                case 'external_RTA2'     % Read: Real (external) Temperature Adjustments (RTA 2) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RERTA2');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: External RTA 2 [ºC/F/K]:',retval); end
                    
                case 'external_RTA3'     % Read: Real (external) Temperature Adjustments (RTA 3) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RERTA3');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: External RTA 3 [ºC/F/K]:',retval); end
                    
                case 'external_RTA4'     % Read: Real (external) Temperature Adjustments (RTA 4) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RERTA4');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: External RTA 4 [ºC/F/K]:',retval); end
                    
                case 'external_RTA5'     % Read: Real (external) Temperature Adjustments (RTA 5) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'RERTA5');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: External RTA 5 [ºC/F/K]:',retval); end
                    
                case 'setpoint_1'                      % Read: Setpoint 1 temperature in ºC/F/K (The setpoint is the desired fluid temperature).
                    fprintf(serialObject,'RS1');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Setpoint 1 [ºC/F/K]:',retval); end
                    
                case 'setpoint_2'                      % Read: Setpoint 2 temperature in ºC/F/K.
                    fprintf(serialObject,'RS2');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Setpoint 2 [ºC/F/K]:',retval); end
                    
                case 'setpoint_3'                      % Read: Setpoint 3 temperature in ºC/F/K.
                    fprintf(serialObject,'RS3');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Setpoint 3 [ºC/F/K]:',retval); end
                    
                case 'setpoint_4'                      % Read: Setpoint 4 temperature in ºC/F/K.
                    fprintf(serialObject,'RS4');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Setpoint 4 [ºC/F/K]:',retval); end
                    
                case 'setpoint_5'                      % Read: Setpoint 5 temperature in ºC/F/K.
                    fprintf(serialObject,'RS5');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Setpoint 5 [ºC/F/K]:',retval); end
                    
                case 'high_temperature_fault'          % Read: High temperature fault in ºC/F/K.
                    fprintf(serialObject,'RHTF');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: High temperature fault value [ºC/F/K]:',retval); end
                    
                case 'high_temperature_warn'          % Read: High temperature warning in ºC/F/K.
                    fprintf(serialObject,'RHTW');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: High temperature warning value [ºC/F/K]:',retval); end
                    
                case 'low_temperature_fault'          % Read: Low temperature fault in ºC/F/K.
                    fprintf(serialObject,'RLTF');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Low temperature fault value [ºC/F/K]:',retval); end
                    
                case 'low_temperature_warn'           % Read: Low temperature warning in ºC/F/K.
                    fprintf(serialObject,'RLTW');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Low temperature warning value [ºC/F/K]:',retval); end
                    
                case 'proportional_heat_band_setting'          % Read: Proportional heat band setting in %.
                    fprintf(serialObject,'RPH');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Percentage of proportional HEAT band setting [%]:',retval); end
                    
                case 'proportional_cool_band_setting'           % Read: Proportional cool band setting in %.
                    fprintf(serialObject,'RPC');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Percentage of proportional COOL band setting:',retval); end
                    
                case 'integral_heat_band_setting'               % Read: Integrall heat band setting in Repeats per minute.
                    fprintf(serialObject,'RIH');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Integral HEAT band setting [RepeatsPerMinute]:',retval); end
                    
                case 'integral_cool_band_setting'               % Read: Integral cool band setting in Repeats per minute.
                    fprintf(serialObject,'RIC');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Integral COOL band setting [RepeatsPerMinute]:',retval); end
                    
                case 'derivative_heat_band_setting'             % Read: Derivative heat band setting in minutes.
                    fprintf(serialObject,'RDH');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Derivative HEAT band setting [Minutes]:',retval); end
                    
                case 'derivative_cool_band_setting'             % Read: Derivative COOL band setting in minutes.
                    fprintf(serialObject,'RDC');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Derivative COOL band setting [Minutes]:',retval); end
                    
                case 'temperature_precision'                    % Read: Temperature precision.
                    fprintf(serialObject,'RTP');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Temperature Precision:',retval); end
                    
                case 'temperature_units'                        % Read: Temperature units [ºC/F/K].
                    fprintf(serialObject,'RTU');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Temperature units [ºC/F/K]:',retval); end
                    
                case 'unit_on'                                  % Read: Units. True or False [1/0].
                    fprintf(serialObject,'RO');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Show Temperature units [ºC/F/K] status bit:',retval); end
                    
                case 'external_probe_enabled'                   % Read: External Probe enabled. Enabled/Disabled [1/0].
                    fprintf(serialObject,'RE');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Reading External Probe status bit:',retval); end
                    
                case 'auto_restart_enabled'                     % Read: Auto Restart enabled. Enabled/Disabled [1/0].
                    fprintf(serialObject,'RAR');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Auto Restart status bit:',retval); end
                    
                case 'energy_saving_mode'                       % Read: External Probe enabled. Enabled/Disabled [1/0].
                    fprintf(serialObject,'REN');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200:  Energy saving mode status bit:',retval); end
                    
                case 'time'                                     % Read: Time [hh:mm:ss].
                    fprintf(serialObject,'RCK');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: The current time is:',retval); end
                    
                case 'date'                                     % Read: Date [mm/dd/yy] or [dd/mm/yy].
                    fprintf(serialObject,'RDT');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: The current date ([mm/dd/yy] or [dd/mm/yy]) is :',retval); end
                    
                case 'date_format'                              % Read: Date Format [mm/dd/yy] or [dd/mm/yy].
                    fprintf(serialObject,'RDF');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: The date format is:',retval); end
                    
                case 'ramp_status'                              % Read: Ramp Status [Stopped/Running/Paused].
                    fprintf(serialObject,'RRS');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: The Ramp Status [Stopped/Running/Paused] is:',retval); end
                    
                case 'firmware_version'                         % Read: Firmware Version.
                    fprintf(serialObject,'RVER');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: The Firmware version is:',retval); end
                    
                case 'firmware_checksum'                         % Read: Firmware Checksum.
                    fprintf(serialObject,'RSUM');
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: The Firmware Checksum is:',retval); end
                    
                case 'unit_fault_status'             % This command returns 5 values. These are decimal representations of hexadecimal values. Each individual bit of the value represents a different warning, fault or status.
                    fprintf(serialObject,'RUFS');
                    [V1,V2,V3,V4,V5] = fscanf(serialObject,'%s');
                    retval = [V1;V2;V3;V4;V5];
                    if verbose >=2, fprintf(1,'%s %s\n','isoTemp 6200: Read Unit Fault System:',retval); end
                    
            end
            
            
        case 'set'
            switch 'actionCommand'
                
                case 'displayed_setpoint'              % Set: Displayed Setpoint Temperature in ºC/F/K (it depends on the Instrument internal configuration)
                    fprintf(serialObject,'SS %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Set displayed setpoint to ',value,'ºC :',retval); end
                    
                case 'internal_RTA1'     % Set: Real (internal) Temperature Adjustments (RTA 1) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SIRTA1 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 1 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'internal_RTA2'     % Set: Real (internal) Temperature Adjustments (RTA 2) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SIRTA2 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 2 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'internal_RTA3'     % Set: Real (internal) Temperature Adjustments (RTA 3) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SIRTA3 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 3 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'internal_RTA4'     % Set: Real (internal) Temperature Adjustments (RTA 4) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SIRTA4 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 4 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'internal_RTA5'     % Set: Real (internal) Temperature Adjustments (RTA 5) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SIRTA5 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 5 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'external_RTA1'     % Set: Real (external) Temperature Adjustments (RTA 1) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SERTA1 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 1 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'external_RTA2'     % Set: Real (external) Temperature Adjustments (RTA 2) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SERTA2 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 2 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'external_RTA3'     % Set: Real (external) Temperature Adjustments (RTA 3) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SERTA3 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 3 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'external_RTA4'     % Set: Real (external) Temperature Adjustments (RTA 4) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SERTA4 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 4 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'external_RTA5'     % Set: Real (external) Temperature Adjustments (RTA 5) in ºC/F/K. The RTA can be set ±10°C (±18°F).
                    fprintf(serialObject,'SERTA4 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Internal RTA 5 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'setpoint_1'                      % Set: Setpoint 1 temperature in ºC/F/K (The setpoint is the desired fluid temperature).
                    fprintf(serialObject,'SS1 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Setpoint 1 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'setpoint_2'                      % Set: Setpoint 2 temperature in ºC/F/K.
                    fprintf(serialObject,'SS2 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Setpoint 2 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'setpoint_3'                      % Set: Setpoint 3 temperature in ºC/F/K.
                    fprintf(serialObject,'SS3 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Setpoint 3 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'setpoint_4'                      % Set: Setpoint 4 temperature in ºC/F/K.
                    fprintf(serialObject,'SS4 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Setpoint 4 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'setpoint_5'                      % Set: Setpoint 5 temperature in ºC/F/K.
                    fprintf(serialObject,'SS5 %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Setpoint 5 set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'high_temperature_fault'          % Set: High temperature fault in ºC/F/K.
                    fprintf(serialObject,'SHTF %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: High temperature fault value set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'high_temperature_warn'          % Set: High temperature warning in ºC/F/K.
                    fprintf(serialObject,'SHTW %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: High temperature warning value set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'low_temperature_fault'          % Set: Low temperature fault in ºC/F/K.
                    fprintf(serialObject,'SLTF %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Low temperature fault value set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'low_temperature_warn'           % Set: Low temperature warning in ºC/F/K.
                    fprintf(serialObject,'SLTW %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Low temperature warning value set to ',value,'[ºC/F/K] :',retval); end
                    
                case 'proportional_heat_band_setting'          % Set: Proportional heat band setting in %.
                    fprintf(serialObject,'SPH %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Percentage of proportional Heat band setting set to ',value,': ',retval); end
                    
                case 'proportional_cool_band_setting'           % Set: Proportional cool band setting in %.
                    fprintf(serialObject,'SPC %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Percentage of proportional Cool band setting set to ',value,': ',retval); end
                    
                case 'integral_heat_band_setting'               % Set: Integrall heat band setting in Repeats per minute.
                    fprintf(serialObject,'SIH %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Integral heat band setting set to ',value,'[RepeatPerMinute]: ',retval); end
                    
                case 'integral_cool_band_setting'               % Set: Integral cool band setting in Repeats per minute.
                    fprintf(serialObject,'SIC %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Integral cool band setting set to ',value,'[RepeatPerMinute]: ',retval); end
                    
                case 'derivative_heat_band_setting'             % Set: Derivative heat band setting in minutes.
                    fprintf(serialObject,'SDH %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Derivative heat band setting set to ',value,'[Minutes]: ',retval); end
                    
                case 'derivative_cool_band_setting'             % Set: Derivative cool band setting in minutes.
                    fprintf(serialObject,'SDC %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Derivative cool band setting set to ',value,'[Minutes]: ',retval); end
                    
                case 'temperature_resolution'                    % Set: Temperature resolution.
                    fprintf(serialObject,'STR %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Temperature Resolution set to ',value,'[ºC]: ',retval); end
                    
                case 'temperature_units'                        % Set: Temperature units [ºC].
                    fprintf(serialObject,'STU %s',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Temperature unit set to ',value,' (ºC): ',retval); end
                    
                case 'unit_on_status'                           % Set: Unit Status. True or False [1/0].
                    fprintf(serialObject,'SO %d',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Temperature unit status  bit set to ',value,' :',retval); end
                    
                case 'external_probe_on_status'                   % Set: External Probe ON status. Enabled/Disabled [1/0].
                    fprintf(serialObject,'SE %d',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: External Probe status bit set to',value,' :',retval); end
                    
                case 'auto_restart_enabled'                     % Set: Auto Restart bit status. Enabled/Disabled [1/0].
                    fprintf(serialObject,'SAR %d',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Auto Restart status bit set to ',value,': ',retval); end
                    
                case 'energy_saving_mode'                       % Set: Energy saving mode bit status. Enabled/Disabled [1/0].
                    fprintf(serialObject,'SEN %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Energy saving mode status bit set to ',value,': ',retval); end
                    
                case 'pump_speed'                       % Set: Pump Speed [L/M/H](Low/Medium/High).
                    fprintf(serialObject,'SPS %s',value);
                    retval = fscanf(serialObject,'%s');
                    
                    if strcmpi(value, 'L')
                        aux = 'Low';
                    elseif strcmpi(value, 'H')
                        aux = 'High';
                    else
                        aux = 'Medium';
                    end
                    
                    if verbose >=2, fprintf(1,'%s %s %s %s\n','isoTemp 6200: Pump speed set to ',aux,' :',retval); end
                    clear aux;
                    
                case 'ramp_number'                              % Set: Ramp Status [Stopped/Running/Paused].
                    fprintf(serialObject,'SRN %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Ramp Status set to ',value,' :',retval); end
                    
            end 
    end
    
end

fclose(serialObject);
delete(serialObject);
clear serialObject;

end