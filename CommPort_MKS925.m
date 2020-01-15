%% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike CC BY-NC-SA License
%%
%% This license lets others remix, tweak, and build upon your work non-commercially, as long as they credit 
%% you and license their new creations under the identical terms.
%%
%% To view a copy of the license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode


function retval=CommPort_mks925(Instrument,serialPort,Tiempo,verbose,RW_command,actionCommand,value)

% Versión 1: (1/8/2018 Juan Manuel López Torralba
%           Serial Communications Protocol MKS 925 MNicroPirani
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

if serialPort
    if ischar(serialPort)
        serialPort = str2num(serialPort);
    end
else 
    serialPort = 123;
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

if (strcmpi(instrument, 'mks925') || strcmpi(instrument, 'all'))
    
    switch RW_command
        case 'query'
            switch actionCommand
                
                case 'baudrate'                  % Query: Baud Rate 
                    fprintf(serialObject,'@%dBR?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK9600;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: Communication Baud Rate:',retval); end
                    
                case 'address'                   % Query: Transducer communication address (001 to 253)
                    fprintf(serialObject,'@%dAD?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK253;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: Transducer communication address:',retval); end
                    
                case 'delay'                     % Query: Communication delay between receive and transmit sequence.
                    fprintf(serialObject,'@%dRSD?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKON;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: Communication delay between receive and transmit sequence:',retval); end
                    
                case 'pressure'                  % Query: Communication delay between receive and transmit sequence.
                    fprintf(serialObject,'@%dPR1?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACK9.00E+2;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani sensor pressure as 3 digit floating point value:',retval); end

                case 'pressure_accurate'         % Query: MicroPirani sensor pressure as 4 digit floating point value.
                    fprintf(serialObject,'@%dPR4?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKSET;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani sensor pressure as 4 digit floating point value:',retval); end

                case 'setpoint_relay_1'         % Query: Setpoint relay 1 status (SET=Relay energized / CLEAR=Relay deenergized)
                    fprintf(serialObject,'@%dSS1?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKSET;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relay 1 status:',retval); end

                case 'setpoint_relay_2'         % Query: Setpoint relay 2 status (SET=Relay energized / CLEAR=Relay deenergized)
                    fprintf(serialObject,'@%dSS2?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relay 2 status:',retval); end

                case 'setpoint_relay_3'         % Query: Setpoint relay 3 status (SET=Relay energized / CLEAR=Relay deenergized)
                    fprintf(serialObject,'@%dSS3?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relay 3 status:',retval); end

                case 'setpoint_switch_1'         % Query: Setpoint 1 switch value 
                    fprintf(serialObject,'@%dSP1?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK1.00E-2;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint switch 1 value:',retval); end

                case 'setpoint_switch_2'         % Query: Setpoint 2 switch value
                    fprintf(serialObject,'@%dSP2?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint switch 2 value:',retval); end

                case 'setpoint_switch_3'         % Query: Setpoint 3 switch value
                    fprintf(serialObject,'@%dSP3?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint switch 3 value:',retval); end

                case 'setpoint_hysteresis_1'         % Query: Setpoint 1 hysteresis switch value 
                    fprintf(serialObject,'@%dSH1?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK1.10E-2;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint hysteresis switch 1 value:',retval); end

                case 'setpoint_hysteresis_2'         % Query: Setpoint 2 hysteresis switch value
                    fprintf(serialObject,'@%dSH2?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint hysteresis switch 2 value:',retval); end

                case 'setpoint_hysteresis_3'         % Query: Setpoint 3 hysteresis switch value
                    fprintf(serialObject,'@%dSH3?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint hysteresis switch 3 value:',retval); end

                case 'setpoint_enable_1'         % Query: Setpoint 1 enable status
                    fprintf(serialObject,'@%dEN1?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK1.10E-2;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint enable status 1:',retval); end

                case 'setpoint_enable_2'         % Query: Setpoint 2 enable status
                    fprintf(serialObject,'@%dEN2?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint enable status 2:',retval); end

                case 'setpoint_enable_3'         % Query: Setpoint 3 enable status
                    fprintf(serialObject,'@%dEN3?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint enable status 3:',retval); end

                case 'setpoint_relaydirection_1'         % Query: Setpoint relaydirection  (ABOVE or BELOW)
                    fprintf(serialObject,'@%dEN1?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKBELOW;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relaydirection 1:',retval); end

                case 'setpoint_relaydirection_2'         % Query: Setpoint relaydirection  (ABOVE or BELOW)
                    fprintf(serialObject,'@%dEN2?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relaydirection 2:',retval); end

                case 'setpoint_relaydirection_3'         % Query: Setpoint relaydirection  (ABOVE or BELOW)
                    fprintf(serialObject,'@%dEN3?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relaydirection 3:',retval); end

                case 'setpoint_safety_relay'         % Query: Setpoint safety delay
                    fprintf(serialObject,'@%dSPD?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKON;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint safety delay:',retval); end

                case 'model_number'         % Query: model number (925)
                    fprintf(serialObject,'@%dMD?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK925;FF  
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Model Number:',retval); end

                case 'device_type'         % Query: Device type name (MicroPirani)
                    fprintf(serialObject,'@%dDT?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACKMICROPIRANI;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Device Type:',retval); end

                case 'manufacturer'         % Query: Manufacturer Name
                    fprintf(serialObject,'@%dMF?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACKMKS;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Manufacturer Name:',retval); end

                case 'hardware_version'         % Query: Hardware version
                    fprintf(serialObject,'@%dHV?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKA;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Hardware version:',retval); end

                case 'firmware_version'         % Query: Firmware version
                    fprintf(serialObject,'@%dFV?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACK1.33;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Firmware version:',retval); end

                case 'serial_number'         % Query: Serial Number
                    fprintf(serialObject,'@%dSN?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACK1302856880;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Serial Number:',retval); end

                case 'switch_enable'         % Query: switch enable
                    fprintf(serialObject,'@%dSW?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACK1302856880;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani switch enable:',retval); end

                case 'time'         % Query: Time on ( hours of operation )
                    fprintf(serialObject,'@%dTIM?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACK277;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Time on ( hours of operation ):',retval); end

                case 'temperature'         % Query: MicroPirani sensor temperature
                    fprintf(serialObject,'@%dTEM?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACK2.57E+1;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani sensor temperature:',retval); end

                case 'text_string'         % Query: MicroPirani user programmed text_string
                    fprintf(serialObject,'@%dUT?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKVACUUM1;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani user programmed text_string:',retval); end

                case 'status_check'         % Query: MicroPirani Transducer status check 
                    fprintf(serialObject,'@%dT?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKO;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Transducer status check:',retval); end

                case 'pressure_unit'         % Query: MicroPirani Pressure unit setup (Torr, mbar, Pascal)
                    fprintf(serialObject,'@%dU?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @123ACKTORR;FF // TORR
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Pressure unit setup:',retval); end

                case 'calibration_gas'         % Query: MicroPirani sensor calibration gas (Nitrogen, Air, Argon, Helium, Hydrogen, H2O, Neon, CO2, Xenon)
                    fprintf(serialObject,'@%dGT?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKNITROGEN;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani sensor calibration gas:',retval); end

                case 'vacuum'                  % Query: Provides delta pressure value between current vacuum zero adjustment and factory calibration.
                    fprintf(serialObject,'@%dVAC?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK5.12E-5;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani delta pressure value:',retval); end

                case 'atmospheric'              % Query: Provides delta pressure value between current current atmospheric adjustment and factory calibration.
                    fprintf(serialObject,'@%dATM?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK1.22E+1;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani delta atmospheric value:',retval); end

                case 'analog_voltage_output_1'              % Query: Analog voltage output 1: Pressure assignment and calibration
                    fprintf(serialObject,'@%dAO1?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK10;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Analog voltage output 1:',retval); end

                case 'analog_voltage_output_2'              % Query: Analog voltage output 2: Pressure assignment and calibration
                    fprintf(serialObject,'@%dAO2?;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK10;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Analog voltage output 2:',retval); end
                    
            end
            
            
        case 'set'
            switch 'actionCommand'
                
                case 'displayed_setpoint'              % Set: Displayed Setpoint Temperature in ºC/F/K (it depends on the Instrument internal configuration)
                    fprintf(serialObject,'SS %f',value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %f %s %s\n','isoTemp 6200: Set displayed setpoint to ',value,'ºC :',retval); end

                case 'setpoint_switch_1'         % Set: Setpoint 1 switch value 
                    fprintf(serialObject,'@%dSP1!%f;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK2.00E+1;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint switch 1 value:',retval); end

                case 'setpoint_switch_2'         % Set: Setpoint 2 switch value
                    fprintf(serialObject,'@%dSP2!%f;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint switch 2 value:',retval); end

                case 'setpoint_switch_3'         % Set: Setpoint 3 switch value
                    fprintf(serialObject,'@%dSP3!%f;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint switch 3 value:',retval); end

                case 'setpoint_hysteresis_1'         % Set: Setpoint 1 hysteresis switch value 
                    fprintf(serialObject,'@%dSH1!%f;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK1.10E-2;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint hysteresis switch 1 value:',retval); end

                case 'setpoint_hysteresis_2'         % Set: Setpoint 2 hysteresis switch value
                    fprintf(serialObject,'@%dSH2!%f;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint hysteresis switch 2 value:',retval); end

                case 'setpoint_hysteresis_3'         % Set: Setpoint 3 hysteresis switch value
                    fprintf(serialObject,'@%dSH3!%f;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint hysteresis switch 3 value:',retval); end

                case 'setpoint_enable_1'         % Set: Setpoint 1 enable status (ON/OFF)
                    fprintf(serialObject,'@%dEN1!%s;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK1.10E-2;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint enable status 1:',retval); end

                case 'setpoint_enable_2'         % Set: Setpoint 2 enable status (ON/OFF)
                    fprintf(serialObject,'@%dEN2!%s;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint enable status 2:',retval); end

                case 'setpoint_enable_3'         % Set: Setpoint 3 enable status (ON/OFF)
                    fprintf(serialObject,'@%dEN3!%s;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint enable status 3:',retval); end

                case 'setpoint_relaydirection_1'         % Set: Setpoint relaydirection  (ABOVE or BELOW)
                    fprintf(serialObject,'@%dEN1!%s;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKBELOW;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relaydirection 1:',retval); end

                case 'setpoint_relaydirection_2'         % Set: Setpoint relaydirection  (ABOVE or BELOW)
                    fprintf(serialObject,'@%dEN2!%s;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relaydirection 2:',retval); end

                case 'setpoint_relaydirection_3'         % Set: Setpoint relaydirection  (ABOVE or BELOW)
                    fprintf(serialObject,'@%dEN3!%s;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint relaydirection 3:',retval); end

                case 'setpoint_safety_relay'         % Set: Setpoint safety delay
                    fprintf(serialObject,'@%dSPD!ON;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKON;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Setpoint safety delay:',retval); end

                case 'baudrate'                  % Set: Baud Rate (4800, 9600, 19200, 38400,57600, 115200, 230400)
                    fprintf(serialObject,'@%dBR!%d;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK19200;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: Communication Baud Rate:',retval); end
                    
                case 'address'                   % Set: Transducer communication address (001 to 253)
                    fprintf(serialObject,'@%dAD!%d;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK253;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: Transducer communication address:',retval); end
                    
                case 'delay'                     % Set: Communication delay between receive and transmit sequence (ON/OFF)
                    fprintf(serialObject,'@%dRSD!%s;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKON;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: Communication delay between receive and transmit sequence:',retval); end

                case 'pressure_unit'         % Set: MicroPirani Pressure unit setup (Torr, mbar, Pascal)
                    fprintf(serialObject,'@%dU!%s;FF',serialPort,value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKMBAR;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Pressure unit setup:',retval); end

                case 'calibration_gas'         % Set: MicroPirani sensor calibration gas (Nitrogen, Air, Argon, Helium, Hydrogen, H2O, Neon, CO2, Xenon)
                    fprintf(serialObject,'@%dGT!%s;FF',serialPort, value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKARGON;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani sensor calibration gas:',retval); end

                case 'vacuum'                  % Set: Executes MicroPirani zero adjustment
                    fprintf(serialObject,'@%dVAC!;FF',serialPort);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani delta pressure value:',retval); end

                case 'atmospheric'              % Set: Executes MicroPirani full scale atmospheric adjustment.
                    fprintf(serialObject,'@%dATM!%f;FF',serialPort, value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani delta atmospheric value:',retval); end

                case 'analog_voltage_output_1'              % Set: analog voltage output 1 calibration
                    fprintf(serialObject,'@%dAO1!%d;FF',serialPort, value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK10;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Analog voltage output 1:',retval); end

                case 'analog_voltage_output_2'              % Set: analog voltage output 2 calibration
                    fprintf(serialObject,'@%dAO2!%d;FF',serialPort, value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACK10;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Analog voltage output 2:',retval); end

                case 'user_tag'              % Set: transducer user tag
                    fprintf(serialObject,'@%dUT!%s;FF',serialPort, value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKLOADLOCK;FF 
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Set transducer user tag:',retval); end   

                case 'user_switch'              % Set: Enable / disable user switch (ON/OFF)
                    fprintf(serialObject,'@%dSW!%s;FF',serialPort, value);
                    retval = fscanf(serialObject,'%s');
                    % Example Response: @xxxACKON;FF
                    if verbose >=2, fprintf(1,'%s %s\n','MKS 925: MicroPirani Enable / disable user switch:',retval); end          
                    
            end 
    end
    
end

fclose(serialObject);
delete(serialObject);
clear serialObject;

end