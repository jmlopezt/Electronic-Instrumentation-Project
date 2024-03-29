% kpib
% KPIB is a framework for operating laboratory instruments that are
%  connected to a computer by GPIB or serial connections.
%  KPIB provides a unified interface for communicating with different
%  instruments of the same type from different manufacturers. KPIB requires
%  the MATLAB Instrument Control toolbox.

function retval = kpib(Instrument, command, value, channel, aux, verbose)

%RETVAL = KPIB(INSTRUMENT, GPIB, COMMAND, VALUE, CHANNEL, AUX, VERBOSE)
%Version Info
versionnum=5.02;
versionstr='kpib.m version 5.02 [NI] (May 2018)';
% Versi�n 5.0.2     Juan Manuel L�pez Torralba
%       HP E3631A
%       KEYSIGHT 6063B ELECTRONIC LOAD
%
%
% Versi�n 5.0.1     Alejandro Toral L�pez
%       A�adidos comandos a la fuente AgilentN6705A para la configuraci�n
%       y activaci�n simult�nea de varios canales.

%% HW Gpib Board Index

if (ischar(Instrument))
    instrument=Instrument;
else
    gpib_interface_BOARDINDEX=Instrument.Logical_Board_Index;
    instrument=Instrument.Name;
    GPIB=Instrument.Gpib_Address;
end

%% BEGIN CODE

% verify that the Instrument Control Toolbox is installed
if ~isdeployed && isempty(ver('instrument'))
    %error('kpib: ERROR (fatal): The Instrument Control Toolbox does not appear to be installed.\n\n')
    if verbose >= 1, fprintf('kpib: WARNING The Instrument Control Toolbox does not appear to be installed.\n\n'); end
end

%% Begin interpreting commands
% The main body of the code  begins here. It consists of a series of if
%  statements which check the value of INSTRUMENT and execute the
%  appropriate code block.

% % Flags
validInst = 0; % validInst will be set if a valid instrument has been called.
%retval=0; % this prevents "output argument not assigned" errors

%% 'version' return kpib version number
if strcmpi(instrument,'version') || strcmpi(instrument,'ver')
    retval=versionnum;
    if verbose > 0
        fprintf(1,'%s\n',versionstr);
    end
    validInst = 1;
end


%% GPIB bus level commands
% Low-level commands that apply to any instrument- close, write, etc.

%% 'identify'
% Requests the "Identity String" from an instrument using the *IDN command
%   Obviously this only works if the instrument supports *IDN ...
% Returns 0 if no instrument is present at GPIB (or *IDN? not supported)
if strcmpi(instrument,'identify') || strcmpi(instrument,'identity') || strcmpi(instrument,'*IDN')
    io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        fprintf(io,'*IDN?');
        retval=fscanf(io,'%s');
        if verbose >= 2, fprintf('kpib/identify: %s\n',versionstr); end
        if verbose >= 1, fprintf('kpib/identify: Instrument at GPIB-%s identifies as:\n  %s\n',num2str(GPIB),retval); end
        validInst = 1;
    else
        retval=0;
        if verbose >= 1, fprintf(1,'kpib/identify: No instrument at GPIB-%s\n',num2str(GPIB)); end
        kpib('close',GPIB,0,0,0,0,verbose);
        validInst = 1;
    end
end


%% 'clear'
% This function is used in order to clear all of the instrument handles
% and to close all the connections without having to go and find each
% individual instrument and close it. Essentially a "close all" command.
if strcmpi(instrument,'clear')
    if verbose >= 2, fprintf('kpib: Closing and clearing all instrument connections.\n'); end
    io = instrfind;
    if verbose >= 2, disp(io); end
    if ~(isempty(io))
        fclose(io);
        delete(io);
        clear io;
    end
    if verbose >= 2, fprintf('kpib: All instruments (ports) closed.\n'); end
    validInst = 1;
    if nargout == 1, retval = 1; end
end

%% 'close'
% This function is used in order to close individual instruments with a
%  known GPIB address.
% For many instruments, this returns the instrument to local (front panel)
%  control.
% Can specify GPIB addresses as an array and all addresses will be closed.
% Can specify serial ports ('COM1', 'COM2'), but don't mix serial and GPIB.
if strcmpi(instrument,'close')
    if isnumeric(GPIB)
        for g=GPIB
            if verbose >= 2, fprintf('kpib: Closing GPIB-%d.\n',g); end
            iof = instrfind('Type','gpib','PrimaryAddress',g);
            if ~isempty(iof)
                if strcmp(iof.Status,'open')
                    clrdevice(iof);
                end
                fclose(iof);
                delete(iof);
                clear iof;
            else
                if verbose >= 1, fprintf('kpib: No instrument in memory at GPIB-%d.\n',g); end
            end
        end
        
    elseif isstruct(GPIB) && isfield(GPIB,'gpib')
        if verbose >= 2, fprintf('kpib: Closing GPIB-%d.\n',GPIB.gpib); end
        iof = instrfind('Type','gpib','PrimaryAddress',GPIB.gpib);
        if ~isempty(iof)
            fclose(iof);
            delete(iof);
            clear iof;
        end
        
    elseif strncmpi(GPIB,'COM',3)
        if verbose >= 2, fprintf('kpib: Closing serial port %s.\n',GPIB); end
        iof = instrfind('Type','serial');
        if ~isempty(iof)
            clrdevice(iof);
            fclose(iof);
            delete(iof);
            clear iof;
        else
            if verbose >= 1, fprintf('kpib: No instrument in memory at GPIB-%d.\n',g); end
        end
        
    else
        fprintf('kpib: Error, invalid GPIB address ["%s"].\n',GPIB);
    end
    validInst = 1;
end

%% 'open'
% This function basically calls fopen().
% Sort of a ping.
% Can specify GPIB addresses as an array and all addresses will be opened.
if strcmpi(instrument,'open')
    if isnumeric(GPIB)
        if verbose >= 2, fprintf('kpib: Opening GPIB# %d.\n',GPIB); end
        for g=GPIB
            %io = instrfind('Type','gpib','PrimaryAddress',g);
            io = port(g,instrument,value,verbose);
            %             if isempty(io)
            %                 io = gpib('ni',0,g);
            %                 fopen(io);
            % %                 set(io,'EOSMode','read&write')
            % %                 set(io,'EOSCharCode','LF')
            % %                 EOSmode=get(io,'EOSMode');
            % %                 if verbose >= 3, fprintf('kpib/open: EOSmode: %s\n',EOSmode); end
            %             else
            %                 if verbose >= 1, fprintf('kpib: Instrument at GPIB# %d already open.\n',g); end
            %             end
        end
        if nargout > 0, retval = io; end
    else
        fprintf('kpib: Error, invalid GPIB address ["%s"].\n',GPIB);
    end
    validInst = 1;
end

%% 'write'
% This function is used to write the string COMMAND to a specified address.
if strcmpi(instrument,'write')
    if verbose >= 2, fprintf('kpib: Writing to GPIB# %d.\n',GPIB); end
    io = port(GPIB,instrument);
    fprintf(io,command);
    validInst = 1;
end

%% 'query'
% (previously known as 'writeread')
% This function is used to make queries that return a value. The string
%  COMMAND is written to the GPIB address and whatever is returned is
%  returned. The buffersize can also be set to VALUE. The default buffer
%  size is 1000 bytes. The buffer has to be large enough to contain whatever
%  will be returned.
if any(strcmpi(instrument, {'writeread', 'query'}))
    if verbose >= 2, fprintf('kpib: Writing "%s" to GPIB# %d and reading response.\n',command,GPIB); end
    io = port(GPIB,instrument,value,verbose);
    fprintf(io,command);
    retval = fscanf(io);
    validInst = 1;
end


%% 'scan'
% This function scans the GPIB bus and returns information about the type
%  of GPIB interfaces and connected instruments (uses the INSTRHWINFO function).
% Use VALUE == 'identify' to ask for the identity string from each instrument
%  that is detected.
%
if strcmpi(instrument,'scan')
    if verbose >=2, fprintf(1,'%s\n',versionstr); end
    gpib_interfaces = instrhwinfo('gpib');
    %n = length(gpib_interfaces.InstalledAdaptors);
    for i=1:length(gpib_interfaces.InstalledAdaptors);
        fprintf(1,'kpib/scan: GPIB interface ''%s'':\n',gpib_interfaces.InstalledAdaptors{i});
        fprintf(1,'           Instruments Detected:\n');
        boardinfo=instrhwinfo('gpib',gpib_interfaces.InstalledAdaptors{i});
        for j=1:length(boardinfo.ObjectConstructorName)
            fprintf(1,'             %s ',boardinfo.ObjectConstructorName{j});
            if strcmpi(command,'identify')
                addr=textscan(boardinfo.ObjectConstructorName{j},'%s %s %n);');
                fprintf(1,'%s\n',kpib('identify',addr{3},command,value,channel,aux,0));
            else
                fprintf(1,'\n');
            end
        end
    end
    if verbose >= 3,
        fprintf(1, '%s\n%s\n%s\n%s\n','kpib/scan: Note: if you are having trouble with kpib,',...
            '            make sure that the correct GPIB interface manufacturer',...
            '            from the list show here is entered in the kpib code',...
            '            as the value for the variable "gpib_interface_manufacturer".');
    end
    
    serial_interfaces = instrhwinfo('serial');
    for i=1:length(serial_interfaces.AvailableSerialPorts);
        fprintf(1,'kpib/scan: Serial interface ''%s''\n\n',serial_interfaces.AvailableSerialPorts{i});
    end
    kpib('clear',command,value,channel,aux,verbose);
    
    validInst = 1;
end

% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %
%% Individual Instrument Drivers
% Each supported instrument is handled by the appropriate IF statement
% which matches the 'INSTRUMENT' parameter. Documentation for each driver
% is in the comment field for each section.
%

%% 'None' (no instrument)
% This is a "dummy instrument" so that we can make calls the kpib that have
%  no result
% 'none' | '[none]' | '(none)'
if any(strcmpi(instrument,{'none','[none]','(none)'}))
    if verbose >= 2, fprintf(1, 'kpib: Instrument NONE'); end
    if nargout > 0
        if strcmpi(value,'temp')
            retval = 1776;
            if verbose >= 2, fprintf(1, ', retval = 1776 (temp).\n'); end
        else
            retval = 0;
            if verbose >= 2, fprintf(1, ', retval = 0.\n'); end
        end
    else
        if verbose >= 2, fprintf('.\n'); end
    end
    validInst = 1;
end


