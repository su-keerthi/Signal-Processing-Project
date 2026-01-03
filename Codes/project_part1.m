clear; 

fs = 1000;          
Ts = 1/fs;
N = 2048;           
t = (0:N-1)*Ts;     
f_cut = 200;

s1_fun = @(tt) sin(2*pi*50*tt) + 0.6*sin(2*pi*120*tt);

s2_fun = @(tt) cos(2*pi*80*tt);

sigma = 0.02;
center = 0.5;
s3_fun = @(tt) exp(-((tt - center).^2) / (2*sigma^2));

s1 = s1_fun(t);
s2 = s2_fun(t);
s3 = s3_fun(t);

signals = {s1, s2, s3};
signal_funs = {s1_fun, s2_fun, s3_fun};  
names = {'combination of sines', 'Cosine 80 Hz', 'Gaussian Pulse'};

%a 
K_values = 1:4;
MSE_a = zeros(length(signals), length(K_values));

for si = 1:length(signals)
    x_true = signals{si};        
    xfun = signal_funs{si};      

    for kidx = 1:length(K_values)
        K = K_values(kidx);

        jitterInts = randi([-K K], 1, N);
        Delta = Ts/10;
        t_jitter = t + jitterInts * Delta;  
        x_jit = xfun(t_jitter);   

        x_rec = zeros(1,N);
        window = 50;
        for n = 1:N
            il = max(1, n-window);
            ih = min(N, n+window);
            tau = (t(n) - t_jitter(il:ih))/Ts;
            w = sinc(tau);                    
            x_rec(n) = sum(x_jit(il:ih).*w);
        end

        MSE_a(si, kidx) = mean((x_rec - x_true).^2);
    end
end

%b
p_values = 0.01:0.01:0.1;
MSE_b = zeros(length(signals), length(p_values));

for si = 1:length(signals)
    x_true = signals{si};
    for pidx = 1:length(p_values)
        p = p_values(pidx);

        mask = randi([0,1],1,N) > p;   
        measured = zeros(1,N);
      
        xfun = signal_funs{si};
        x_full = xfun(t);           
        measured(mask) = x_full(mask);
        known = find(mask);
        x_init = interp1(known, measured(known), 1:N, 'linear', 'extrap');

        x_rec = x_init;
        
        for it = 1:200
            X = fft(x_rec);
            freqs = (0:N-1)*(fs/N);
            freq_mask = (freqs <= f_cut) | (freqs >= fs - f_cut);
            X(~freq_mask) = 0;
            temp = real(ifft(X));
            temp(mask) = measured(mask);
            x_rec = temp;
        end

        MSE_b(si, pidx) = mean((x_rec - x_true).^2);
    end
end

figure;
plot(K_values, MSE_a', '-o','LineWidth',1.5);
xlabel('K (max jitter integer)'); ylabel('MSE');
title('Scenario (a): MSE vs K (jitter)'); legend(names); grid on;

figure;
plot(p_values, MSE_b', '-o','LineWidth',1.5);
xlabel('p (missing probability)'); ylabel('MSE');
title('Scenario (b): MSE vs p (missing samples)'); legend(names); grid on;

%example
idx = 400:650;  
for si = 1:length(signals)
    x_true = signals{si};
    xfun = signal_funs{si};
    sigName = names{si};

    K = 3;
    jitterInts = randi([-K K], 1, N);
    t_jitter = t + jitterInts*(Ts/10);
    x_jit = xfun(t_jitter);
    %a
    x_rec_a = zeros(1,N);
    for n = 1:N
        il = max(1, n-window);
        ih = min(N, n+window);
        tau = (t(n) - t_jitter(il:ih))/Ts;
        x_rec_a(n) = sum(x_jit(il:ih).*sinc(tau));
    end
    %b
    p = 0.05;
    mask = rand(1,N) > p;
    measured = zeros(1,N);
    measured(mask) = xfun(t(mask));
    known = find(mask);
    x_init = interp1(known, measured(known), 1:N, 'linear','extrap');
    x_rec_b = x_init;
    for it = 1:200
        X = fft(x_rec_b);
        freqs = (0:N-1)*(fs/N);
        freq_mask = (freqs <= f_cut) | (freqs >= fs-f_cut);
        X(~freq_mask) = 0;
        temp = real(ifft(X));
        temp(mask) = measured(mask);
        x_rec_b = temp;
    end

    figure;
    plot(t(idx), x_true(idx), 'LineWidth',1.2); hold on;
    plot(t(idx), x_rec_a(idx),'--','LineWidth',1.2);
    scatter(t_jitter(idx), x_jit(idx), 12, 'filled');
    title(['Part A recon — ' sigName]); legend('True','Recon','Measured (jitter)'); grid on;

    figure;
    plot(t(idx), x_true(idx), 'LineWidth',1.2); hold on;
    plot(t(idx), x_rec_b(idx),'--','LineWidth',1.2);
    local_mask = mask(idx);
    scatter(t(idx(local_mask)), measured(idx(local_mask)), 20, 'filled');
    title(['Missing-sample recon — ' sigName]); legend('True','Recon','Measured (present)'); grid on;
end
