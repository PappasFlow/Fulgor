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

n_stpsz = length(stpsz_v);
n_ber = length(theo_ber_v);

ber_est_m = zeros(n_stpsz,n_ber);
ber_theo_m = zeros(n_stpsz,n_ber);
ebno_db_m = zeros(n_stpsz,n_ber);
for i = 1:n_stpsz
    
    stpsz = stpsz_v(i);
    
    name = sprintf('STEP%d',stpsz*1e3);
    file = [out_dir, 'out_',name,'.mat'];
    load(file);

    for j = 1:n_ber

        ber_est_m(i,j) = out_c{j}.ber_est;
        ber_theo_m(i,j) = out_c{j}.ber_theo;

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
    "#DC143C"  % Crimson (deep red)
    "#00CED1"  % Dark Turquoise
    "#FF8C00"  % Dark Orange
    "#9932CC"  % Dark Orchid
    "#ADFF2F"  % Green Yellow
    "#20B2AA"  % Light Sea Green
    "#FF4500"  % Orange Red
    "#8B0000"  % Dark Red
    "#4682B4"  % Steel Blue
    "#DA70D6"  % Orchid
    "#7CFC00"  % Lawn Green
    "#FF69B4"  % Hot Pink
    "#00FF7F"  % Spring Green
];



% BER vs EbNo: Before Filtering
figure; 
leg = {}; idx_leg = 1;
ebno_db_v = get_ebno_from_theo_ber(theo_ber_v,M);
for i = 1:n_stpsz
    
    stpsz = stpsz_v(i);
    ber_theo_v = ber_theo_m(1,:);
    p = semilogy(ebno_db_v, ber_theo_v, '--', 'Linewidth', 1.5);
    p.Color = color_c(idx_leg); 
    hold on; grid on;
    leg{idx_leg} = sprintf('Teorica Step Size=%d Hz',stpsz); 
    idx_leg = idx_leg + 1;

    ber_est_v = ber_est_m(i,:);
    p = semilogy(ebno_db_v, ber_est_v, '-o', 'Linewidth', 1);
    p.MarkerFaceColor = color_c{idx_leg};
    p.MarkerEdgeColor = 'k';
    p.Color = color_c{idx_leg}; 
    leg{idx_leg} = sprintf('Estimada Step Size=%d Hz',stpsz); 
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



