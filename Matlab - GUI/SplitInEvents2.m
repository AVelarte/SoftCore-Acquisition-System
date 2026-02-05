
function DataEventsStruct= SplitInEvents2(Data, selectedChannel, ParamStruct)
% SplitInEvents Separa los datos del canal seleccionado en los eventos que
% se han producido. En caso de que uno de los eventos tenga mayor
% longitud, añade padding en el resto para conseguir vectores de la misma
% longitud. 
% 
% Hay que tener en cuenta que el StartPos no puede superar el primer evento
%
%   DataEvenstStruct = SplitInEvents(Data, selectedChannel)
%       Data = LabData  --> Clase con los datos a analizar
%       selectedChannel --> Número del canal a anlizar (int)
%       ParamStruct --> Estructura que contiene los datos:
%           Threshold --> Límite que superan los picos respecto al resto de la
%               señal (typ. 1000)
%           Prominence --> Diferencia entre el pico máximo y el resto de picos
%               que hay a su alrededor (typ. 500)
%           StartPos --> Número de muestras anteriores al pico máximo que se
%               toman a la hora de separar los eventos (typ. 90)
%       DataEventsStruct --> Estructura con los eventos separados y el eje de tiempos.
%           Fields:
%               - Event_1   --> [1xm] double
%               - Event_2   --> [1xm] double
%               - ...
%               - Event_n   --> [1xm] double
%               - Timestamp --> [1xm] double
%               - ChannelNumber --> double

    switch nargin
        case 3
            DataEventsStruct = struct();
            threshold = ParamStruct.Threshold;
            prominence = ParamStruct.Prominence;
            StartPos = ParamStruct.StartPos;
            
            SelectedData = Data.GetChannelConvertedData(selectedChannel);

            [pks, locs] = findpeaks(SelectedData, 'MinPeakHeight', threshold,...
                        'MinPeakProminence', prominence);
            
            maxSize = 0;
            for i = 1:length(locs)-1
                tmp = locs(i+1)-locs(i);
                if(tmp > maxSize)
                    maxSize = tmp;
                end
            end

            AllSignalEvents = zeros(length(locs)-1, maxSize);
            for i = 1:length(locs)-1
                tmp = SelectedData(locs(i)-StartPos:locs(i+1)-StartPos -1);
                if(length(tmp) < maxSize)
                    tmp = [tmp zeros(1,maxSize - length(tmp))];
                end
                DataEventsStruct.(['Event_' num2str(i,"%02d")]) = tmp;
                AllSignalEvents(i,:)= tmp;
            end

            DataEventsStruct.("Timestamp") = Data.ChannelsTimestamps(1:1-1+size(AllSignalEvents,2));
            DataEventsStruct.("zChannelNumber") = selectedChannel;

        case 2 % Utiliza los eventos del trigger que acompaña la señal. 
            DataEventsStruct = struct();

            ChannelData = Data.GetChannelConvertedData(selectedChannel);
            
            aux = GetProgramInfo(Data);
            if strcmp(aux.name, "Open Ephys")
                TriggerHighSamples = Data.TriggerSampleNumber(1:2:end);
                TriggerLowSamples = Data.TriggerSampleNumber(2:2:end);
            elseif strcmp(aux.name, "FPGA-Platform")
                TriggerHighSamples = Data.TriggerSampleNumber(1:1:end);
            end
            % Nota: Faltaría un caso para le MCS, pero no lo hemos probado
            % capturando el trigger. 

            TriggerHpos = [];
            for i = 1:length(TriggerHighSamples)
                TriggerHpos(i) = find(Data.ChannelsSampleNumber == TriggerHighSamples(i));
            end

            EventSample = {};
            aux = length(TriggerHpos);
            for i = 1:aux
                if (i) < length(TriggerHpos)
                    %Como puede darse el caso de que el primer Trigger llegue con
                    %la muestra 0, cuando ocurra esto se camiará por un 1, se
                    %pierde una muestra pero no presenta grandes problemas
                    if(TriggerHpos(i) == 0) TriggerHpos(i) = 1; end
                    tmp = ChannelData(TriggerHpos(i):TriggerHpos(i+1)-1);
                    EventSample{i,1} = tmp;
                    EventSample{i, 2} = length(tmp);
                else
                    tmp = ChannelData(TriggerHpos(i):end);
                    EventSample{i,1} = tmp;
                    EventSample{i, 2} = length(tmp);
                end
            end
            maxEventLength = max(cell2mat(EventSample(:,2)));

            for i = 1:size(EventSample,1)
                if length(EventSample{i,1}) < maxEventLength
                    tmp = [EventSample{i,1} zeros(1, maxEventLength - length(EventSample{i,1}))];
                    DataEventsStruct.(['Event_' num2str(i,"%02d")]) = tmp;
                else
                    DataEventsStruct.(['Event_' num2str(i,"%02d")]) = EventSample{i,1};
                end
            end

            DataEventsStruct.("Timestamp") = Data.ChannelsTimestamps(1:maxEventLength)' - Data.ChannelsTimestamps(1);
            DataEventsStruct.("zChannelNumber") = selectedChannel;
    end
end