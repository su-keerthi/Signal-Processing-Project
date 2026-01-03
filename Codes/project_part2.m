clear; 

audioFiles = {'File1.wav', 'File2.wav', 'File3.wav', 'File4.wav'};
threshold_factor = 0.15;
min_hit_separation = 0.05;

for fileIdx = 1:length(audioFiles)
    filename = audioFiles{fileIdx};
    fprintf('\n File number: %s \n', filename);

    [y, fs] = audioread(filename);
    if size(y,2) > 1
        y = mean(y,2); 
    end
    t = (0:length(y)-1)/fs;

    % RMS envelope-10ms
    window_size = round(0.01 * fs);
    envelope = sqrt(filter(ones(1,window_size)/window_size, 1, y.^2));

    % Peak detection
    threshold = threshold_factor * max(envelope);
    min_distance = round(min_hit_separation * fs);
    locs = [];
    pks = [];
    i = min_distance + 1;
    while i <= length(envelope) - min_distance
        if envelope(i) > threshold
            window = envelope(max(1,i-min_distance):min(length(envelope),i+min_distance));
            [pk_val, pk_idx] = max(window);
            actual_idx = max(1,i-min_distance) + pk_idx - 1;
            if actual_idx == i
                locs = [locs; i];
                pks = [pks; pk_val];
                i = i + min_distance;
            else
                i = i + 1;
            end
        else
            i = i + 1;
        end
    end

    hit_times = t(locs);
    n_hits = length(hit_times);
    fprintf('Detected %d drum hits\n', n_hits);

    % Hit durations and segments
    hit_durations = zeros(n_hits,1);
    hit_segments = cell(n_hits,1);
    hit_instruments = strings(n_hits,1);
    for i = 1:n_hits
        start_idx = locs(i);
        decay_threshold = 0.2 * pks(i);
        end_idx = start_idx;
        while end_idx < length(envelope) && envelope(end_idx) > decay_threshold
            end_idx = end_idx + 1;
        end
        hit_durations(i) = (end_idx - start_idx) / fs;

        segment_length = round(0.1 * fs);
        end_segment = min(start_idx + segment_length - 1, length(y));
        segment = y(start_idx:end_segment);
        hit_segments{i} = segment;

       
        N = length(segment);
        spec = fft(segment);
        P = abs(spec(1:floor(N/2)+1)).^2;
        freqs = (0:floor(N/2)) * fs / N;

        low_power = sum(P(freqs < 200));
        high_power = sum(P(freqs > 5000));

        if low_power > 3 * high_power
            instrument = 'Kick Drum'; %low freq
        elseif high_power > low_power
            instrument = 'Hi-Hat or Cymbal'; %high freq
        else
            instrument = 'Snare or Tom'; %Mid freq
        end
        hit_instruments(i) = instrument;
    end

    % Display results
    fprintf('%-6s %-10s %-12s %-25s\n','Hit#','Time(s)','Dur(ms)','Instrument');
    for i = 1:n_hits
        fprintf('%-6d %-10.3f %-12.1f %-25s\n', i, hit_times(i), hit_durations(i)*1000, hit_instruments(i));
    end

    
    figure;
    plot(t, y, 'LineWidth', 0.5);
    hold on;
    scatter(hit_times, y(locs), 50, 'r', 'filled');
    xlabel('Time (s)'); ylabel('Amplitude');
    title(['Detected Drum Hits: ' filename]);
    grid on;
end

