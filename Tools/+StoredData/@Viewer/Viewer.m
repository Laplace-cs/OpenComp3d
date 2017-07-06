classdef Viewer < handle
    % StoredData.Viewer is the GUIDE to plot the variables values stored during optimization
    % 
    % ex: StoredData.Viewer(data)
    %   data is a storedData structure.
    %
    %   See also StoredData.Interface, StoredData.Facture
    %
    
    properties
        storedData
        iterations
        
        uicontrolNumber1
        uicontrolNumber2
        uicontrolNumber3
        uicontrolNumber4
        
        displayData
        displayText
        
        valueChosen = cell([1,4]);
    end
    
    methods
        function obj = Viewer(storedData)
            widthLB = 130;
            heightLB = 480;
            x0 = 30;
            y0 = 10;
            
            obj.storedData = storedData;
            mycell = struct2cell(storedData);
            L = max( cellfun( @length, mycell));
            obj.iterations = 0:L-1;
            
            figure('name','Stored Data Viewer','Position',[300 500 1200 500])
            
            obj.displayData.axes = axes();
            obj.displayData.line = plot(1,1);
            set(gca,'position',[0.52 0.05 0.30 0.88]);
            set(gca,'Visible','off');
            set(obj.displayData.line,'Visible','off');
            
            obj.uicontrolNumber1 = uicontrol('Style','listbox',...
                'String',fields(obj.storedData),'Value',1,'Position',[x0 y0 widthLB heightLB],...
                'CallBack',@obj.uicontrolNumber1callback);
            
            obj.uicontrolNumber2 = uicontrol('Style','listbox',...
                'String',{'one','two',},'Value',1,'Position',[x0+widthLB,y0,widthLB,heightLB],...
                'Visible','off','CallBack',@obj.uicontrolNumber2callback);
            
            obj.uicontrolNumber3 = uicontrol('Style','listbox',...
                'String',{'one','two',},'Value',1,'Position',[x0+2*widthLB,y0,widthLB,heightLB],...
                'Visible','off','CallBack',@obj.uicontrolNumber3callback);
            
            obj.uicontrolNumber4 = uicontrol('Style','listbox',...
                'String',{'one','two',},'Value',1,'Position',[x0+3*widthLB,y0,widthLB,heightLB],...
                'Visible','off','CallBack',@obj.uicontrolNumber4callback);
            
            obj.displayText.finalValueTitle =   uicontrol('Style','Text','Position',[1025 400 150 30],'String','Final Value','Visible','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',15);
            obj.displayText.finalValueVal =     uicontrol('Style','Text','Position',[1025 360 150 30],'String','Final Value','Visible','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',15);
            obj.displayText.initialValueTitle = uicontrol('Style','Text','Position',[1025 250 150 30],'String','Initial Value','Visible','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',15);
            obj.displayText.initialValueVal =   uicontrol('Style','Text','Position',[1025 210 150 30],'String','Initial Value','Visible','off','BackgroundColor',[0.8 0.8 0.8],'FontSize',15);
            
            obj.uicontrolNumber1callback;
        end
    end
    
    methods
        function uicontrolNumber1callback(obj,hObject,eventdata)
            set(obj.uicontrolNumber2,'Visible','off')
            set(obj.uicontrolNumber3,'Visible','off')
            set(obj.uicontrolNumber4,'Visible','off')
            
            value1 = get(obj.uicontrolNumber1,'Value');
            string1 = get(obj.uicontrolNumber1,'String');
            obj.valueChosen{1} = string1{value1};
            obj.valueChosen{2} = [];
            obj.valueChosen{3} = [];
            obj.valueChosen{4} = [];
            
            newValues = obj.storedData.(obj.valueChosen{1});

            if ~isempty(newValues)
                if isstruct(newValues)
                    set(obj.uicontrolNumber2,'Visible','on')
                    set(obj.uicontrolNumber2,'Value',1);
                    set(obj.uicontrolNumber2,'String',fields(newValues));
                    obj.uicontrolNumber2callback;
                elseif isnumeric(newValues)
                    displayFunction(obj,newValues,valueChosen1)
                else
                    obj.resetDisplay;
                end
            else
                obj.resetDisplay;
            end
        end
        
        function uicontrolNumber2callback(obj,hObject,eventdata)
            set(obj.uicontrolNumber3,'Visible','off')
              
            value2 = get(obj.uicontrolNumber2,'Value');
            string2 = get(obj.uicontrolNumber2,'String');
            obj.valueChosen{2} = string2{value2};
            obj.valueChosen{3} = [];
            obj.valueChosen{4} = [];
            
            newValues = [obj.storedData.(obj.valueChosen{1}).(obj.valueChosen{2})];
            
            if ~isempty(newValues)
                if isstruct(newValues)
                    set(obj.uicontrolNumber3,'Visible','on');
                    set(obj.uicontrolNumber3,'Value',1);
                    set(obj.uicontrolNumber3,'String',fields(newValues));
                    obj.uicontrolNumber3callback;
                elseif isnumeric(newValues)
                    obj.displayFunction( newValues, obj.valueChosen{2})
                else
                    obj.resetDisplay;                
                end
            else
                obj.resetDisplay;                
            end
        end
        
        function uicontrolNumber3callback(obj,hObject,eventdata)
            set(obj.uicontrolNumber4,'Visible','off')
            
            value3 = get(obj.uicontrolNumber3,'Value');
            string3 = get(obj.uicontrolNumber3,'String');
            obj.valueChosen{3} = string3{value3};
            obj.valueChosen{4} = [];
            
            newValues = [obj.storedData.(obj.valueChosen{1}).(obj.valueChosen{2})];
            newValues = [newValues.(obj.valueChosen{3})];
            
            if ~isempty(newValues)
                if isstruct(newValues)
                    set(obj.uicontrolNumber4,'Visible','on')
                    set(obj.uicontrolNumber4,'Value',1);
                    set(obj.uicontrolNumber4,'String',fields(newValues));
                    obj.uicontrolNumber4callback;
                elseif isnumeric(newValues)
                    obj.displayFunction( newValues, obj.valueChosen{3})
                else
                    obj.resetDisplay;                
                end
            else
                obj.resetDisplay;
            end
        end
        
        function uicontrolNumber4callback(obj,hObject,eventdata)
            value4 = get(obj.uicontrolNumber4,'Value');
            string4 = get(obj.uicontrolNumber4,'String');
            obj.valueChosen{4} = string4{value4};
            
            newValues = [obj.storedData.(obj.valueChosen{1}).(obj.valueChosen{2})];
            newValues = [newValues.(obj.valueChosen{3})];
            newValues = [newValues.(obj.valueChosen{4})];
                        
            if ~isempty(newValues)
                if isstruct(newValues)
                elseif isnumeric(newValues)
                    obj.displayFunction( newValues, obj.valueChosen{4})
                else
                    obj.resetDisplay;                
                end
            else
                obj.resetDisplay;                
            end
        end
    end
    
    methods (Access = protected)
        function displayFunction(obj,newValues,name)
            if length(obj.iterations) ~= length(newValues)
                newValues = reshape(newValues,length(newValues)/length(obj.iterations),length(obj.iterations));
            end
            
            obj.displayData.line = plot(obj.iterations,newValues);
            grid on
            xlabel('iterations');
            ylabel(name);
            
            set(obj.displayText.finalValueTitle,'Visible','on');
            set(obj.displayText.finalValueVal,'Visible','on');
            set(obj.displayText.initialValueTitle,'Visible','on');
            set(obj.displayText.initialValueVal,'Visible','on');
            
            set(obj.displayText.finalValueVal,'String',num2str(newValues(end)));
            set(obj.displayText.initialValueVal,'String',num2str(newValues(1)));
            
            axes(obj.displayData.axes);
            set(obj.displayData.line,'Visible','on');
        end
        
        function resetDisplay(obj)
            set(obj.displayText.finalValueVal,'Value',1);
            set(obj.displayText.initialValueVal,'Value',1);
            
            set(obj.displayData.axes,'Visible','off');
            set(obj.displayData.line,'Visible','off');
            set(obj.displayText.finalValueTitle,'Visible','off');
            set(obj.displayText.finalValueVal,'Visible','off');
            set(obj.displayText.initialValueTitle,'Visible','off');
            set(obj.displayText.initialValueVal,'Visible','off');
        end
    end
end

