function EventFeatures = FeaturesExtractor(SplitEventsData, SplitChannel, SelectedEvent)
    % Función que extrae todas las características del evento seleccionado
    % y devuelve una estructura con ellas. Extrae Tap y amplitud del pico
    % (vp-Vp)

    EventFeatures = struct();
    pend = diff(SplitEventsData.(SelectedEvent));
    [minpend, mpindex] = min(pend);
    % Encontramos el punto Tpeak
    [PeakVle, Peakindex] = max(SplitEventsData.(SelectedEvent)(mpindex+1:end));
    % Hacemos el cálculo del tiempo
    Tap = SplitEventsData.Timestamp(mpindex + Peakindex) - ...
          SplitEventsData.Timestamp(mpindex);
    % Calculamos amplitud del pico grande
    MaxPeak = max(SplitEventsData.(SelectedEvent)(1:mpindex));
    MinPeak = min(SplitEventsData.(SelectedEvent)(mpindex+1:mpindex+Peakindex));
    PeakAmplitude = MaxPeak - MinPeak;
    
    EventFeatures.Temp.T0.timePos = mpindex;
    EventFeatures.Temp.T0.time =  SplitEventsData.Timestamp(mpindex);
    EventFeatures.Temp.T0.value = SplitEventsData.(SelectedEvent)(mpindex);
    
    EventFeatures.Temp.Tpeak.timePos = mpindex +Peakindex;
    EventFeatures.Temp.Tpeak.time = SplitEventsData.Timestamp(mpindex + Peakindex);
    EventFeatures.Temp.Tpeak.value = SplitEventsData.(SelectedEvent)(mpindex + Peakindex);
    
    EventFeatures.Temp.Tap = Tap;
    
    EventFeatures.Ampl.MaxPeak = MaxPeak;
    EventFeatures.Ampl.MinPeak = MinPeak;
    
    EventFeatures.Ampl.PeakAmplitude = PeakAmplitude;
end