%% 'Agilent_N6705A' 4 units DC Power Supply
%********************************************************************************************************************************
%********************************************************************************************************************************
%RETVAL = KPIB('INSTRUMENT', LOGICAL_BOARD_INDEX, GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'read'    Trigger a display value read of type VALUE ('curr'|'volt'|'Vrange'|'Irange'|'outputState')
%
% 'set'     Set the values of type VALUE ('curr'|'volt'|'Irange'|'Vrange')
%           specifying the allowed range for 'curr', through the use of
%           type CHANNEL
%
% Valid ranges for setting the current:
%   '[-2 , 2]A if we set 1/4 of the scale','[-8 , 8]A if we set full scale'.
% Valid ranges for setting the voltage:
%   '[-12.5 , 12.5]V if we set 1/4 of the scale','[-50 , 50]V if we set full scale'.
%
% If no Irange or Vrange is specified, then both them are set to full scale
% [-50 , 50]V and [-8 , 8]A
%


if (strcmpi(instrument, 'Agilent_N6705A') || strcmpi(instrument, 'all'))
    %It is necessary so to specify to the port function what is the
    %gpib_interface_BOARDINDEX, in order to correctly open the IO port
    io = port(GPIB, instrument, 0, verbose,gpib_interface_BOARDINDEX);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        %fprintf(io, '*RST');
        
        switch command
            case 'instrument_id'
                fprintf(io,'*IDN?'); % Typical Response:  AGILENT TECHNOLOGIES,N6700B,MY00123456,B.00.00
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib/N6705A: Identification:',retval); end
                
            case 'reset'
                fprintf(io,'*RST'); % User guide pag 194.  Reset init state explained in that page.
                
            case 'output_all_on'
                fprintf(io,'OUTP ON'); % User guide pag 186.  Reset init state explained in that page.
                %<Bool> Boolean OFF | 0 | ON | 1
            case 'output_all_off'
                fprintf(io,'OUTP OFF'); % User guide pag 186.  Reset init state explained in that page.
                %<Bool> Boolean OFF | 0 | ON | 1
                
            case 'ready?'
                fprintf(io,'*OPC?'); % *OPC? - places a 1 in the Output Queue when all pending operations have completed.
                %Because it requires your program to read the returned value before executing the
                %next program statement, *OPC? can be used to cause the controller to wait for commands
                %to complete before proceeding with its program.
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib/N6705A: Ready?',retval); end
                
            case 'output_on'
                aux_sting=sprintf('%s (@%s)','OUTP ON,',channel);
                fprintf(io, aux_sting);
                
            case 'VoltageOrCurrentMode'  %  The following command sets the preferred mode of channel 1 to CURRent. OUTP:PMOD CURR,(@1)
                switch value
                    case {'current'}
                        aux_sting=sprintf('%s (@%s)','OUTP:PMOD CURR,',channel);   %'OUT:STAT:PMOD CURR,',channel);
                        fprintf(io, aux_sting);
                    case {'voltage'}
                        aux_sting=sprintf('%s (@%s)','OUTP:PMOD VOLT,',channel);   %'OUT:STAT:PMOD VOLT,',channel);
                        fprintf(io, aux_sting);
                end
                
            case 'readDigitalPinData'
                %This command sets the output data on the digital control port when that port is configured
                %for Digital I/O operation. The port has seven signal pins and a digital ground pin.
                %In the binary-weighted value that is written to the port, the pins are controlled according to
                % the following bit assignments:
                %
                %                 Pin  Bit Number  Decimal Value
                %                  1      0            1
                %                  2      1            2
                %                  3      2            4
                %                  4      3           8
                %                  5      4           16
                %                  6      5           32
                %                  7      6           64
                %
                aux_sting=sprintf('%s','DIG:OUTP:DATA?');
                fprintf(io, aux_sting);
                retval=fscanf(io,'%s');
                
            case {'set','setdata'}
                
                switch value
                    case {'VoltSetting'}
                        aux_sting=sprintf('%s %s, (@%s)','VOLT',num2str(aux),channel);
                        fprintf(io, aux_sting);
                        
                    case {'VoltModeList'}
                        aux_sting=sprintf('%s ,(@%s)','VOLT:MODE LIST',channel);
                        fprintf(io, aux_sting);
                        
                    case {'VoltAll'}
                        aux_sting = sprintf('%s %s, (@%s)','VOLT',num2str(aux),'1:4');
                        fprnitf(io, aux_sting);
                        
                    case {'CurrModeList'}
                        aux_sting=sprintf('%s ,(@%s)','CURR:MODE LIST',channel);
                        fprintf(io, aux_sting);
                        
                    case {'CurrModeFix'}
                        aux_sting=sprintf('%s ,(@%s)','CURR:MODE FIX',channel);
                        fprintf(io, aux_sting);
                        
                    case{'CurrentAll'}
                        aux_sting = sprintf('%s %s, (@%s)','CURR',num2str(aux),'1:4');
                        
                    case {'ListVolt'}
                        aux_sting=sprintf('%s %s , (@%s)','LIST:VOLT',value,channel);
                        fprintf(io, aux_sting);
                        
                    case {'ListCurr'}
                        aux_sting=sprintf('%s %s ,(@%s)','LIST:CURR',value,channel);
                        fprintf(io, aux_sting);
                        
                    case {'ListDwel'}
                        aux_sting=sprintf('%s %s ,(@%s)','LIST:DWEL ',value,channel);
                        fprintf(io, aux_sting);
                        
                    case {'OverVoltSetting'}
                        aux_string=sprintf('%s %s, (@%s)','VOLT:PROT:LEV',num2str(aux),channel);
                        fprintf(io,aux_string);
                        
                    case {'CurrentSetting'}
                        aux_string=sprintf('%s %s, (@%s)','CURR',num2str(aux),channel);
                        fprintf(io,aux_string);
                        
                    case {'CurrentProtectionStatusON'}
                        aux_string=sprintf('%s (@%s)','CURR:PROT:STAT ON,',channel);
                        fprintf(io,aux_string);
                        
                    case {'OutputOn'}
                        aux_string=sprintf('%s (@%s)','OUTP ON,',channel);
                        fprintf(io,aux_string);
                        
                    case {'OutputOff'}
                        aux_string=sprintf('%s (@%s)','OUTP OFF,',channel);
                        fprintf(io,aux_string);
                        
                    case('Curr')
                        aux_string=sprintf('%s %s, (@%s)','CURR',num2str(aux),channel);
                        fprintf(io,aux_string);
                        
                    case('DigitOut')
                        %This command sets the output data on the digital control port when that port is configured
                        % for Digital I/O operation. The port has seven signal pins and a digital ground pin.
                        aux_string=sprintf('%s %s','DIG:OUTP:DATA',num2str(aux));
                        fprintf(io,aux_string);
                        
                    case('DigMode')
                        %The pin is a general-purpose ground-referenced digital input/output.
                        %The output can be set with [SOURce:]DIGital:OUTPut:DATA.
                        aux_string=sprintf('%s%s:FUNC DIO','DIG:PIN',channel);
                        fprintf(io,aux_string);
                        
                end %End of value Switch for case 'setdata' or 'set'
                
            case {'read','getdata'}
                
                switch value
                    case {'Volt'}
                        aux_string=sprintf('%s (@%s)','MEAS:VOLT? ' ,channel);
                        fprintf(io,aux_string);
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib/N6705A: Identification:',retval); end
                end %End of value Switch for case 'read'
                
            case 'error'
                aux_string=sprintf('Syst:err?');
                fprintf(io,aux_string);
                retval = fscanf(io,'%f');
                
            otherwise
                if verbose >= 1, fprintf('kpib/Agilent N6705A: Error, command not supported by the instrument.\n'); end
                
        end %End of the Command Switch
        
    else % catch incorrect address errors
        if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
        retval=0;
    end
    
    validInst = 1;
end % end Agilent N6705A

%********************************************************************************************************************************
%********************************************************************************************************************************



