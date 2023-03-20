%This script visualizes the threshold calculated in 'histograms_paper'. You
%can change the variables 'max_radius_fit_liste' and 'n_components',
%depending on which fitfunctions should be used. However they have to be
%created first by the script 'histograms_paper.m'
%It saves values of discrepancy to EDXS for calculation of an average
%discrepancy by appending these values to the .mat-file of the utilized fit
%functions.

close all
clear all
max_radius_fit_liste=0.4%[0.1 0.2 0.4 0.6 1];%which fitfunctions should be used
n_components=3%which fitfunctions should be used
show_plots=1%change this to 0, if you don't want additional plots

darkgreen=[0 153 53]./256;
colormapbg = {[0 153 53]./256,[1 0 0],[226 0 116],[0 1 1]};

[intensitiesfile_multi,intensitiespath] = uigetfile('*intensities.mat','MultiSelect','on','Select intensities .mat');

if iscell(intensitiesfile_multi)
    anzahl_files=size(intensitiesfile_multi,2);
else
    anzahl_files=1;
end
for kkk=1:length(max_radius_fit_liste);
    max_radius_fit=max_radius_fit_liste(kkk);
    
    zeit_liste=cell(anzahl_files,1);
    anzahl_pp_liste=zeros(anzahl_files,1);
    
    for jj=1:anzahl_files
        if iscell(intensitiesfile_multi)
            intensitiesfile=char(intensitiesfile_multi(jj));
        else
            intensitiesfile=char(intensitiesfile_multi);
        end
        [matchstr, splitstr] = regexp(intensitiesfile, '_', 'match','split');
        zeit=splitstr(1);
        radius=splitstr(2);
        if strcmp(zeit,'')==1
            zeit=intensitiesfile(1:end-20);
            radius=intensitiesfile(end-18:end-16);
        end
        zeit_liste{jj}=char(zeit);
        file_comp=sprintf('fit_functions_%0.0dKomp.mat',n_components);
        fitpath=intensitiespath;
        fitfile=char(strcat(zeit,'_',num2str(max_radius_fit),'_',file_comp));
        load([fitpath,fitfile]);
        bincenters=xout;
        x_axis=x_achse;
        radius_med=max_radius_fit;
        file1=char(strcat(intensitiespath,zeit,'_','fit',num2str(max_radius_fit),'_med',num2str(radius_med)));
        load(char(strcat(intensitiespath,zeit,'_PARTICLE_DATA.mat')))
        load([intensitiespath,intensitiesfile]);
        
        %Calculations
        intersection=i_inters;
        threshold=x_inters;
        y_werte=-log(1-int_ges)./(sehne_ges.*pixsizex)*1000;
        sehne_med_pp=zeros(1,all_particles.number);
        int_log_med_pp=zeros(1,all_particles.number);
        int_log=-log(1-int_ges);
        for ii=1:all_particles.number
            sehne_med_pp(ii)=median(sehne_ges(part_nummer_ges==ii))*pixsizex;%mean
            int_log_med_pp(ii)=median(int_log(part_nummer_ges==ii));%mean
        end
        norm_bars(:,1)=norm_Ti;
        norm_bars(:,2)=norm_W;
        anzahl_pp=max(part_nummer_ges);
        anzahl_pp_liste(jj)=anzahl_pp;
        
        img_el_med=zeros(size(img_single));
        pp_element_med=zeros(size(all_particles.element));
        y_werte_part_med=zeros(size(all_particles.element));
        pp_nummer_nA=[];
        for ii=1:anzahl_pp; 
            clear y_werte_pp pp_aboveth y_werte_pp_rad
            y_werte_pp=y_werte((part_nummer_ges==ii));
            %only pixel values from the inner regions are considered for
            %calculation the median value, pixelvalues from overlapping
            %region were never saved in 'y_werte'
            Lia = ismember(find(part_nummer_ges==ii),find(dist_durch_radius_ges<=radius_med));
            if nnz(Lia)==0;
                fprintf('no pixels left of pp number:%d',ii)
                pp_nummer_nA=[pp_nummer_nA ii];
            end
            y_werte_pp_rad=y_werte_pp(Lia==1);
            y_werte_part_med(ii)=median(y_werte_pp_rad);
            
            if y_werte_part_med(ii)<=threshold%Titan
                pp_element_med(ii)=2;
            elseif y_werte_part_med(ii)>threshold%Tungsten
                pp_element_med(ii)=1;
            end
            koordsX_pp=koordsX_ges(part_nummer_ges==ii);
            koordsY_pp=koordsY_ges(part_nummer_ges==ii);
            for mm=1:length(koordsY_pp)
                img_el_med(koordsY_pp(mm),koordsX_pp(mm))=pp_element_med(ii);
            end
        end
        unterschied_elemente_med=all_particles.element-pp_element_med;
        unterschied_anzahl_med=nnz(unterschied_elemente_med(pp_element_med~=0));
        unterschied_anteil_med=nnz(unterschied_elemente_med(pp_element_med~=0))/length(unterschied_elemente_med(pp_element_med~=0));
        img_el_med(img_single==0)=0;
        
        %% save discrepancy values for a summary and comparison to simulations
        save([fitpath,fitfile],'unterschied_anteil_med','anzahl_pp','y_werte_part_med','pp_nummer_nA','unterschied_anzahl_med','radius_med','-append')
        
        
        %% Plot of median values of each PP versus Diameter with the calculated threshold
        if show_plots==1
            figure;
            plot(all_particles.radius(all_particles.element==1)*2*all_particles.px2nm,y_werte_part_med(all_particles.element==1),'+','Color',darkgreen)
            hold on
            plot(all_particles.radius(all_particles.element==2)*2*all_particles.px2nm,y_werte_part_med(all_particles.element==2),'r+')
            ylabel('electron optical density R [pm^{-1}]','fontsize',12)
            xlabel('thickness in nm','FontSize',14)
            xlimit=get(gca,'xlim');
            x_line=0:0.1:xlimit(2);
            y_line=threshold*ones(size(x_line));
            plot(x_line,y_line,'k--')
            legend('WO_3','TiO_2','Threshold')
            title('median value of each PP','FontSize',14)
            set(gcf, 'Color', 'w');
            set(gca,'FontSize',14)
            hold off
        end
        %% EDX-like map of identified PPs
        load('colormap_k_dg_r.mat')
        legstr_box=sprintf('discrepancy to EDX:%0.0f%%',unterschied_anteil_med*100);
        bereichx=(length(img_el_med)-1)*pixsizex;
        bereichy=(length(img_el_med)-1)*pixsizey;
        figure;
        hold on
        imagesc([0,bereichx],[0,bereichy],img_el_med)
        colormap(custom_cmap)
        xlabel('x in nm','FontSize',14)
        ylabel('y in nm','FontSize',14)
        axis on
        axis image
        set(gca,'FontSize',14)
        numbers=0;
        pp_nummer_med=[];
        for ii=1:all_particles.number
            center_coord = all_particles.center_coord(ii,:).*all_particles.px2nm;
            radius = all_particles.radius(ii).*all_particles.px2nm;
            index1 = all_particles.index(ii);
            colortouse =   colormapbg{all_particles.element(ii)};
            if all_particles.element(ii)==pp_element_med(ii)
                hl(ii)=plot(center_coord(1),center_coord(2),'Color',colortouse,'LineWidth',1);
                set(hl(ii),'Visible','off')
            elseif pp_element_med(ii)==0
                hl(ii)=plot(center_coord(1),center_coord(2),'w','LineWidth',1);
                set(hl(ii),'Visible','on')
            elseif all_particles.element(ii)~=pp_element_med(ii) && pp_element_med(ii)~=0
                hl(ii)=plot(center_coord(1),center_coord(2),'y','LineWidth',1);
                pp_nummer_med=[pp_nummer_med ii];
            end
            x1=radius*sind([0:5:360])+center_coord(1);
            y1=radius*cosd([0:5:360])+center_coord(2);
            set(hl(ii),'XData',x1,'YData',y1);
        end
        annotation('textbox', [.74 .75 .06 .05], 'String', 'TiO_2','EdgeColor','r','FontSize',14,...
            'Linewidth',1,'BackgroundColor','r','Color','w','Margin',0,'HorizontalAlignment','center')
        annotation('textbox', [.74 .85 .06 .05], 'String', 'WO_3','EdgeColor',[0 153 53]./256,'FontSize',14,...
            'Linewidth',1,'BackgroundColor',[0 153 53]./256,'Color','w','Margin',0,'HorizontalAlignment','center')
        annotation('textbox', [.23 .85 .4 .06],  'String', legstr_box,'EdgeColor','y','FontSize',14,...
            'Linewidth',2,'BackgroundColor','none','Color','w','HorizontalAlignment','center','VerticalAlignment','top')
        set(gca,'Ydir','reverse')
        set(gcf, 'Color', 'w');
        title('calculated elemental map')
        hold off
        
        %% STEM image with misidentified PPs
        if show_plots==1
            img=myimage;
            bereich=[1:size(img,1)].*all_particles.px2nm;
            figure;
            axis image
            imagesc(bereich, bereich,img);
            hold on
            xlabel('x in nm','FontSize',16)
            ylabel('y in nm','FontSize',16)
            axis on
            set(gca,'FontSize',16)
            hold on
            if all_particles.number ~=0
                gcf
                hold on
                for jjj=1:length(pp_nummer_med);
                    ii=pp_nummer_med(jjj);
                    fortschritt = 'Partikel %4.0f von %4.0f \n';
                    fprintf(fortschritt,ii,all_particles.number)
                    center_coord = all_particles.center_coord(ii,:).*all_particles.px2nm;
                    radius = all_particles.radius(ii).*all_particles.px2nm;
                    index1 = all_particles.index(ii);
                    colortouse =   colormapbg{all_particles.element(ii)};
                    hl(ii)=plot(center_coord(1),center_coord(2),'y','LineWidth',2);
                    hold on
                    x1=radius*sind([0:5:360])+center_coord(1);
                    y1=radius*cosd([0:5:360])+center_coord(2);
                    set(hl(ii),'XData',x1,'YData',y1);
                end
                for jjj=1:length(pp_nummer_nA);
                    ii=pp_nummer_nA(jjj);
                    fortschritt = 'Partikel %4.0f von %4.0f \n';
                    fprintf(fortschritt,ii,all_particles.number)
                    center_coord = all_particles.center_coord(ii,:).*all_particles.px2nm;
                    radius = all_particles.radius(ii).*all_particles.px2nm;
                    index1 = all_particles.index(ii);
                    colortouse =   colormapbg{all_particles.element(ii)};
                    hl(ii)=plot(center_coord(1),center_coord(2),'w','LineWidth',2);
                    hold on
                    x1=radius*sind([0:5:360])+center_coord(1);
                    y1=radius*cosd([0:5:360])+center_coord(2);
                    set(hl(ii),'XData',x1,'YData',y1);
                end
            end
            drawnow
            axis image
            hold off
        end
        %% normalized image with PP-markings
        if show_plots==1
            draw_all_particles_function(all_particles,myimage,'gray')
        end
        %% thickness-map
        if show_plots==1
            dicke_img=zeros(size(myimage));
            for ii=1:length(koordsX_ges)
                dicke_img(koordsY_ges(ii),koordsX_ges(ii))=sehne_ges(ii).*pixsizex;
            end
            figure;
            imagesc([0,bereichx],[0,bereichy],dicke_img)
            hold on
            xlabel('x in nm','FontSize',16)
            ylabel('y in nm','FontSize',16)
            colorbar
            set(gca,'FontSize',16)
            title('thickness in nm')
            hold off
        end
    end
end