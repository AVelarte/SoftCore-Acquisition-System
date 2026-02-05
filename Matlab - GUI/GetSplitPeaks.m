function varargout = GetSplitPeaks(Data, Timestamp, Threshold,getValue)
%GetSplitPeaks Se encarga de pasar los datos y el timestamp encontrar todos
%los spikes que hay en el record y devolver un vector con la posición de
%los spikes en el timestamp.
%   SpikesPositions = GetSplitPeaks(Data, Timestamp,Threshold)
%       Data  --> Vector con los datos a analizar
%       Timestamp --> vector con el tiempo de los datos
%       Threshold --> umbral sobre el que detectar los spikes de tiempo
%       SpikesPositions --> Timestamp asociado a los distintos spikes
%       encontrados. 

    [pks, loc] = findpeaks(Data);

    switch nargin
        case 3
            varargout = Timestamp(loc);
        case 4
            varargout = [Timestamp(loc), pks];
    end
end