%% 'KEPCO_50-8' DC V/I Source
%********************************************************************************************************************************
%********************************************************************************************************************************
%RETVAL = KPIB('INSTRUMENT', LOGICAL_BOARD_INDEX, GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'read'    Trigger a display value read of type VALUE ('curr'|'volt'|'Vrange'|'Irange'|'outputState')
%
% 'set'     Set the values of type VALUE ('curr'|'volt'|'Irange'|'Vrange')
%           specifying the allowed range for 'curr', through the use of
%           type CHANNEL
%
% Valid ranges for setting the current:
%   '[-2 , 2]A if we set 1/4 of the scale','[-8 , 8]A if we set full scale'.
% Valid ranges for setting the voltage:
%   '[-12.5 , 12.5]V if we set 1/4 of the scale','[-50 , 50]V if we set full scale'.
%
% If no Irange or Vrange is specified, then both them are set to full scale
% [-50 , 50]V and [-8 , 8]A
%
% KEPCO_50-8 command strings (Kepco bit 4886 operation manual; and Quick start guide it 4886, Tables 3 and 4)

if (strcmpi(instrument, 'KEPCO_50-8') || strcmpi(instrument, 'all'))
    %It is necessary so to specify to the port function what is the
    %gpib_interface_BOARDINDEX, in order to correctly open the IO port
    io = port(GPIB, instrument, 0, verbose,gpib_interface_BOARDINDEX);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        %fprintf(io, '*RST');
        
        switch command
            %case 'init'
            %fprintf(io,'INIT'); % Page 4-3, Table 4-2. (Default Values, Status on power up)
            
            case {'read','getdata'}
                % if VALUE is not specified
                % (curr,vlimit), default show both them
                
                switch value
                    case {'curr','current','I'}
                        % if a valid parameter for reading the current source value has been passed,
                        % it is printed on the screen.
                        % For example: kpib(KEPCO_50-8, 8, 6, 'read', 'curr', 0, 0, 2)
                        fprintf(io, 'MEAS:CURR?');
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/KEPCO_50-8: Output Current :',retval,'A'); end
                        
                    case {'volt','voltage','V'}
                        % if a valid parameter for reading the current source value has been passed,
                        % it is printed on the screen.
                        % For example: kpib(KEPCO_50-8, 8, 6, 'read', 'volt', 0, 0, 2)
                        fprintf(io, 'MEAS:VOLT?');
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/KEPCO_50-8: Output Voltage :',retval,'V'); end
                        
                    case {'rangevolt','rangevoltage','Vrange'}
                        % if a valid parameter for reading the Vrange value has been passed,
                        % it is printed on the screen.
                        % For example: kpib(KEPCO_50-8, 8, 6, 'read', 'Vrange', 0, 0, 2)
                        fprintf(io, 'VOLT:RANG?');
                        retval = fscanf(io,'%f');
                        if retval==1
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Voltage Range : +-50V'); end
                        else
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Voltage Range : +-12.5V'); end
                        end
                        
                    case {'rangecurr','rangecurrent','Irange'}
                        % if a valid parameter for reading the Irange value has been passed,
                        % it is printed on the screen.
                        % For example: kpib(KEPCO_50-8, 8, 6, 'read', 'Irange', 0, 0, 2)
                        fprintf(io, 'CURR:RANG?');
                        retval = fscanf(io,'%f');
                        if retval==1
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Current Range : +-8A'); end
                        else
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Current Range : +-2A'); end
                        end
                        
                    case {'output','outp','outputState'}
                        % if a valid parameter for reading the output state value has been passed,
                        % it is printed on the screen.
                        % For example: kpib(KEPCO_50-8, 8, 6, 'read', 'output', 0, 0, 2)
                        fprintf(io, 'OUTP?');
                        retval = fscanf(io,'%f');
                        if retval==1
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Source�s Output is ON'); end
                        else
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Source�s Output is OFF'); end
                        end
                        
                    otherwise
                        % if no value parameter has been passed, just
                        % show all of them
                        % For example: kpib(KEPCO_50-8, 8, 12, 'read', 0, 0, 0, 2)
                        fprintf(io, 'OUTP?');
                        retval = fscanf(io,'%f');
                        if retval==1
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Source�s Output is ON'); end
                        else
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Source�s Output is OFF'); end
                        end
                        fprintf(io, 'CURR:RANG?');
                        retval = fscanf(io,'%f');
                        if retval==1
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Current Range : +-8A'); end
                        else
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Current Range : +-2A'); end
                        end
                        fprintf(io, 'CURR?');
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/KEPCO_50-8: Output Current :',retval,'A'); end
                        fprintf(io, 'VOLT:RANG?');
                        retval = fscanf(io,'%f');
                        if retval==1
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Voltage Range : +-50V'); end
                        else
                            if verbose >=2, fprintf(1,'%s\n','kpib/KEPCO_50-8: Voltage Range : +-12.5V'); end
                        end
                        fprintf(io, 'VOLT?');
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/KEPCO_50-8: Output Voltage :',retval,'V'); end
                        
                end %End of value switch for command case 'read' or 'getdata'
                
            case {'set','setdata'}
                % if VALUE is not specified
                % (curr,vlimit,dwelltime,Memlocation), show exception
                
                switch value
                    case {'rangecurr','rangecurrent','Irange'}
                        % if a valid range has been specified, use it.
                        % AUX is the scale range.
                        % Accuracy specifications --> Kepco bit 4886
                        % operation manual Page 1-2, Tables 1-2 and 1-3.
                        %  1 is full scale up to +-8A, high range accuracy --> 4mA
                        %  4 is 1/4 scale up to +-2A, low range accuracy --> 0.25mA
                        switch aux
                            case {'1'}
                                fprintf(io, 'CURR:RANG 1');
                            case {'4'}
                                fprintf(io, 'CURR:RANG 4');
                                
                        end %End of aux Switch for value case 'rangecurr' or 'Irange'
                        
                    case {'rangevolt','rangevoltage','Vrange'}
                        % if a valid range has been specified, use it.
                        % AUX is the scale range.
                        % 1 is full scale up to +-50V, high range
                        % accuracy --> 6mV
                        % 4 is 1/4 scale up to +-12.5V, low range
                        % accuracy --> 1.5mV
                        switch aux
                            case {'1'}
                                fprintf(io, 'VOLT:RANG 1');
                            case {'4'}
                                fprintf(io, 'VOLT:RANG 4');
                                
                        end %End of aux Switch for value case 'rangecurr' or 'Irange'
                        
                    case {'curr','current','I'}
                        % if a valid range has been specified, use it.
                        fprintf(io, 'CURR:RANG?');
                        retval = fscanf(io,'%f');
                        if retval==4 && aux>=-2 && aux<=2
                            fprintf(io, 'CURR %f',aux);
                            fprintf(1,'%s %f %s\n','kpib/KEPCO_50-8: Programmed output Current =',aux,'A');
                        elseif retval==1 && aux>=-8 && aux<=8
                            fprintf(io, 'CURR %f',aux);
                            fprintf(1,'%s %f %s\n','kpib/KEPCO_50-8: Programmed output Current =',aux,'A');
                        else
                            fprintf(1,'%s\n','kpib/KEPCO_50-8: Programmed output Current : limit exceeded!!');
                            fprintf(1,'%s\n','kpib/KEPCO_50-8: Recalculate Programmed output Current value according to Irange!!');
                        end
                        
                    case {'volt','voltage','V'}
                        % if a valid range has been specified, use it.
                        fprintf(io, 'VOLT:RANG?');
                        retval = fscanf(io,'%f');
                        if retval==4 && aux>=-12.5 && aux<=12.5
                            fprintf(io, 'VOLT %f',aux);
                            fprintf(1,'%s %f %s\n','kpib/KEPCO_50-8: Programmed output Voltage =',aux,'V');
                        elseif retval==1 && aux>=-50 && aux<=50
                            fprintf(io, 'VOLT %f',aux);
                            fprintf(1,'%s %f %s\n','kpib/KEPCO_50-8: Programmed output Voltage =',aux,'V');
                        else
                            fprintf(1,'%s\n','kpib/KEPCO_50-8: Programmed output Voltage : limit exceeded!!');
                            fprintf(1,'%s\n','kpib/KEPCO_50-8: Recalculate Programmed output Voltage value according to Vrange!!');
                        end
                        
                end %End of value Switch for case 'setdata' or 'set'
                
            case {'beep','alert','sound'}
                % Kepco source emits a brief audible sound
                fprintf(io, 'SYST:BEEP');
                
            case {'on','start','operate'}
                % if the 'start' or 'on' command is passed as argument we
                % need to enable the output
                fprintf(io, 'OUTPUT ON');
                fprintf(1,'%s\n','kpib/KEPCO_50-8: Output Enabled');
                
            case {'off','stop','nooperate'}
                % if the 'stop' or 'off' command is passed as argument we
                % need to disable the output
                fprintf(io, 'OUTPUT OFF');
                fprintf(1,'%s\n','kpib/KEPCO_50-8: Output Disabled');
                
            case {'modeV','Vsource'}
                % if the 'start' or 'on' command is passed as argument we
                % need to enable the output
                fprintf(io, 'FUNC:MODE VOLT');
                fprintf(1,'%s\n','kpib/KEPCO_50-8: Working as Voltage Source, limited by current');
                
            case {'modeI','Isource'}
                % if the 'start' or 'on' command is passed as argument we
                % need to enable the output
                fprintf(io, 'FUNC:MODE CURR');
                fprintf(1,'%s\n','kpib/KEPCO_50-8: Working as Current Source, limited by voltage');
                
            otherwise
                if verbose >= 1, fprintf('kpib/KEPCO_50-8: Error, command not supported by the instrument.\n'); end
                
        end %End of the Command Switch
        
    else % catch incorrect address errors
        if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
        retval=0;
    end
    
    validInst = 1;
end % end KEPCO_50-8

%********************************************************************************************************************************
%********************************************************************************************************************************

%% 'HP_3478A' HP multimeter
%RETVAL = KPIB('INSTRUMENT', LOGICAL_BOARD_INDEX, GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'init'    Initialize the multimeter.
% 'read'    Trigger a measurement of type VALUE ('volt'|'ohms'|'curr'|'temp') with
%            range CHANNEL and integration times AUX ('low','medium',high') and return the result
%           'read' defaults to voltage measurement for compatibility with code
%            written to kpib < v2.4.
% 'getdata' Same as 'read'.
%
% Valid ranges for measurement in Volts:
%   .030,.300,3,30,300
% Valid ranges for measurement in Ohms:
%   30,300,3000,30000,300000,3000000,30000000
% Valid ranges for measurement in Amps:
%   .3, 3
% If no CHANNEL is supplied for the range then the multimeter is set to
% auto.
%
%

% 3478A command strings (manual p59)
% Mxx  SRQ mask
% Zx   Autozero on or off (0 | 1)
% Nx   Display setting: (3 - 5) digits of resolution: Faster for small amount of display numbers
% Fx   Instrument function (1 - 7);
%      1 = DC volts, 3 = 2-wire ohms, 5 = DC current   6 = AC current  7 = Extended Ohms Function (Resistance measurement for R>30 MOhms Pag. 26)
% Rx   Range(-2 - 7, A). A = autorange
% Tx   Trigger. 1 = internal trigger

if (strcmpi(instrument, 'HP_3478A') || strcmpi(instrument, 'all'))
    %It is necessary so to specify to the port function what is the
    %gpib_interface_BOARDINDEX, in order to correctly open the IO port
    io = port(GPIB, instrument, 0, verbose,gpib_interface_BOARDINDEX);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        %fprintf(io, '*RST');
        
        switch command
            case 'init'
                fprintf(io,'H0'); % DC Volts, Auto Range SingleTrigger, 4 1/2 Display digit, AutoZero ON, External Trigger Disabled
                
            case {'read','getdata'}
                % if VALUE is not specified (volts,ohms,curr,temp), default to volts
                switch value
                    case {'ohm2W','ohms2W','R2W'}
                        % if a valid range has been specified, use it. CHANNEL is
                        %     the measurement range in ohms
                        switch channel
                            case 30
                                fprintf(io, 'M01Z1N5F3R1T1');
                            case 300
                                fprintf(io, 'M01Z1N5F3R2T1');
                            case 3000
                                fprintf(io, 'M01Z1N5F3R3T1');
                            case 30000
                                fprintf(io, 'M01Z1N5F3R4T1');
                            case 300000
                                fprintf(io, 'M01Z1N5F3R5T1');
                            case 3000000
                                fprintf(io, 'M01Z1N5F3R6T1');
                            case 30000000
                                fprintf(io, 'M01Z1N5F3R7T1');
                            otherwise
                                if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                fprintf(io, 'M01Z1N5F3RAT1');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/HP_3478A: Resistance 2 wires measurement:',retval,'ohms'); end
                        
                        
                    case {'ohm4W','ohms4W','R4W'}
                        % if a valid range has been specified, use it. CHANNEL is
                        %     the measurement range in ohms
                        switch channel
                            case 30
                                fprintf(io, 'M01Z1N5F4R1T1');
                            case 300
                                fprintf(io, 'M01Z1N5F4R2T1');
                            case 3000
                                fprintf(io, 'M01Z1N5F4R3T1');
                            case 30000
                                fprintf(io, 'M01Z1N5F4R4T1');
                            case 300000
                                fprintf(io, 'M01Z1N5F4R5T1');
                            case 3000000
                                fprintf(io, 'M01Z1N5F4R6T1');
                            case 30000000
                                fprintf(io, 'M01Z1N5F4R7T1');
                            otherwise
                                if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                fprintf(io, 'M01Z1N5F4RAT1');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/HP_3478A: Resistance 4 wires measurement:',retval,'ohms'); end
                        
                    case {'voltDC','voltageDC','VDC'}
                        % if a valid range has been specified, use it. CHANNEL is
                        %     the measurement range in amps
                        switch channel
                            case .030
                                fprintf(io, 'M01Z1N5F1R-2T1');
                            case .300
                                fprintf(io, 'M01Z1N5F1R-1T1');
                            case 3
                                fprintf(io, 'M01Z1N5F1R0T1');
                            case 30
                                fprintf(io, 'M01Z1N5F1R1T1');
                            case 300
                                fprintf(io, 'M01Z1N5F1R2T1');
                            otherwise
                                if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                fprintf(io, 'M01Z1N5F1RAT1');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Voltage DC measurement:',retval,'Volts'); end
                        
                    case {'voltAC','voltageAC','VAC'}
                        % if a valid range has been specified, use it. CHANNEL is
                        %     the measurement range in amps
                        switch channel
                            case .030
                                fprintf(io, 'M01Z1N5F2R-2T1');
                            case .300
                                fprintf(io, 'M01Z1N5F2R-1T1');
                            case 3
                                fprintf(io, 'M01Z1N5F2R0T1');
                            case 30
                                fprintf(io, 'M01Z1N5F2R1T1');
                            case 300
                                fprintf(io, 'M01Z1N5F2R2T1');
                            otherwise
                                if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                fprintf(io, 'M01Z1N5F2RAT1');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Voltage AC measurement:',retval,'Volt'); end
                        
                        %                         case {'volt','volts','V','temp','temperature','T'}
                        %                             % "temperature" is a special case of reading
                        %                             %  voltage from a LM35 sensor. Temperature in C
                        %                             %  equals voltage*100
                        %
                        %                             % if a valid range has been specified, use it.
                        %                             %   CHANNEL is the measurement range in volts.
                        %                              switch channel
                        %                                 case .030
                        %                                     fprintf(io, 'M01Z1N5F1R-2T1');
                        %                                 case .300
                        %                                     fprintf(io, 'M01Z1N5F1R-1T1');
                        %                                 case 3
                        %                                     fprintf(io, 'M01Z1N5F1R0T1');
                        %                                 case 30
                        %                                     fprintf(io, 'M01Z1N5F1R1T1');
                        %                                 case 300
                        %                                     fprintf(io, 'M01Z1N5F1R2T1');
                        %                                 otherwise
                        %                                     switch value
                        %                                         case {'volt','volts','V'}
                        %                                             if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                        %                                             fprintf(io, 'M01Z1N5F1RAT1');
                        %                                         case {'temp','temperature','T'}
                        %                                             if verbose >= 2, fprintf('kpib/HP_3478A: Range 3 volts (default for T measurement)\n'); end
                        %                                             fprintf(io, 'M01Z1N5F1R0T1');
                        %                                     end
                        %
                        %                             end
                        %                             % read the value returned
                        %                             retval = fscanf(io,'%f');
                        %                             switch value
                        %                                 case {'volt','volts','V'}
                        %                                     if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Voltage measurement:',retval,'volts'); end
                        %                                 case {'temp','temperature','T'}
                        %                                     retval = retval *100; % return value in deg C
                        %                                     if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Temperature measurement:',retval,'deg C'); end
                        %                             end
                        %
                        %
                        %                         % 'temp' currently refers to the LM35 circuit where
                        %                         %    T (deg C) = volts*100
                        %                         % but this could be changed in future to be a
                        %                         %  4-wire resistance measurement of an RTD
                        %                         case {'temp','temperature','T'}
                        %                             % if a valid range has been specified, use it. Otherwise default to 3 volts.
                        %                             %  CHANNEL is the measurement range in volts
                        %                              switch channel
                        %                                 case .030
                        %                                     fprintf(io, 'M01Z1N5F1R-2T1');
                        %                                 case .300
                        %                                     fprintf(io, 'M01Z1N5F1R-1T1');
                        %                                 case 3
                        %                                     fprintf(io, 'M01Z1N5F1R0T1');
                        %                                 case 30
                        %                                     fprintf(io, 'M01Z1N5F1R1T1');
                        %                                 case 300
                        %                                     fprintf(io, 'M01Z1N5F1R2T1');
                        %                                 otherwise
                        %                                     if verbose >= 2, fprintf('kpib/HP_3478A: Range 3 volts (default temp)\n'); end
                        %                                     fprintf(io, 'M01Z1N5F1R0T1');
                        %                             end
                        %                             % read the value returned
                        %                             retval = fscanf(io,'%f'); retval = retval *100; % return value in deg C
                        %                             if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Temperature measurement:',retval,'deg C'); end
                        
                    case {'currDC','currentDC','IDC'}
                        % if a valid range has been specified, use it. CHANNEL is
                        %     the measurement range in amps
                        switch channel
                            %case .030
                            %fprintf(io, 'M01Z1N5F5R-2T1');
                            case .300
                                switch aux
                                    case 'low'
                                        fprintf(io, 'M01Z1N3F5R-1T1');
                                    case 'medium'
                                        fprintf(io, 'M01Z1N4F5R-1T1');
                                    case 'high'
                                        fprintf(io, 'M01Z1N5F5R-1T1');
                                end
                            case 3
                                switch aux
                                    case 'low'
                                        fprintf(io, 'M01Z1N3F5R0T1');
                                    case 'medium'
                                        fprintf(io, 'M01Z1N4F5R0T1');
                                    case 'high'
                                        fprintf(io, 'M01Z1N5F5R0T1');
                                end
                                
                                %Lineas comentadas por carecer de sentido
                                %f�sico
                                %case 30
                                %fprintf(io, 'M01Z1N5F5R1T1');
                                %case 300
                                %fprintf(io, 'M01Z1N5F5R2T1');
                            otherwise
                                if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                fprintf(io, 'M01Z1N5F5RAT1');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Current DC measurement:',retval,'amps'); end
                        
                    case {'currAC','currentAC','IAC'}
                        % if a valid range has been specified, use it. CHANNEL is
                        %     the measurement range in amps
                        switch channel
                            case .030
                                fprintf(io, 'M01Z1N5F6R-2T1');
                            case .300
                                fprintf(io, 'M01Z1N5F6R-1T1');
                            case 3
                                fprintf(io, 'M01Z1N5F6R0T1');
                            case 30
                                fprintf(io, 'M01Z1N5F6R1T1');
                            case 300
                                fprintf(io, 'M01Z1N5F6R2T1');
                            otherwise
                                if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                fprintf(io, 'M01Z1N5F6RAT1');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1,'%s %g %s\n','kpib/HP_3478A: Current AC measurement:',retval,'amps'); end
                        
                    otherwise % default to voltage measurement for compatibility with older code
                        % if a valid range has been specified, use it. CHANNEL is
                        %     the measurement range in volts
                        switch channel
                            case .030
                                fprintf(io, 'M01Z1N5F1R-2T1');
                            case .300
                                fprintf(io, 'M01Z1N5F1R-1T1');
                            case 3
                                fprintf(io, 'M01Z1N5F1R0T1');
                            case 30
                                fprintf(io, 'M01Z1N5F1R1T1');
                            case 300
                                fprintf(io, 'M01Z1N5F1R2T1');
                            otherwise
                                if verbose >= 2, fprintf('kpib/HP_3478A: Range Automatically Set by Multimeter\n'); end
                                fprintf(io, 'M01Z1N5F1RAT1');
                        end
                        % read the value returned
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1,'%s %f %s\n','kpib/HP_3478A: Voltage measurement (default):',retval,'volts'); end
                        
                end % end ohms/volts/curr (VALUE) switch
                
            otherwise
                if verbose >= 1, fprintf('kpib/HP_3478A: Error, command not supported by the instrument.\n'); end
                
        end % end command switch
        
    else % catch incorrect address errors
        if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
        retval=0;
    end
    
    validInst = 1;
end % end HP_3478A

%% 'KTH_220' Keithley 220 Programmable Current Source
%********************************************************************************************************************************
%********************************************************************************************************************************
%RETVAL = KPIB('INSTRUMENT', LOGICAL_BOARD_INDEX, GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'init'    Initialize the current source.
% 'read'    Trigger a display value read of type VALUE ('curr'|'vlimit'|'dwelltime'|'memory')
%
% 'set'     Set the values of type VALUE ('curr'|'vlimit'|'dwelltime')
%           specifying the allowed range for 'curr', through the use of
%           type CHANNEL
%
% Valid ranges for setting the current:
%   '1nA','10nA','100nA','1uA','10uA','100uA','1mA','10mA','100mA'.
%
% If no CHANNEL is supplied for the range then the multimeter is set to
% auto, which is +-101mA
%
%

% KTH_220 command strings (keithley_220_programmers_manual; pag.4-5; Table 4.3)
% Mxx  SRQ mask
% Dx   Display
% Fx   Function
% Gx   Prefix for Data Format
% Rx   Range
% Ix   Current Input        (x format = +-n.nnnnE+-nn) / range:+-101 mA
% Vx   Voltage limit Input  (x format = n.nnE+-nn)     / range:1-105 V
% Wx   Dwell time Input     (x format = n.nnnE+-nn)    / range:0-999.9 s
% X    Execute Command (at the end of the string)

if (strcmpi(instrument, 'KTH_220') || strcmpi(instrument, 'KEITHLEY_220') ||strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose,gpib_interface_BOARDINDEX);
    %io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        %fprintf(io, '*RST');
        
        switch command
            case 'init'
                fprintf(io,'D0F0G0K0P2R0T6M0X'); % Page 4-3, Table 4-2. (Default Values, Status on power up)
                
            case {'read','getdata'}
                % if VALUE is not specified
                % (curr,vlimit,dwelltime,Memlocation), default show all
                
                switch value
                    case {'source','curr','current'}
                        % if a valid parameter for reading the current source value has been passed,
                        % it is firstly shown in the instrument display and secondly printed on the screen
                        % For example: kpib(KTH_220, 8, 12, 'read', 'current', 0, 0, 2)
                        fprintf(io, 'G1X'); %For not showing the memory location prefix of each read value
                        retval = fscanf(io,'%s');
                        retval = str2num(retval);
                        retval = retval(1);
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/KTH_220: Current supplied by the current source :',retval,'A'); end
                        
                    case {'vlimit','Vlimit','voltage'}
                        % if a valid parameter for reading the voltage limit value has been passed,
                        % it is firstly shown in the instrument display and secondly printed on the screen
                        % For example: kpib(KTH_220, 8, 12, 'read', 'vlimit', 0, 0, 2)
                        fprintf(io, 'G1X'); %For not showing the memory location prefix of each read value
                        retval = fscanf(io,'%s');
                        retval = str2num(retval);
                        retval = retval(2);
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/KTH_220: Voltage Limit for the current source :',retval,'V'); end
                        
                    case {'dwelltime','Dwelltime','dwellt'}
                        % if a valid parameter for reading the dwell time value has been passed,
                        % it is firstly shown in the instrument display and secondly printed on the screen
                        % For example: kpib(KTH_220, 8, 12, 'read', 'dwelltime', 0, 0, 2)
                        fprintf(io, 'G1X'); %For not showing the memory location prefix of each read value
                        retval = fscanf(io,'%s');
                        retval = str2num(retval);
                        retval = retval(3);
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/KTH_220: Dwell Time of the current source :',retval,'s'); end
                        
                    case {'memlocation','Memlocation','memory'}
                        % if a valid parameter for reading the voltage limit value has been passed,
                        % it is firstly shown in the instrument display and secondly printed on the screen
                        % For example: kpib(KTH_220, 8, 12, 'read', 'memory', 0, 0, 2)
                        fprintf(io, 'G1X'); %For not showing the memory location prefix of each read value
                        retval = fscanf(io,'%s');
                        retval = str2num(retval);
                        retval = retval(4);
                        if verbose >=2, fprintf(1,'%s %f %s\n','kpib/KTH_220: Memory location :',retval,'position'); end
                        
                    otherwise
                        % if no value parameter has been passed, just
                        % show all of them
                        % For example: kpib(KTH_220, 8, 12, 'read', 0, 0, 0, 2)
                        fprintf(io, 'G1X'); %For not showing the memory location prefix of each read value
                        retval = fscanf(io,'%s');
                        retval = str2num(retval);
                        if verbose >=2
                            fprintf(1,'%s %f %s\n','kpib/KTH_220: Current supplied by the current source :',retval(1),'A');
                            fprintf(1,'%s %f %s\n','kpib/KTH_220: Voltage Limit for the current source :',retval(2),'V');
                            fprintf(1,'%s %f %s\n','kpib/KTH_220: Dwell Time of the current source :',retval(3),'s');
                            fprintf(1,'%s %f %s\n','kpib/KTH_220: Memory location :',retval(4),'position');
                        end
                        
                end %End of value switch for command case 'read' or 'getdata'
                
            case {'set','setdata'}
                % if VALUE is not specified
                % (curr,vlimit,dwelltime,Memlocation), show exception
                
                switch value
                    case {'source','curr','current'}
                        % if a valid range has been specified, use it. CHANNEL is
                        %     the measurement range in amps
                        switch channel
                            case {'1nA'}
                                fprintf(io, 'R1I%fX',aux);
                            case {'10nA'}
                                fprintf(io, 'R2I%fX',aux);
                            case {'100nA'}
                                fprintf(io, 'R3I%fX',aux);
                            case {'1uA'}
                                fprintf(io, 'R4I%fX',aux);
                            case {'10uA'}
                                fprintf(io, 'R5I%fX',aux);
                            case {'100uA'}
                                fprintf(io, 'R6I%fX',aux);
                            case {'1mA'}
                                fprintf(io, 'R7I%fX',aux);
                            case {'10mA'}
                                fprintf(io, 'R8I%fX',aux);
                            case {'100mA'}
                                fprintf(io, 'R9I%fX',aux);
                            otherwise
                                if verbose >= 2, fprintf('kpib/KTH_220: Range Automatically Set to +-101mA\n'); end
                                % For example: kpib(KTH_220, 8, 12, 'set', 'current', 0, aux, 2)
                                % with aux a numeric value in between +-101mA
                                fprintf(io, 'R0I%fX',aux);
                        end %End of channel Switch for value case 'source' or 'current'
                        
                    case {'vlimit','Vlimit','voltage'}
                        if aux>=1 || aux<=105
                            fprintf(io, 'V%fX',aux);
                        else
                            fprintf('kpib/KTH_220: Voltage limit exceeded!! Range = [1-105]V\n');
                        end
                        
                    case {'dwelltime','Dwelltime','dwellt'}
                        if aux>=0 || aux<=999.9
                            fprintf(io, 'W%fX',aux);
                        else
                            fprintf('kpib/KTH_220: Dwell time limit exceeded!!  Range = [0-999.9]s\n');
                        end
                        
                end %End of value Switch for case 'setdata' or 'set'
                
            case {'start','operate'}
                % if the 'start' or 'operate' command is passed as argument we need to put
                % the KTH_220 on working
                fprintf(io, 'F1X');
                fprintf('kpib/KTH_220: Current Source Operating\n');
                
            case {'stop','nooperate'}
                % if the 'stop' or 'nooperate' command is passed as
                % argument we need to stop the KTH_220 from working
                fprintf(io, 'F0X');
                fprintf('kpib/KTH_220: Current Source Stopped\n');
                
            case {'overlimit', 'vlimitexceed'}
                % if the 'overlimit' or 'vlimitexceed' command is passed as
                % argument we need to know if the KTH_220 is over voltage limit
                fprintf(io, 'G2X');
                retval = fscanf(io,'%s');
                retval = strfind(retval, 'ODCI');
                retval = size(retval);
                if retval(2)>0
                    retval = 1; % Exceed
                    if verbose >=2, fprintf('kpib/KTH_220: Over voltage limit.\n'); end
                else
                    retval = 0; % Not exceed
                end
                
                
            otherwise
                if verbose >= 1, fprintf('kpib/KTH_220: Error, command not supported by the instrument.\n'); end
                
        end %End of the Command Switch
        
    else % catch incorrect address errors
        if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
        retval=0;
    end
    
    validInst = 1;
end % end KTH_220




%% HP Power Supplies ('HP_POWER')
%
%Added by Juan Manuel L�pez Torralba
%
% HP_power is the list of HP Power supplies which have a common syntax
% use INSTRUMENT = 'HP_POWER' for generic code
HP_power={'HP_POWER','HP_POWERM','HP_6614C','HP_E3631A','HP_E3632A','HP_E3633A','HP_E3634A','HP_E3641A','HP_E3647A'};
% which of these have multiple outputs?
% NOTE: some multiple output supplies use numbered output (1,2) and some
%  use named outputs ("P6V"). Code assumes numbered; adjust in HP_power_M
%  section as necessary for new instruments.
HP_power_M={'HP_POWERM','HP_E3631A','HP_E3647A'};
%
%
% The GPIB commands are the same for all recent generations of HP power
%  supplies; the only difference is whether or not they have multiple outputs.
%  Note that kpib is doing no limit checking, and different models have
%  different output limits.
% If your model is not listed here, that means it hasn't been tested, but
%  it probably works if it is reasonably recent (< 10 yrs old). Use
%  INSTRUMENT == 'HP_POWER' to control a generic HP power supply.

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)
% Valid Commands:
% 'init'  Send the *RST command to reset the instrument and clear registers
% 'read'  Reads the output levels of the specified Output CHANNEL.
%           Returns a single value if you specify VALUE ('volt' or 'curr'),
%           otherwise result is returned as a two-field structure of %f numbers:
%          retval.volt
%          retval.curr
% 'setV'   Sets the output voltage to VALUE in Volts. Also 'set' (deprecated).
% 'setI'   Sets the output current to VALUE in Amps.
%
% 'off'   Turns off both outputs.
% 'on'    Turns on both outputs.
%

if (any(strcmpi(instrument, HP_power)) || strcmpi(instrument, 'all'))
    io = port(GPIB, instrument, 0, verbose,gpib_interface_BOARDINDEX);
    %io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        
        % do we need to select an output channel?
        if any(strcmpi(instrument, HP_power_M))
            % select the Output channel if specified, default to 1
            if ~(any(channel == [1 2 3]))
                channel=1;
            end
            if strcmpi(instrument,'HP_E3631A') % use name of channel instead of number
                switch channel
                    case 1
                        fprintf(io, 'INST:SEL P6V');
                    case 2
                        fprintf(io, 'INST:SEL P25V');
                    case 3
                        fprintf(io, 'INST:SEL N25V');
                end
            else
                fprintf(io, 'INST:SEL OUT%d', channel); % Selects the output
            end
            if verbose >= 2, fprintf(1, 'kpib/%s(%d): Output %d ',instrument,GPIB,channel); end
        end
        
        switch command
            case 'init'
                fprintf(io,'*RST');
                if verbose >=2,
                 fprintf('kpib/HP_POWER: RESET');
                end
                retval=0;
                
            case 'instrument_id'
                fprintf(io,'*IDN?'); % Typical Response:
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib/HP_POWER: Identification:',retval); end
                
                
            case 'read'
                switch value % return a single value or both V & I?
                    case {'volt','volts','V','v'}
                        % read the voltage
                        fprintf(io, 'MEAS:VOLT?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'reads %f Volts\n',retval); end
                    case {'curr','I','A','current'}
                        % read the current
                        fprintf(io, 'MEAS:CURR?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'reads %f Amps\n',retval); end
                    otherwise
                        % read the output
                        fprintf(io, 'MEAS:VOLT?');
                        retval.volt = fscanf(io,'%f');
                        fprintf(io, 'MEAS:CURR?');
                        retval.curr = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'reads %f Volts & %f Amps\n',retval.volt,retval.curr); end
                end
                
            case {'setV','volt','voltage','set'}
                % set the voltage
                fprintf(io, 'VOLT %f',value); % Sets voltage.
                if verbose >= 2, fprintf('Output Voltage set to %g Volts\n',value); end
                
            case {'setI','curr','current'}
                % set the current
                fprintf(io, 'CURR %f',value); % Sets current.
                if verbose >= 2, fprintf('Output Current set to %g Amps\n',value); end
                
            case 'off'
                fprintf(io, 'OUTP OFF'); % Disables all outputs.
                if verbose >= 2, fprintf(1, 'Outputs off.\n'); end
            case 'on'
                fprintf(io, 'OUTP ON'); % Enables all outputs.
                if verbose >= 2, fprintf(1, ' Outputs on.\n'); end
                
            otherwise
                if verbose >= 1, fprintf('Error, command not supported. ["%s"]\n',command); end
        end
        
    else % catch incorrect address errors
        if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
        retval=0;
    end
    
    validInst = 1;
end % end HP_POWER




%% KEYSIGHT 6063B ELECTRONIC LOAD
% Added by Juan Manuel Lopez Torralba

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)

% Valid Commands:
% 'init'  Send the *RST command to reset the instrument and clear registers
% 'instrument_id'  Send the *IDN? query command to identify the electronic load
% 'read'  Reads the output levels of the specified Output CHANNEL.
%           Returns a single value if you specify VALUE ('volt' or 'curr'),
%           otherwise result is returned as a two-field structure of %f numbers:
%          retval.volt
%          retval.curr
% 'setV'   Sets the output voltage to VALUE in Volts. Also 'set' (deprecated).
% 'setI'   Sets the output current to VALUE in Amps.
% 'mode'   Sets the operation mode
%
% 'off'   Turns off both outputs.
% 'on'    Turns on both outputs.
%

if (any(strcmpi(instrument, 'KEYSIGHT_6063B')) || strcmpi(instrument, 'all'))
    
    io = port(GPIB, instrument, 0, verbose,gpib_interface_BOARDINDEX);
    %io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)
        
        
        
        switch command
            case 'init'
                fprintf(io,'*RST');
                retval=0;
                
            case 'error'
                fprintf(io,'SYST:ERR?');
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: Error:',retval); end
                
            case 'instrument_id'
                fprintf(io,'*IDN?'); % Typical Response:
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: Identification:',retval); end
                
                
            case {'MODE','mode'}
                switch value % select between CV,CC,CR modes
                    case {'CV','cv'}
                        % constant voltage
                        fprintf(io, 'MODE:VOLT:DC\n');
                        if verbose >= 2, fprintf('ELOAD mode sets to %g \n',value); end
                        retval=0;
                        
                    case {'CR','cr'}
                        % constant resistance
                        fprintf(io, 'MODE:RES');
                        if verbose >= 2, fprintf('ELOAD mode sets to %g \n',value); end
                        retval=0;
                        
                    case {'CC','cc'}
                        % constant current
                        fprintf(io, 'MODE:CURR:DC');
                        if verbose >= 2, fprintf('ELOAD mode sets to %g \n',value); end
                        retval=0;
                        
                end
            case 'read'
                switch value % return a single value or both V & I?
                    case {'volt','volts','V','v'}
                        % read the voltage
                        fprintf(io, 'MEAS:VOLT?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'Keysight 6063B output voltage: %f Volts\n',retval); end
                    case {'curr','I','A','current'}
                        % read the current
                        fprintf(io, 'MEAS:CURR?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'Keysight 6063B output current: %f Amps\n',retval); end
                    otherwise
                        % read the output
                        fprintf(io, 'MEAS:VOLT?');
                        retval.volt = fscanf(io,'%f');
                        fprintf(io, 'MEAS:CURR?');
                        retval.curr = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'reads %f Volts & %f Amps\n',retval.volt,retval.curr); end
                end
                
                
            case {'setV','volt','voltage','set'}
                % set the voltage
                fprintf(io, 'VOLT:LEV:IMM %f',value); % Sets voltage.
                if verbose >= 2, fprintf('Output Voltage set to %g Volts\n',value); end
                retval=0;                
                
                %            case {'setI','curr','current'}
                %                % set the current
                %                fprintf(io, 'CURR %f',value); % Sets current.
                %               if verbose >= 2, fprintf('Output Current set to %g Amps\n',value); end
                
            case 'off'
                fprintf(io, 'OUTP OFF'); % Disables all outputs.
                if verbose >= 2, fprintf(1, 'Outputs off.\n'); end
                retval=0;
                
            case 'on'
                fprintf(io, 'OUTP ON'); % Enables all outputs.
                if verbose >= 2, fprintf(1, ' Outputs on.\n'); end
                retval=0;
                
            case 'input_off'
                fprintf(io, 'INP:STAT OFF'); % Disables all outputs.
                if verbose >= 2, fprintf(1, 'Outputs off.\n'); end
                retval=0;
                
            case 'input_on'
                fprintf(io, 'INP:STAT ON'); % Enables all outputs.
                if verbose >= 2, fprintf(1, ' Outputs on.\n'); end
                retval=0;
                
            otherwise
                if verbose >= 1, fprintf('Error, command not supported. ["%s"]\n',command); end
                retval=0;                
        end
        
        
    else % catch incorrect address errors
        if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
        retval=0;
    end
    
    validInst = 1;
end % END KEYSIGHT 6063B ELECTRONIC LOAD



%% SDM3065X Digital Multimeter
% Added by Juan Manuel Lopez Torralba

%RETVAL = KPIB('INSTRUMENT', GPIB, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)

% Valid Commands:
% 'init'  Send the *RST command to reset the instrument and clear registers
% 'instrument_id'  Send the *IDN? query command to identify the electronic load
% 'read'  Reads the output levels of the specified Output CHANNEL.
%           Returns a single value if you specify VALUE ('volt' or 'curr'),
%           otherwise result is returned as a two-field structure of %f numbers:
%          retval.volt
%          retval.curr
% 'setV'   Sets the output voltage to VALUE in Volts. Also 'set' (deprecated).
% 'setI'   Sets the output current to VALUE in Amps.
% 'mode'   Sets the operation mode
%
% 'off'   Turns off both outputs.
% 'on'    Turns on both outputs.
%

if (any(strcmpi(instrument, 'SDM3065X')) || strcmpi(instrument, 'all'))
    
    io = port(GPIB, instrument, 0, verbose,gpib_interface_BOARDINDEX);
    %io = port(GPIB, instrument, 0, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

        switch command
            
            case 'abort'
                fprintf(io,'ABOR');
                retval=0;
                
            case 'fetch'
                fprintf(io,'FETCh?');
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X FETCH:',retval); end
                
            case 'init'
                fprintf(io,'INIT:IMM');
                retval=0;
                
            case 'output_triger_slope'
                % Selects the slope of the voltmeter complete output 
                % signal on the rear-panel VM Comp BNC connector.
                fprintf(io,'OUTPut:TRIGger:SLOPe?');
                retval=0;
                
            case 'erase_read'
                fprintf(io,'R? %f', value);
                retval=0;
                
            case 'error'
                fprintf(io,'SYST:ERR?');
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X Error:',retval); end
                
            case 'instrument_id'
                fprintf(io,'*IDN?'); % Typical Response:
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X Identification:',retval); end
                
         	case 'set_sample_count'
               	fprintf(io,'SAMPle:COUNt? %f', value);
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X number of measurements:',retval); end
            
            case 'get_sample_count'
                fprintf(io,'SAMPle:COUNt?');
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X number of measurements:',retval); end

            case 'get_unit_temperature'
                fprintf(io,'UNIT:TEMPerature?');
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X unit of temperature:',retval); end
                
                
            case 'set_unit_temperature'
                fprintf(io,'UNIT:TEMPerature? %c'+ value);
                retval = fscanf(io,'%s');
                if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X unit of temperature:',retval); end
                
            case 'calculate_clear'
                % Clears all limits, histogram data, statistics and measurements
                fprintf(io,'CALC:CLE:IMM');
                retval=0;
                
            case 'calculate_limit'
                % This subsystem specifies measurements and indicates when a limit has been exceeded
                switch value
                    case 'clear'
                        fprintf(io,'CALC:LIM:CLE'); 
                        retval=0;
                        
                    case 'get_lower' % sets a lower limit
                        fprintf(io,'CALC:LIM:LOW?'); 
                    	retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X lower limit: ',retval); end
                        
                    case 'get_upper' % sets an upper limit
                        fprintf(io,'CALC:LIM:UPP?'); 
                    	retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X upper limit: ',retval); end
                        
                    case 'set_lower' % sets a lower limit
                        fprintf(io,'CALC:LIM:LOW %f', value); 
                        retval=0;
                        
                    case 'set_upper' % sets an upper limit
                        fprintf(io,'CALC:LIM:UPP %f', value); 
                        retval=0;
                        
                    case 'stat_on'
                        fprintf(io,'CALC:LIM:STAT ON'); 
                        retval=0;
                        
                    case 'stat_off'
                        fprintf(io,'CALC:LIM:STAT OFF'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib SDM3065X :',retval); end
                end
                
            case 'CALCulate_TRANsform_HISTogram_Subsystem'
                disp('not implemented yet')
                retval=0;
                
            case 'CALCulate_SCALe_Subsystem'
                disp('not implemented yet')
                retval=0;
                
            case 'calculate_average'
                switch value
                    case 'stat_on'
                        fprintf(io,'CALCulate:AVERage:STATe ON'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X statistic computation enabled: ',retval); end
                 	
                    case 'stat_off'
                        fprintf(io,'CALCulate:AVERage:STATe OFF'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X statistic computation disabled: ',retval); end
                    
                    case 'clear'
                        fprintf(io,'CALC:AVER:CLE:IMM'); 
                        retval=0;
                    
                    case 'average_all' % sets an upper limit
                        fprintf(io,'CALCulate:AVERage:ALL?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X average all: ',retval); end
                        
                    case 'average'
                        fprintf(io,'CALCulate:AVERage:AVERage?'); 
                    	retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X mean: ',retval); end
                    
                    case 'count'
                        fprintf(io,'CALCulate:AVERage:COUNt?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X count: ',retval); end
                    
                    case 'max'
                        fprintf(io,'CALCulate:AVERage:MAXimum?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X maximum: ',retval); end
                   	
                    case 'min'
                        fprintf(io,'CALCulate:AVERage:MINimum?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X minimum: ',retval); end
                 	
                    case {'peak','ptpeak'}
                        fprintf(io,'CALCulate:AVERage:PTPeak?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X peaks: ',retval); end
                    
                    case {'sdeviation','deviation','sdev'}
                        fprintf(io,'CALCulate:AVERage:SDEViation?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X standard deviation: ',retval); end
                end
                
                
                
                
            case 'Configure'
                switch value
                    case 'configure'
                        fprintf(io,'CONF?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X present function, range, and resolution: ',retval); end
                 	
                    case 'continuity'
                        % Configure the instrument for continuity measurements
                        fprintf(io,'CONFigure:CONTinuity'); 
                        retval=0;
                    
                    case 'current_dc'
                        fprintf(io,'CONFigure:CURRent:DC'); 
                        retval=0;
                        
                  	case 'current_ac'
                        fprintf(io,'CONFigure:CURRent:AC'); 
                        retval=0;
                    
                    case 'diode'
                        fprintf(io,'CONFigure:DIODe'); 
                        retval=0;
                        
                    case 'freq'
                        fprintf(io,'CONF:FREQ}'); 
                        retval=0;
                        
                  	case 'period'
                        fprintf(io,'CONF:PER}'); 
                        retval=0;
                    
                    case 'resistance'
                        fprintf(io,'CONF:RES'); 
                        retval=0;
                        
                  	case 'fresistance'
                        fprintf(io,'CONF:FRES'); 
                        retval=0;
                    
                    case 'temperature'
                        fprintf(io,'CONFigure:TEMPerature'); 
                        retval=0;
                   	
                    case 'dc_volt'
                        fprintf(io,'CONFigure:VOLT:DC'); 
                        retval=0;
                 	
                    case {'ac_volt'}
                        fprintf(io,'CONF:VOLT:AC'); 
                        retval=0;
                    
                    case {'capacitance'}
                        fprintf(io,'CONF:CAP'); 
                        retval=0;
                end
            case 'data'
                switch value
                    case 'last'
                        fprintf(io,'DATA:LAST?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X last measurement taken: ',retval); end
                    case 'points'
                        %Returns the total number of measurements currently in reading memory.
                        fprintf(io,'DATA: POINts?'); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X number of measurements in reading memory: ',retval); end   
                    case 'remove'
                       	fprintf(io,'DATA:REMove? %f', value2); 
                        retval = fscanf(io,'%s');
                        if verbose >=2, fprintf(1,'%s %s\n','kpib: SDM3065X Read and erase the oldest readings from reading memory: ',retval); end
                end
            case 'read'
                switch value
                    case 'read'
                        fprintf(io, 'READ?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X measurement: %f \n',retval); end
                        
                    case {'Cont','cont','Continuity','continuity'}
                        % Sets all measurement parameters and trigger parameters to their default values for
                        % continuity test and immediately triggers a measurement. The results are sent directly to
                        % the instrument's output buffer.
                        fprintf(io, 'MEAS:CONT?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X measured resistance: %f \n',retval); end
                        
                    case {'volt','volts','V','v'}
                        % read the DC voltage
                        fprintf(io, 'MEAS:VOLT?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X output DC voltage: %f Volts\n',retval); end
                        
                    case {'VAC','vac'}
                        % read the AC voltage
                        fprintf(io, 'MEAS:VOLT:AC?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X output AC voltage: %f Volts\n',retval); end
                        
                    case {'curr','I','A','current','Curr'}
                        % Sets all measurement parameters and trigger parameters to their default values for AC or
                        % DC current measurements and immediately triggers a measurement. Also specifies the
                        % stalls through the incoming parameters
                        fprintf(io, 'MEAS:CURR?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X output DC current: %f A\n',retval); end
                        
                    case {'DIODE','diode','D','d','diod'}
                        % Sets all measurement parameters and trigger parameters to their default values for diode
                        % test measurements and immediately triggers a measurement. The results are sent directly
                        % to the instrument's output buffer.
                        fprintf(io, 'MEAS:DIOD?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X output DC voltage: %f V\n',retval); end
                        
                    case {'Frequency','frequency','Freq','freq'}
                        % Sets all measurement parameters and trigger parameters to their default values for
                        % frequency or period measurements and immediately triggers a measurement. The results
                        % are sent directly to the instrument's output buffer
                        fprintf(io, 'MEAS:FREQ?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X default frequency measurements: %f Hz\n',retval); end
                        
                        
                    case {'Resistance','resistance','Res','res'}
                        % Sets all measurement and trigger parameters to their 2-wire (RESistance) measurements,
                        % and immediately triggers a measurement. The results are sent directly to the instrument's
                        % output buffer. Also specifies the stalls through the incoming parameters.
                        fprintf(io, 'MEAS:RES?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X default frequency measurements: %f ohm\n',retval); end
                        
                    case {'FResistance','fresistance','fres'}
                        % Sets all measurement and trigger parameters to their 4-wire (RESistance) measurements,
                        % and immediately triggers a measurement. The results are sent directly to the instrument's
                        % output buffer. Also specifies the stalls through the incoming parameters.
                        fprintf(io, 'MEAS:FRES?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X default frequency measurements: %f ohm\n',retval); end
                        
                    case {'Temp','temp','temperature','t'}
                        % read the temperature
                        fprintf(io, 'MEAS:TEMP?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X output temperature: %f \n',retval); end
                        
                    case {'Capacitance','capacitance','Cap','cap'}
                        % read capacitance
                        fprintf(io, 'MEAS:CAP?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X output capacitance: %f F \n',retval); end
                       
                end
                
            case 'sense'
                switch value
                    case 'function_cont'
                        fprintf(io, 'FUNC "CONT"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'function_curr'
                        fprintf(io, 'FUNC "CURR"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_curr_ac'
                        fprintf(io, 'FUNC "CURR:AC"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_diod'
                        fprintf(io, 'FUNC "DIOD"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_freq'
                        fprintf(io, 'FUNC "FREQ"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_fres'
                        fprintf(io, 'FUNC "FRES"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_period'
                        fprintf(io, 'FUNC "PER"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_res'
                        fprintf(io, 'FUNC "RES"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_temp'
                        fprintf(io, 'FUNC "TEMP"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'function_volt'
                        fprintf(io, 'FUNC "VOLT"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_volt_ac'
                        fprintf(io, 'FUNC "VOLT:AC"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_cap'
                        fprintf(io, 'FUNC "CAP"');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'function_default'
                        fprintf(io, 'FUNC');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                      
                  	case 'set_current_ac_null'
                        fprintf(io, 'CURRent:AC:NULL:STAT %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'set_current_dc_null'
                        fprintf(io, 'CURRent:DC:NULL:STAT %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'get_current_ac_null'
                        fprintf(io, 'CURRent:AC:NULL:STAT?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'get_current_dc_null'
                        fprintf(io, 'CURRent:DC:NULL:STAT?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'set_current_ac_null_val'
                        fprintf(io, 'CURRent:AC:NULL:VAL %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                                               
                  	case 'set_current_dc_null_val'
                        fprintf(io, 'CURRent:DC:NULL:VAL %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'get_current_ac_null_val'
                        fprintf(io, 'CURRent:AC:NULL:VAL?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                              
                  	case 'get_current_dc_null_val'
                        fprintf(io, 'CURRent:DC:NULL:VAL?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'get_current_ac_null_val_auto'
                        fprintf(io, 'CURRent:AC:NULL:VALue:AUTO?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'get_current_dc_null_val_auto'
                        fprintf(io, 'CURRent:DC:NULL:VALue:AUTO?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'set_current_ac_null_val_auto'
                        fprintf(io, 'CURRent:AC:NULL:VALue:AUTO %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'set_current_dc_null_val_auto'
                        fprintf(io, 'CURRent:DC:NULL:VALue:AUTO %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                    case 'current_ac_range'
                        fprintf(io, 'CURR:AC:RANGe');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'current_dc_range'
                        fprintf(io, 'CURR:DC:RANGe');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                          
                 	case 'get_current_ac_range_auto'
                        fprintf(io, 'CURR:AC:RANGe:AUTO?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'get_current_dc_range_auto'
                        fprintf(io, 'CURR:DC:RANGe:AUTO?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'set_current_ac_range_auto'
                        fprintf(io, 'CURR:AC:RANGe:AUTO %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'set_current_dc_range_auto'
                        fprintf(io, 'CURR:DC:RANGe:AUTO %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'get_current_nlpc'
                        fprintf(io, 'CURR:NLPC?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'set_current_nlpc'
                        fprintf(io, 'CURR:NLPC %f', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'get_current_bandw'
                        fprintf(io, 'CURR:BAND?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                     
                  	case 'set_current_bandw'
                        fprintf(io, 'CURR:BAND %f', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'get_current_az'
                        fprintf(io, 'CURR:AZ?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'set_current_az'
                        fprintf(io, 'CURR:AZ %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                          
                   	case 'temp_null'
                        fprintf(io, 'SENSe:TEMPerature:NULL:STATe');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'get_temp_null_val'
                        fprintf(io, 'TEMPerature:NULL:VALue?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                	case 'set_temp_null_val'
                        fprintf(io, 'TEMPerature:NULL:VALue %f', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                                                
                 	case 'temp_null_auto'
                        fprintf(io, 'TEMPerature:NULL:VALue:AUTO');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'temp_trans'
                        fprintf(io, 'TEMPerature:TRANsducer?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'current_trans_ude_list'
                        fprintf(io, 'TEMPerature:UDEF:THER:TRANsducer:LIST?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'current_trans_udef_ther'
                        fprintf(io, 'TEMPerature:UDEF:THER:TRAN %s', value2);
                        retval=0;
                        
                  	case 'current_trans_mdef_ther'
                        fprintf(io, 'TEMPerature:MDEF:THER:TRAN %s', value2);
                        retval=0;
                        
                  	case 'current_trans_udef_rtd'
                        fprintf(io, 'TEMPerature:UDEF:RTD:TRAN %s', value2);
                        retval=0;
                        
                  	case 'current_trans_mdef_rtd'
                        fprintf(io, 'TEMPerature:MDEF:RTD:TRAN %s', value2);
                        retval=0;
                                 
                  	case 'current_trans_udef_ther_point'
                        fprintf(io, 'TEMPerature:UDEF:THER:TRAN:POINt %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end  
                        
                  	case 'current_trans_mdef_ther_point'
                        fprintf(io, 'TEMPerature:MDEF:THER:TRAN:POINt %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end  
                        
                  	case 'current_trans_udef_rtd_point'
                        fprintf(io, 'TEMPerature:UDEF:RTD:TRAN:POINt %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end  
                        
                  	case 'current_trans_mdef_rtd_point'
                        fprintf(io, 'TEMPerature:MDEF:RTD:TRAN:POINt %s', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end  
                        
                 	case 'volt_ac_null'
                        fprintf(io, 'VOLT:AC:NULL:STAT');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'volt_dc_null'
                        fprintf(io, 'VOLT:DC:NULL:STAT');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'volt_ac_null_val'
                        fprintf(io, 'VOLT:AC:NULL:VAL');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'VOLT_dc_null_val'
                        fprintf(io, 'VOLT:DC:NULL:VAL');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'volt_ac_null_val_auto'
                        fprintf(io, 'VOLT:AC:NULL:VALue:AUTO');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                        
                  	case 'volt_dc_null_val_auto'
                        fprintf(io, 'VOLT:DC:NULL:VALue:AUTO');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                    case 'volt_ac_range'
                        fprintf(io, 'VOLT:AC:RANGe');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'volt_dc_range'
                        fprintf(io, 'VOLT:DC:RANGe');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'volt_ac_range_auto'
                        fprintf(io, 'VOLT:AC:RANGe:AUTO');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'volt_dc_range_auto'
                        fprintf(io, 'VOLT:DC:RANGe:AUTO');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                  	case 'volt_nlpc'
                        fprintf(io, 'VOLT:NLPC');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end     
                          
                  	case 'volt_impedance'
                        fprintf(io, 'VOLT:DC:IMP');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end      
                        
                  	case 'volt_bandw'
                        fprintf(io, 'VOLT:BAND %f', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end 
                        
                  	case 'volt_az_on'
                        fprintf(io, 'VOLT:AZ ON');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end 
                        
                  	case 'volt_az_off'
                        fprintf(io, 'VOLT:AZ OFF');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end 
                        
                  	case 'cap_null'
                        fprintf(io, 'CAPacitance:NULL:STAT');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                    case 'cap_null_value'
                        fprintf(io, 'CAP:NULL:VAL');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'cap_null_val_auto'
                        fprintf(io, 'CAPacitance:NULL:VALue:AUTO');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end

                 	case 'cap_range'
                        fprintf(io, 'CAPacitance:RANGe');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end
                        
                 	case 'cap_range_auto'
                        fprintf(io, 'CAP:RANGe:AUTO');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X function: %f \n',retval); end            
     
                end
                
            case 'route'
                switch value
                    case 'stat'
                        fprintf(io, 'ROUTe:STATe?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end
                        
                	case 'get_scan'
                        fprintf(io, 'ROUTe:SCAN?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end
                        
                	case 'scan_on'
                        fprintf(io, 'ROUTe:SCAN ON');
                        retval=0;
                        
                	case 'scan_off'
                        fprintf(io, 'ROUTe:SCAN OFF');
                        retval=0;
                        
                    case 'get_start'
                        fprintf(io, 'ROUTe: STARt?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end
                        
                    case 'start_on'
                        fprintf(io, 'ROUTe: STARt ON');
                        retval=0;

                    case 'start_off'
                        fprintf(io, 'ROUTe: STARt OFF');     
                        retval=0;
                              
                    case 'function'
                    	fprintf(io, 'ROUTe: FUNCtion?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end
                        
                	case 'get_delay'
                        fprintf(io, 'ROUTe: DELay?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end
                        
                	case 'set_delay'
                        fprintf(io, 'ROUTe: DELay %f', value2);
                        retval=0;
                        
                	case 'get_count_auto'
                        fprintf(io, 'ROUTe:COUNt:AUTO?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end    
                        
                	case 'set_count_auto'
                        fprintf(io, 'ROUTe:COUNt:AUTO %s', value2);  
                        retval=0;
                        
                    case 'get_count'
                        fprintf(io, 'ROUTe:COUNt?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end
                        
                    case 'set_count'
                        fprintf(io, 'ROUTe:COUNt %f', value2);
                        retval=0;
                        
                    case 'get_limit_high'
                        fprintf(io, 'ROUTe: LIMIt:HIGH?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end   
                        
                    case 'get_limit_low'
                        fprintf(io, 'ROUTe: LIMIt:LOW?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end  
                        
                    case 'set_limit_high'
                        fprintf(io, 'ROUTe: LIMIt:HIGH %f', value2);
                        retval=0;
                        
                    case 'set_limit_low'
                        fprintf(io, 'ROUTe: LIMIt:LOW %f', value2);
                        retval=0;
                        
                	case 'data'
                        fprintf(io, 'ROUTe:DATA? %f', value2);
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end    
                        
                	case 'channel'
                        fprintf(io, 'ROUTe: CHANnel?');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end   
                        
                    case 'relative'
                        fprintf(io, 'ROUTe: RELAtive %s', value2);  
                        retval=0;
                        
                    case 'impedance_10m'
                        fprintf(io, 'ROUTe: IMPedance 10M'); 
                        retval=0;
                        
                     case 'impedance_10g'
                        fprintf(io, 'ROUTe: IMPedance 10G');  
                        retval=0;
                        
                	case 'temperature_rtd'
                        fprintf(io, 'ROUTe: TEMPerature:RTD PT100');
                        retval=0;
                        
                	case 'temperature_ther'
                        fprintf(io, 'ROUTe:TEMPerature:THER %s', value2);
                        retval=0;
                        
                    case 'set_temperature_unit'
                        fprintf(io, ' ROUTe:TEMPerature:UNIT %c', value2);   
                        retval=0;
                        
                    case 'threshold_cont'
                        fprintf(io, 'ROUTe:CONTinuity:THReshold:VALue');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end  
                        
                	case 'threshold_diod'
                        fprintf(io, 'ROUTe:DIODe:THReshold:VALue');
                        retval = fscanf(io,'%f');
                        if verbose >= 2, fprintf(1, 'SDM3065X route: %f \n',retval); end    
                        
                  	case 'frequency'
                        fprintf(io, 'ROUTe:FREQ');  
                        retval=0;
                        
                	case 'period'
                       fprintf(io, 'ROUTe:PER');
                       retval=0;
                        
                end
                
            otherwise
                if verbose >= 1, fprintf('Error, command not supported. ["%s"]\n',command); end
                retval=0;
        end
        
        
    else % catch incorrect address errors
        if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at GPIB %d\n',instrument,GPIB); end
        retval=0;
    end
    
    validInst = 1;
end % END SDM3065X Digital Multimeter


% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
%% End of instrument drivers
% %  add new instruments above this line
% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%

% % Trap invalid instrument calls.  If the drivers above did not recognize
% % the instrument then we issue an error.

if validInst == 0;
    if verbose >= 1
        fprintf(1, 'kpib: ERROR, invalid instrument ["%s/%s"].\n',instrument,num2str(GPIB));
    end
    retval=0;
end

return

%% function port
function io = port(addressGPIB, instrument, value, verbose, gpib_interface_BOARDINDEX)
% IO = PORT(ADRESSGPIB, INSTRUMENT, VALUE, VERBOSE)
% PORT opens a GPIB or a serial port connection for a device. If
%  addressGPIB is a number, the connection is GPIB. If addressGPIB is a
%  string (e.g. 'COM1'), the connection is through a serial port. The
%  INSTRUMENT parameter allows port to adjust settings specific to each
%  instrument (mostly buffer size). VALUE is the buffer size for GPIB or
%  the baudrate for serial connections. VERBOSE level of 3 provides some
%  debugging details about the connection.
%
% Example for de definition of the HP_3478A
%
% if (strcmpi(instrument, 'HP_3478A') || strcmpi(instrument, 'all'))
%    io = port(GPIB, instrument, 0, verbose); -----------------------> Define port with GPIB address
%																	   the instrument name, buffer GPIB and verbose
%    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0) -----------> Check if port is open
%
%
% PORT is hardwired to use a single National Instruments GPIB card.
%  If you are using different GPIB hardware, comment in/out the appropriate
%  section below.
%
% based on PORT by AP JUL2004
%
%logical_board_index=gpib_interface_BOARDINDEX; %esta funciona, descomentar si falla



ioTimout           = 4;   % Seconds that we wait for an instrument to reply before giving up
ioInBuffsize       = 1000; % Minimum buffer size for GPIB inputs
serialTerminator   = 'LF'; % default value for serial port

% verbose defaults to on
if nargin < 4
    verbose = 2;
end
% input buffer default (set value above)
if nargin < 3
    value = ioInBuffsize;
end

% certain instruments require special settings
%  if the user has specified a larger buffer size, use it, but not smaller
if isequal(instrument,'HP_89410A')  %Test to see whether or not to implement special case.
    ioTimout           = 30;
end
if isequal(instrument,'HP_34420A') %Test to see whether or not to implement special case.
    ioTimout           = 10;       %100 % May need to increase timeout for automatic data collection.
end
if isequal(instrument,'OH_EXP')
    serialTerminator   = 'CR/LF';   % The Ohaus Explorers require CR/LF terminator.
end

% maybe the user wants some arbitrary value
if value > ioInBuffsize
    ioInBuffsize = value;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1st CASE.   port: serial port instrument
% is this a GPIB instrument or a serial instrument?

% if GPIB is not a number, then it must be a serial port
if ~isnumeric(addressGPIB)
    % check to see if the port exists already
    if isempty(instrfind('Type','serial','Port',addressGPIB))
        %io = serial(addressGPIB,'BaudRate',value);
        io = serial(addressGPIB, 'BaudRate', value,...
            'StopBits',1 ,...
            'DataBits', 8,...
            'Parity', 'none',...
            'FlowControl', 'none');
        %io.InputBufferSize = ioInBuffsize;
        io.Timeout = ioTimout;
        io.Terminator = serialTerminator;
        fopen(io);
        %stopasync(io);   %descomentar
        if verbose >= 3
            fprintf(1,'kpib/port: Opening port %s',addressGPIB);
            b=get(io,'BaudRate');
            p=get(io,'Parity');
            s=get(io,'StopBit');
            t=get(io,'Terminator');
            fprintf(1,' with %d baud, Parity %s, %d stopbits, Terminator: %s  \n',b,p,s,t);
        end
        
    else
        io = instrfind('Type','serial','Port',addressGPIB);
        if ~isequal(io.Status,'open')
            fopen(io);
            if verbose >= 3, fprintf('kpib/port: Existing serial port is closed; open it (%s)\n',num2str(addressGPIB)); end
        end
        if verbose >= 3
            fprintf(1,'kpib/port: Port %s is already open',addressGPIB);
            b=get(io,'BaudRate');
            p=get(io,'Parity');
            s=get(io,'StopBit');
            t=get(io,'Terminator');
            fprintf(1,' with %d baud, Parity %s, %d stopbits, Terminator: %s  \n',b,p,s,t);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 2nd CASE.   port: GPIB instrument
    % is this a GPIB instrument or a serial instrument?
    % else if GPIB is a number, its a GPIB address
else
    
    % % Choose between "regular" (PCI or similar) and USB (virtual serial port)
    % %   GPIB interface hardware by commenting in/out the appropriate section below
    
    % % Uncomment for regular GPIB interface card (e.g. PCI)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% port: GPIB PCI
    %% If we do: >>instrfind
    % GPIB Object Using AGILENT Adaptor : GPIB7-3
    
    % Communication Address
    % BoardIndex:         7
    % PrimaryAddress:     3
    % SecondaryAddress:   0
    
    % Communication State
    % Status:             open
    % RecordStatus:       off
    
    % Read/Write State
    % TransferStatus:     idle
    % BytesAvailable:     0
    % ValuesReceived:     26
    % ValuesSent:         28
    
    if isempty(instrfind('Type','gpib','PrimaryAddress',addressGPIB))
        try
            % CHANGE FOLLOWING LINE TO USE DIFFERENT GPIB CARD MANUFACTURER    GPIBMAN
            %  See MATLAB documentation for list of supported manufacturers
            %  http://www.mathworks.com/products/instrument/supportedio13769.html
            % (If using USB with a COM port, then comment out this section and see below)
            
            gpib_interface_manufacturer = 'agilent'; % 'agilent'   Agilent
            %gpib_interface_manufacturer = 'ni'; % 'ni'   National Instruments
            % 'ics'  ICS Electronics
            %gpib_interface_index = gpib_interface_BOARDINDEX;
            io = gpib(gpib_interface_manufacturer,gpib_interface_BOARDINDEX,addressGPIB);
            io.InputBufferSize = ioInBuffsize;
            io.Timeout=ioTimout;
            fopen(io);
            if verbose >= 3, fprintf('kpib/port: Create new GPIB port (%d).\n',addressGPIB); end
            
        catch
            if verbose >= 1
                fprintf('kpib/port: ERROR: cannot open GPIB address %d on interface %s\n',addressGPIB,gpib_interface_manufacturer);
                fprintf('           Use ''scan'' to see a list of available instruments.\n');
            end
            io = 0;
        end
        
    else
        io = instrfind('Type','gpib','PrimaryAddress',addressGPIB);
        if verbose >= 3, fprintf('kpib/port: Use existing GPIB port (%d).\n',addressGPIB); end
        if ~isequal(io.Status,'open')
            fopen(io);
            if verbose >= 3, fprintf('kpib/port: Existing port is closed; open it (%d).\n',addressGPIB); end
        end
    end
    
    %% Special GPIB settings
    % Some instruments require particular or unusual GPIB settings
    % The End of Statement (EOS) setting is default none. Several
    %  instruments seem to operate more smmothly with a setting of
    %  'read&write'. Documentation is scarce, results are down to
    %  experimentation.
    %
    % In particular, the KTH_236 often hangs, and it has a default EOS char of
    % CRLF, as opposed to the MATLAB default of LF. The KTH_236 'init'
    % command changes the instrument to LF.  Hard to say.
    %  (MH, v3.2,4.8)
    % Subsequent testing with a KTH_238 indicates that the previous setting was
    % not correct- the default setting for the output terminator is CR/LF,
    % so a matlab setting of LF (the default) works fine.
    if io ~= 0
        if any(strcmp(instrument,{'FLK_294' 'HP_8753ES'}))
            set(io,'EOSMode','read&write'); % this setting may cause problems with USB adapters such as ICS
            % See
            % http://www.mathworks.com/support/solutions/en/data/1-1AY1U/index.html?product=IC&solution=1-1AY1U
            %set(io,'EOSCharCode','CR'); % 'LF' is default
            
        end
        if any(strcmp(instrument,{'AcuOven','ACT_981','ACT_TEMP','WAT_981'}))
            io.EOSCharCode = 13; % CR
            io.EOSmode='read&write';
        end
        if verbose >= 3
            EOImode=get(io,'EOIMode');
            EOScc=get(io,'EOSCharCode');
            EOSmode=get(io,'EOSMode');
            TmOut=get(io,'Timeout');
            BufSz=get(io,'InputBufferSize');
            fprintf('kpib/port: EOIMode: %s; EOSMode: %s; EOSCharCode: %s; Timeout: %d sec; Buffer Size: %d bytes\n',EOImode,EOSmode,num2str(EOScc),TmOut,BufSz);
        end
    end
    
    % % End Regular GPIB interface card
    
    
end % open GPIB port

return

% %% %% %% %% %
% % END KPIB
