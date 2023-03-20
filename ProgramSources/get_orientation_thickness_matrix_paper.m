% This script shows the simulations of the HAADF STEM intensity for various
% crystal phases of TiO2 and WO3. For simulation details, see the
% publication.
clear all
close all

figure(100);
set(gcf,'Position',[175,400,650,350])
figure(101);
set(gcf,'Position',[175,400,650,350])

for k_material = 1 : 4 % loop over the four simulated materials
    switch k_material
        % load data
        case 1
            material = 'TiO_2 rutile';
            text=fileread('../RawData/TiO2_rutile.json');
            cl = [1 0 1];
        case 2
            material = 'TiO_2 anatase';
            text=fileread('../RawData/TiO2_anatase.json');
            cl = [1 0 0];
        case 3
            material = 'WO_3 delta';
            text=fileread('../RawData/WO3_delta.json');
            cl = [0.3922 0.8314 0.0745];
        case 4
            material = 'WO_3 gamma';
            text=fileread('../RawData/WO3_gamma.json');
            cl = [0 1 0];
    end
    data = jsondecode(text); 

    HAADF_sensitivity = load('../RawData/HAADF_Spektra_91mm_R50_v2.txt');
    % scale detectorsensitivity in mrad
    HAADF_sensitivity(:,1) = HAADF_sensitivity(:,1)*1000;
    % extend detectorsensitivity to annular range, where it is zero
    HAADF_sensitivity = [0 0; 35.9 0;HAADF_sensitivity;500 0];
    % interpolate experimental detectorsensitivity such that it fits the
    % simulation:
    HAADF_sensititivity_interp = interp1(HAADF_sensitivity(:,1),HAADF_sensitivity(:,2),data.angle*1000);
    % integration factor, because annular ranges in the simulation have
    % linear increasing widths
    int_fac = 2*pi*sin(data.angle).*data.d_theta;
    % combine sensitivity and integration factor
    HAADF_sensititivity_interp = HAADF_sensititivity_interp.*int_fac;
    % repeat sensititivity and integration factor for every simulated
    % thickness
    HAADF_sensititivity_mat = repmat(HAADF_sensititivity_interp,[1,numel(data.thickness),numel(data.orientations)]);
    % calculate orientation-thickness matrix, i.e. sum simulation over angles
    OT_matrix = squeeze(sum(data.annular_HAADF_mean.*HAADF_sensititivity_mat,1));
    
    %average over crystal tilts
    mean_HAADF = mean(OT_matrix,2)';
    %average of log-scaled intensities over crystal tilts
    mean_HAADF_log = mean(-log(1-OT_matrix),2)';
    %average optical density over crystal tilts
    mean_m = mean_HAADF./data.thickness'*1000;
    %average log-scaled optical density over crystal tilts
    mean_m_log = mean_HAADF_log./data.thickness'*1000;
    %same for standard deviations
    std_HAADF = std(OT_matrix,[],2)';
    std_HAADF_log = std(-log(1-OT_matrix),[],2)';
    std_m = std_HAADF./data.thickness'*1000;
    std_m_log = std_HAADF_log./data.thickness'*1000;

    %plotting. Figures 100 and 101 are for the comparison of the materials
    colours = hsv(numel(data.orientations));
    figure(100)
    hold on
    fill([data.thickness(1:end-1)',data.thickness(end-1:-1:1)'],[mean_HAADF(1:end-1)+std_HAADF(1:end-1),mean_HAADF(end-1:-1:1)-std_HAADF(end-1:-1:1)],cl,'EdgeColor','none','FaceAlpha',0.3,'DisplayName','mean \pm standard deviation');
    figure(101)
    hold on
    fill([data.thickness(2:end-1)',data.thickness(end-1:-1:2)'],[mean_m_log(2:end-1)+std_m_log(2:end-1),mean_m_log(end-1:-1:2)-std_m_log(end-1:-1:2)],cl,'EdgeColor','none','FaceAlpha',0.3,'DisplayName','mean \pm standard deviation');
    leg_str{k_material} = material;
    
    figure
    set(gcf,'Position',[130 70 900 675])
    subplot(2,2,1) % simulated HAADF intensity
    fill([data.thickness(1:end-1)',data.thickness(end-1:-1:1)'],[mean_HAADF(1:end-1)+std_HAADF(1:end-1),mean_HAADF(end-1:-1:1)-std_HAADF(end-1:-1:1)],[0 0 0],'EdgeColor','none','FaceAlpha',0.3,'DisplayName','mean \pm standard deviation');
    hold on
    title(['HAADF-STEM intensity I,  ', material])
    xlabel('thickness t [nm]')
    ylabel('[]')
    set(gca,'FontSize',14)
    subplot(2,2,2) % simulated electron optical density
    fill([data.thickness(2:end-1)',data.thickness(end-1:-1:2)'],[mean_HAADF_log(2:end-1)+std_HAADF_log(2:end-1),mean_HAADF_log(end-1:-1:2)-std_HAADF_log(end-1:-1:2)],[0 0 0],'EdgeColor','none','FaceAlpha',0.3,'DisplayName','mean \pm standard deviation');
    hold on
    title(['-log(1-I),  ', material])
    xlabel('thickness t [nm]')
    ylabel('[]')
    set(gca,'FontSize',14)
    subplot(2,2,3) % log-scaled simulated HAADF intensity
    fill([data.thickness(2:end-1)',data.thickness(end-1:-1:2)'],[mean_m(2:end-1)+std_m(2:end-1),mean_m(end-1:-1:2)-std_m(end-1:-1:2)],[0 0 0],'EdgeColor','none','FaceAlpha',0.3,'DisplayName','mean \pm standard deviation');
    hold on
    title(['I/t,  ', material])
    xlabel('thickness t [nm]')
    ylabel('[1/pm]')
    set(gca,'FontSize',14)
    subplot(2,2,4) % log-scaled electron optical density
    fill([data.thickness(2:end-1)',data.thickness(end-1:-1:2)'],[mean_m_log(2:end-1)+std_m_log(2:end-1),mean_m_log(end-1:-1:2)-std_m_log(end-1:-1:2)],[0 0 0],'EdgeColor','none','FaceAlpha',0.3,'DisplayName','mean \pm standard deviation');
    hold on
    title(['R,  ', material])
    xlabel('thickness t [nm]')
    ylabel('log-scaled electron optical density R [1/pm]')
    set(gca,'FontSize',14)
    for k_orientations = 1 : length(data.orientations) % loop over all crystal orientations
        if data.orientations(k_orientations)==2051
            disp_name = '\beta= 20°, \alpha = 51°';
            subplot(2,2,1)
            plot(data.thickness,OT_matrix(:,k_orientations),'b:','LineWidth',1.5,'Color',colours(k_orientations,:),'DisplayName',disp_name)
            subplot(2,2,2)
            plot(data.thickness,-log(1-OT_matrix(:,k_orientations)),'b:','LineWidth',1.5,'Color',colours(k_orientations,:),'DisplayName',disp_name)
            subplot(2,2,3)
            plot(data.thickness,OT_matrix(:,k_orientations)./data.thickness*1000,'b:','LineWidth',1.5,'Color',colours(k_orientations,:),'DisplayName',disp_name)
            subplot(2,2,4)
            plot(data.thickness,-log(1-OT_matrix(:,k_orientations))./data.thickness*1000,'b:','LineWidth',1.5,'Color',colours(k_orientations,:),'DisplayName',disp_name)
        else
            disp_name = ['\beta=',num2str(data.orientations(k_orientations)),'°'];
            subplot(2,2,1)
            plot(data.thickness,OT_matrix(:,k_orientations),'b','Color',colours(k_orientations,:),'DisplayName',disp_name)
            subplot(2,2,2)
            plot(data.thickness,-log(1-OT_matrix(:,k_orientations)),'b','Color',colours(k_orientations,:),'DisplayName',disp_name)
            subplot(2,2,3)
            plot(data.thickness,OT_matrix(:,k_orientations)./data.thickness*1000,'b','Color',colours(k_orientations,:),'DisplayName',disp_name)
            subplot(2,2,4)
            plot(data.thickness,-log(1-OT_matrix(:,k_orientations))./data.thickness*1000,'b','Color',colours(k_orientations,:),'DisplayName',disp_name)
        end
    end
    subplot(2,2,1)
    xlim([0 149])
    subplot(2,2,2)
    xlim([0 149])
    subplot(2,2,3)
    xlim([0 149])
    subplot(2,2,4)
    xlim([0 149])
    legend
