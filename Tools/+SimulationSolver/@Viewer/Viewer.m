classdef Viewer < handle
    % SimulationSolver.Viewer is the GUIDE to plot simulation results
    % 
    % ex: SimulationSolver.Viewer(simulationResults)
    %   simulationResults is a structure with simulation results
    %
    %   See also SimulationSolver.Interface, SimulationSolver.Facture
    %
    
    %RESULTSVIEWER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        resultsStruct   % Structure containing the result
        namesVector     % Vector with the names of the waveForm
        time            % time Vector
        freq            % frequency Vector
        namesListBox
        callBackButton
        axesTime        % plot of the time figure
        axesFreq        % plot ot the frequency figure
    end
    
    methods
        function obj = Viewer(input)
            obj.separateStruct(input);
            
            figure('name','Simulation Results Viewer','Position',[300 500 800 500])
            
            obj.axesTime = axes();
            plot(1,1);
            set(gca,'position',[0.35 0.6 0.60 0.35]);
            
            obj.axesFreq = axes();
            plot(1,1);
            set(gca,'position',[0.35 0.1 0.60 0.35]);
            
            obj.namesListBox = uicontrol( ...
                'Style', 'listbox', ...
                'String', obj.namesVector, ...
                'Value', 1, ...
                'Position', [50 35 150 450], ...
                'CallBack', @obj.displayData  ...
                );
            
            obj.displayData;
        end
    end
    
    methods (Access = protected)
        
        function displayData(obj,hObject,eventData)
            value = get(obj.namesListBox,'Value');
            stringValue = get(obj.namesListBox,'String');
            stringChosen = stringValue{value};
            
            axes(obj.axesTime)

            plot(obj.time,obj.resultsStruct.(stringChosen));
            grid on
            xlabel('Time (s)')
            ylabel('Current (A)');
            if stringChosen(1) == 'i'
                ylabel('Current (A)');
            elseif stringChosen(1) == 'v'
                ylabel('Voltage (V)');
            end

            axes(obj.axesFreq)

            stem(obj.freq,abs(obj.resultsStruct.([stringChosen,'_fft'])));
            xlabel('Freq (Hz)');
            if stringChosen(1) == 'i'
                ylabel('Current (A)');
            elseif stringChosen(1) == 'v'
                ylabel('Voltage (V)');
            end
        end
        
        function separateStruct(obj,input)
            obj.time = input.simuTime;
            obj.freq = input.simuFreq;
            
            obj.resultsStruct = rmfield(input,{'simuTime','simuFreq'});
            
            names = fieldnames(obj.resultsStruct);

            idxVector = strfind(names,'_fft');
            names(cellfun(@(x) ~isempty(x),idxVector)) = '';
            
            names(cellfun(@(x) strcmp(x,'mcLosses'),names)) = '';
            names(cellfun(@(x) strcmp(x,'mcDesign'),names)) = '';
            obj.namesVector = names;
        end
    end
end

