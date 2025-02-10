clear; close all;

%% Output directory

out_dir = mfilename('fullpath');
out_dir = out_dir(1:end-length(mfilename));
out_dir = [out_dir, 'out/'];

if ~exist(out_dir,'dir')
    proc_file = mfilename
    run_file = [proc_file(1:end-4), 'run']
    error('Output directory not found. Run %s before running %s.', run_file, proc_file)
end

%% Read data

file = [out_dir, 'cfg.mat'];
load(file);

n_BW = length(BW_v);
n_ber = length(theo_ber_v);

ber_est_m = zeros(n_BW*2,n_ber);
ber_theo_m = zeros(n_BW*2,n_ber);
ebno_db_m = zeros(n_BW*2,n_ber);
for i_mode = 0:1 
    for i = 1:n_BW
    
        BW = BW_v(i);
    
        name = sprintf('M%dBW%d',i_mode, BW/1e9);
        file = [out_dir, 'out_',name,'.mat'];
        load(file);

        for j = 1:n_ber

            ber_est_m(i+n_BW*i_mode,j) = out_c{j}.ber_est;
            ber_theo_m(i+n_BW*i_mode,j) = out_c{j}.ber_theo;

        end
    end
end
%% Plots
M = 4; 
idx_fig = 1;
fz = 15;
color_c = [
    "#FF6347"  % Tomato (vibrant red-orange)
    "#3CB371"  % Medium Sea Green
    "#1E90FF"  % Dodger Blue
    "#FFD700"  % Gold
    "#8A2BE2"  % Blue Violet
    "#FF1493"  % Deep Pink
    "#32CD32"  % Lime Green
];


% BER vs EbNo: Before Filtering
figure; 
leg = {}; idx_leg = 1;
ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);  
ber_theo_v = ber_theo_m(1,:);
p = semilogy(ebno_db_v, ber_theo_v, '--', 'Linewidth', 1.5);
    p.Color = color_c(1); 
    hold on; grid on;
    leg{idx_leg} = sprintf('Teorica'); 
    idx_leg = idx_leg + 1;
for i = 1:n_BW
    
    BW = BW_v(i);

    ber_est_v = ber_est_m(i,:);
    p = semilogy(ebno_db_v, ber_est_v, '-o', 'Linewidth', 1);
    p.MarkerFaceColor = color_c{i+1};
    p.MarkerEdgeColor = 'k';
    p.Color = color_c{i+1}; 
    leg{idx_leg} = sprintf('Estimada BW=%d GHz',BW/1e9); 
    idx_leg = idx_leg + 1;
        
end

xlabel('EbNo [dB]', 'Interpreter','latex','FontSize', fz);
ylabel('BER', 'Interpreter','latex','FontSize', fz);
legend(leg,'Location','sw','Interpreter','latex','FontSize', fz-2);
grid on; 

tit = 'BER vs EbNo. w/o Noise filtering ';
title(tit, 'Interpreter','latex','FontSize', fz);
set(gcf, 'Position', [50 50 500 500],'Color', 'w');
saveas(gcf,[out_dir,sprintf('fig%d.png',idx_fig)]); 
idx_fig=idx_fig+1;


% BER vs EbNo: after Filtering
figure; 
leg = {}; idx_leg = 1;
ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);  
ber_theo_v = ber_theo_m(1,:);
p = semilogy(ebno_db_v, ber_theo_v, '--', 'Linewidth', 1.5);
    p.Color = color_c(1); 
    hold on; grid on;
    leg{idx_leg} = sprintf('Teorica'); 
    idx_leg = idx_leg + 1;
for i = 1:n_BW
    
    BW = BW_v(i);

    ber_est_v = ber_est_m(i + n_BW,:);
    p = semilogy(ebno_db_v, ber_est_v, '-o', 'Linewidth', 1);
    p.MarkerFaceColor = color_c{i+1};
    p.MarkerEdgeColor = 'k';
    p.Color = color_c{i+1}; 
    leg{idx_leg} = sprintf('Estimada BW=%d GHz',BW/1e9); 
    idx_leg = idx_leg + 1;
        
end

xlabel('EbNo [dB]', 'Interpreter','latex','FontSize', fz);
ylabel('BER', 'Interpreter','latex','FontSize', fz);
legend(leg,'Location','sw','Interpreter','latex','FontSize', fz-2);
grid on; 

tit = 'BER vs EbNo. w/ Noise filtering ';
title(tit, 'Interpreter','latex','FontSize', fz);
set(gcf, 'Position', [50 50 500 500],'Color', 'w');
saveas(gcf,[out_dir,sprintf('fig%d.png',idx_fig)]); 
idx_fig=idx_fig+1;


% SNR Penalty vs M

ber_int = 1e-2;

snr_loss_db_f_v = zeros(n_BW,1);
snr_loss_db_nf_v = zeros(n_BW,1);

for idx_1 = 1:n_BW

    BW = BW_v(idx_1);
    ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);
    
    ber_theo_v = ber_theo_m(idx_1,:);
    ber_est_v = ber_est_m(idx_1,:);

    ebno_sim_db = interp1(log10(ber_est_v), ebno_db_v, log10(ber_int));
    ebno_theo_db = interp1(log10(ber_theo_v), ebno_db_v, log10(ber_int));

    snr_loss_db_nf_v(idx_1) =  ebno_sim_db - ebno_theo_db;

end

for idx_1 = 1:n_BW

    BW = BW_v(idx_1);
    ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);
    
    ber_theo_v = ber_theo_m(idx_1 + n_BW,:);
    ber_est_v = ber_est_m(idx_1 + n_BW,:);

    ebno_sim_db = interp1(log10(ber_est_v), ebno_db_v, log10(ber_int));
    ebno_theo_db = interp1(log10(ber_theo_v), ebno_db_v, log10(ber_int));

    snr_loss_db_f_v(idx_1) =  ebno_sim_db - ebno_theo_db;

end

figure; 
leg = {}; idx_leg = 1;
p = plot(BW_v /1e9, snr_loss_db_nf_v, '-o', 'Linewidth', 2);
p.MarkerFaceColor = color_c{1};
p.MarkerEdgeColor = 'k';
p.Color = color_c{1}; 
leg{idx_leg} = sprintf('without Noise Filtering'); 
hold on; grid on;
idx_leg = idx_leg+1;
p = plot(BW_v /1e9, snr_loss_db_f_v, '-o', 'Linewidth', 2);
p.MarkerFaceColor = color_c{2};
p.MarkerEdgeColor = 'k';
p.Color = color_c{2}; 
leg{idx_leg} = sprintf('with Noise Filtering'); 
hold on; grid on;

xlabel('Bandwidth [GHz]', 'Interpreter','latex','FontSize', fz);
ylab = sprintf('SNR loss [dB] @ BER = %.1e',ber_int);
ylabel(ylab, 'Interpreter','latex','FontSize', fz);
ylim([-0.1,ceil(max(snr_loss_db_nf_v))]); 
legend(leg,'Location','sw','Interpreter','latex','FontSize', fz-2);

tit = ['SNR loss vs Bandwidth'];
title(tit, 'Interpreter','latex','FontSize', fz);
set(gcf, 'Position', [50 50 500 500],'Color', 'w');
saveas(gcf,[out_dir,sprintf('fig%d.png',idx_fig)]); idx_fig=idx_fig+1;