end

%% Plot in addition some experimental values for comparison.
load('../RawData/comparison_simulation_med_values.mat')
darkgreen=[0 153 53]./256;
% finalize comparative plots
figure(100)
set(gca,'FontSize',14)
xlabel('thickness t [nm]')

ylabel('HAADF intensity I')
xlim([0 149])
legend(leg_str)
axis tight
figure(101)
hold on
plot(radius_liste(element_liste==1)*2,y_werte_part_med_liste(element_liste==1),'wo','MarkerFaceColor','w','MarkerSize',10);
leg_str{5}='';
plot(radius_liste(element_liste==1)*2,y_werte_part_med_liste(element_liste==1),'g+','MarkerEdgeColor',darkgreen);
leg_str{6}='exp. WO_3 PP';
plot(radius_liste(element_liste==2)*2,y_werte_part_med_liste(element_liste==2),'wo','MarkerFaceColor','w','MarkerSize',10)
leg_str{7}='';
plot(radius_liste(element_liste==2)*2,y_werte_part_med_liste(element_liste==2),'r+')
leg_str{8}='exp. TiO_2 PP';
set(gca,'FontSize',14)
xlabel('thickness t [nm], diameter [nm]')
ylabel('R [pm^{-1}]')
legend(leg_str)
axis tight
ylim([0 2.4])
xlim([0 40])