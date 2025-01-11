clear; close all;

%% Output directory

out_dir = mfilename('fullpath');
out_dir = out_dir(1:end-length(mfilename));
out_dir = [out_dir, 'out/'];

if ~exist(out_dir,'dir')
    mkdir(out_dir);
end

file = [out_dir, 'cfg.mat'];
load(file);

n_M = length(M_v);
n_ber = length(theo_ber_v);

ber_est_m = zeros(n_M,n_ber);
ber_theo_m = zeros(n_M,n_ber);
ebno_db_m = zeros(n_M,n_ber);

%% Read data

for idx_1 = 1:n_M
    
    M = M_v(idx_1);
    
    name = sprintf('M%d',M);
    file = [out_dir, 'out_',name,'.mat'];
    load(file);

    for idx_2 = 1:n_ber

        ber_est_m(idx_1,idx_2) = out_c{idx_2}.ber_est;
        ber_theo_m(idx_1,idx_2) = out_c{idx_2}.ber_theo;

    end
end
%% Plots

idx_fig = 1;
fz = 15;
color_c = { [0 0.45 0.74]
            [0.85 0.33 0.1]
            [0.93 0.69 0.13]
            [0.49 0.18 0.56]
            [0.47 0.67 0.19]
            [0.30 0.75 0.93]
            [0.64 0.08 0.18]};

% BER vs EbNo
figure; 
leg = {}; idx_leg = 1;
        
for idx_1 = 1:n_M
    
    M = M_v(idx_1);
    ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);
    
    ber_theo_v = ber_theo_m(idx_1,:);
    ber_est_v = ber_est_m(idx_1,:);
    
    p = semilogy(ebno_db_v, ber_theo_v, '--', 'Linewidth', 1.5);
    p.Color = color_c{idx_1}; 
    hold on; grid on;
    leg{idx_leg} = sprintf('Theo. M=%d',M); 
    idx_leg = idx_leg + 1;
    
    p = semilogy(ebno_db_v, ber_est_v, '-o', 'Linewidth', 1);
    p.MarkerFaceColor = color_c{idx_1};
    p.MarkerEdgeColor = 'k';
    p.Color = color_c{idx_1}; 
    leg{idx_leg} = sprintf('Est. M=%d',M); 
    idx_leg = idx_leg + 1;
        
end

xlabel('EbNo [dB]', 'Interpreter','latex','FontSize', fz);
ylabel('BER', 'Interpreter','latex','FontSize', fz);
legend(leg,'Location','sw','Interpreter','latex','FontSize', fz-2);
grid on; 

tit = ['BER vs EbNo. ',...
        sprintf('BR=%.0f[GBd]', config_s.tx_s.BR/1e9)];
title(tit, 'Interpreter','latex','FontSize', fz);
set(gcf, 'Position', [50 50 500 500],'Color', 'w');
saveas(gcf,[out_dir,sprintf('fig%d.png',idx_fig)]); idx_fig=idx_fig+1;

% SNR Penalty vs M

ber_int = 1e-2;

snr_loss_db_v = zeros(n_M,1);

for idx_1 = 1:n_M

    M = M_v(idx_1);
    ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);
    
    ber_theo_v = ber_theo_m(idx_1,:);
    ber_est_v = ber_est_m(idx_1,:);

    ebno_sim_db = interp1(log10(ber_est_v), ebno_db_v, log10(ber_int));
    ebno_theo_db = interp1(log10(ber_theo_v), ebno_db_v, log10(ber_int));

    snr_loss_db_v(idx_1) =  ebno_sim_db - ebno_theo_db;

end

figure; 
leg = {}; idx_leg = 1;
p = plot(M_v, snr_loss_db_v, '-o', 'Linewidth', 2);
p.MarkerFaceColor = color_c{1};
p.MarkerEdgeColor = 'k';
p.Color = color_c{1}; 
hold on; grid on;

xlabel('M', 'Interpreter','latex','FontSize', fz);
ylab = sprintf('SNR loss [dB] @ BER = %.1e',ber_int);
ylabel(ylab, 'Interpreter','latex','FontSize', fz);
grid on; ylim([-0.1,ceil(max(snr_loss_db_v))]); 

tit = ['SNR loss vs M',sprintf('BR=%.0f[GBd]', config_s.tx_s.BR/1e9)];
title(tit, 'Interpreter','latex','FontSize', fz);
set(gcf, 'Position', [50 50 500 500],'Color', 'w');
saveas(gcf,[out_dir,sprintf('fig%d.png',idx_fig)]); idx_fig=idx_fig+1;
