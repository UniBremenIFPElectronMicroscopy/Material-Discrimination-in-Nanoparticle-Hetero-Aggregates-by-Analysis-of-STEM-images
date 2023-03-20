% This script creates summarizing plots and saves median values for the comparison to
% simulations in 'comparison_simulation_med_values.mat'. 
% You can change the variables 'radius' and 'n_components',
% depending on the fit functions, you want to use.

clear all
close all
radius=0.4 %can be changed, needs corresponding fit functions
n_components=3 %can be changed, needs corresponding fit functions

str_temp=char(strcat('*',num2str(radius),sprintf('_fit_functions_%0.0dKomp.mat',n_components)))
[fitfile_multi,fitpath] = uigetfile(str_temp,'MultiSelect','on','Select fitfile.mat');

if iscell(fitfile_multi)
    anzahl_files=size(fitfile_multi,2);
else
    anzahl_files=1;
end

zeit_liste=cell(anzahl_files,1);
anzahl_pp_liste=zeros(anzahl_files,1);
unterschied_anteil_med_liste=zeros(anzahl_files,1);
unterschied_anzahl_med_liste=zeros(anzahl_files,1);
anzahl_nA_liste=zeros(anzahl_files,1);
normalisiert_liste=zeros(anzahl_files,1);
y_werte_part_med_liste=[];
radius_liste=[];
element_liste=[];
for jj=1:anzahl_files
    
    if iscell(fitfile_multi)
        fitfile=char(fitfile_multi(jj));
    else
        fitfile=char(fitfile_multi);
    end
    load([fitpath,fitfile]);
    [matchstr, splitstr] = regexp(fitfile, '_', 'match','split');
    
    zeit=splitstr(1);
    zeit_liste{jj}=char(zeit);
    anzahl_pp_liste(jj)=anzahl_pp;
    unterschied_anteil_med_liste(jj)=unterschied_anteil_med;
    unterschied_anzahl_med_liste(jj)=unterschied_anzahl_med;
    anzahl_nA_liste(jj)= length(pp_nummer_nA);
    if nnz(strcmp(zeit,{'14.45.39';'14.49.38';'14.58.24';'15.19.34';'15.35.28';'15.38.49';'15.44.19'}))%only these images were normalized for a comparison to simulations
        y_werte_part_med_liste=[y_werte_part_med_liste; y_werte_part_med];
        load(char(strcat(fitpath,zeit,'_PARTICLE_DATA.mat')));
        radius_liste=[radius_liste; all_particles.radius.*all_particles.px2nm];
        element_liste=[element_liste; all_particles.element];
        fprintf('y_werte_anzahl:%d; anzahl_pp:%d\n',length(y_werte_part_med),length(all_particles.radius))
        normalisiert_liste(jj)=1;
    else
        normalisiert_liste(jj)=0;
    end
    
end
save([fitpath,'comparison_simulation_med_values.mat'],'y_werte_part_med_liste','anzahl_pp_liste','unterschied_anteil_med_liste','zeit_liste','radius_liste','element_liste')
%% Average discrepancy values

avg_med=sum(unterschied_anzahl_med_liste)/sum(anzahl_pp_liste)
avg_nA=sum(anzahl_nA_liste)/sum(anzahl_pp_liste)

%%
figure;
plot(anzahl_pp_liste(normalisiert_liste==0),unterschied_anteil_med_liste(normalisiert_liste==0)*100,'bx','Markersize',18)
hold on
plot(anzahl_pp_liste(normalisiert_liste==1),unterschied_anteil_med_liste(normalisiert_liste==1)*100,'rx','Markersize',18)
xlabel('number of primary particles','FontSize',12)
ylabel('discrepancy to EDXS in %','FontSize',12)
set(gcf, 'Color', 'w');
set(gca,'FontSize',12)
filename='summary_discrepancy'
hold off
%saveas(gcf,char(strcat(filename,'.fig')),'fig')
