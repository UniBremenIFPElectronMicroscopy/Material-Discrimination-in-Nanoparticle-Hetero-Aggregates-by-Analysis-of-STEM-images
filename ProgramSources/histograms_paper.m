% This script shows histograms and calculates fit functions of multiple
% images of aggregates. It needs an 'intensities.mat'-file as created by
% the script 'intensities_paper.m'.
% You can change the variable 'show_plots' to 0, if you are overwhelmed by
% plots.
% You can change the variable 'radii' to change the maximum
% distance of pixels to center of a PP, which are to be examined. This is a
% ratio to the radius of the PP. 0.4 means only pixels with a maximum
% distance of 0.4*radius of the particle, they belong to, are considered for
% the histogram and therefore calculation of a fit function. 
% You can also
% change the variable 'n_components', which is the number of components for 
% the Gaussian mixture model, but for more components, the pairing of material to
% components might not work reliably.
% The resulting fit functions and other variables are saved in mat-file, 
% named like a timestamp followed by the radius, which you have chosen, and "_fit_functions" and followed by the number of components, you have chosen, 
% e.g. "11.47.17_0.4_fit_functions_3Komp.mat".


%close all
clear all
show_plots=1;%can be changed to 0
radii=0.4%[0.1 0.2 0.4 0.6 1];
n_components=3;%number of components for the Gaussian mixture model

[intensitiesfile_multi,intensitiespath] = uigetfile('*intensities.mat','MultiSelect','on','Select intensities .mat');

if iscell(intensitiesfile_multi)
    anzahl_files=size(intensitiesfile_multi,2);
else
    anzahl_files=1;
end

for iii=1:anzahl_files
    clearvars -except anzahl_files intensitiesfile_multi intensitiespath iii show_plots radii n_components
    if iscell(intensitiesfile_multi)
        intensitiesfile=char(intensitiesfile_multi(iii));
    else
        intensitiesfile=char(intensitiesfile_multi);
    end
    load([intensitiespath,intensitiesfile]);
    [matchstr, splitstr] = regexp(intensitiesfile, '_', 'match','split');
    zeit=splitstr(1);
    if strcmp(zeit,'')==1
        zeit=intensitiesfile(1:end-20);
    end

    forestgreen=[0.13 0.54 0.13];
    colormap_comp={'r--','b--','g-','m-','c-','g--','r'};
    for ii=1:length(radii);
        max_radius=radii(ii);
        radius_str=num2str(max_radius);
        anzahl_komponenten=n_components;
        
        %Some images were not normalized correctly, so they have a different data-range
        if strcmp(zeit,'14.51.30')
            x_end=30;
            x_start=0;
            inters_interv_min=9;
            inters_interv_max=12;
            limit_fit=20;
        elseif strcmp(zeit,'15.10.27')
            x_end=5;
            x_start=0;
            inters_interv_min=0.8;
            inters_interv_max=2;
            limit_fit=3;
        elseif strcmp(zeit,'15.48.25')
            x_end=4;
            x_start=0;
            inters_interv_min=0.6;
            inters_interv_max=1.2;
            limit_fit=3;
        elseif strcmp(zeit,'16.33.25 20nm')
            x_end=4;
            x_start=-1;
            inters_interv_min=0.2;
            inters_interv_max=0.8;
            limit_fit=2;
        elseif nnz(strcmp(zeit,{'11.47.17';'12.05.22';'12.15.31';'12.28.59';'12.55.35'}))
            x_end=4;
            x_start=-0.5;
            inters_interv_min=0;
            inters_interv_max=0.7;
            limit_fit=2;
        else
            x_end=4;
            x_start=-0.5;
            inters_interv_min=0.2;
            inters_interv_max=1;
            limit_fit=2;
        end
        
        file1=strcat(intensitiespath,zeit,'_',radius_str,'_');
        title_str={' '};
        num_bins=100;
        
        %Calculations of R-values, separation into W and Ti
        int_log=-log(1-int_ges);
        sehne_nm=sehne_ges.*pixsizex;
        Steigung=int_log./sehne_nm.*1000;
        Steigung=Steigung';
        
        Steigung_R=Steigung(dist_durch_radius_ges<=max_radius);
        Lia1 = ismember(find(ind_Ti_liste==1),find(dist_durch_radius_ges<=max_radius));
        Steigung_temp=Steigung(ind_Ti_liste==1);
        Steigung_Ti=Steigung_temp(Lia1==1);
        Lia2 = ismember(find(ind_W_liste==1),find(dist_durch_radius_ges<=max_radius));
        Steigung_temp=Steigung(ind_W_liste==1);
        Steigung_W=Steigung_temp(Lia2==1);
        
        % Setting up histograms and normalization
        x_width=(x_end-x_start)/num_bins;
        x_bins=[x_start:x_width:x_end]';
        x_achse=[x_start:x_width/10:x_end]';
        
        [hist_sum,xout]=hist(Steigung_R,x_bins);
        [hist_Ti,xout]=hist(Steigung_Ti,x_bins);
        [hist_W,xout]=hist(Steigung_W,x_bins);
        normierung=1/(x_width*sum(hist_sum));
        hist_Ti_norm=1/(x_width*sum(hist_Ti)).*hist_Ti;
        hist_W_norm=1/(x_width*sum(hist_W)).*hist_W;
        normierung_W=sum(hist_W)./(sum(hist_W)+sum(hist_Ti));
        normierung_Ti=sum(hist_Ti)./(sum(hist_W)+sum(hist_Ti));
        norm_Ti=hist_Ti_norm*normierung_Ti;
        norm_W=hist_W_norm*normierung_W;
        norm_sum=hist_sum*normierung;
        bar_stacked=[norm_Ti;norm_W];
        
        
        %Fit by GMdistribution
        options = statset('Display','final','MaxIter',1000);
        n_components=3 %can also be vector
        gmm_sum = zeros(length(n_components),length(x_achse));
        for kk=1:length(n_components)
            rep=10;
            
            obj = gmdistribution.fit(Steigung_R(Steigung_R<limit_fit),n_components(kk),'Options',options,'Replicates',rep);
            BIC(kk)=obj.BIC;
            AIC(kk)=obj.AIC;
            
            gmm_sum(kk,:) = pdf(obj,x_achse);
            gmm=zeros(n_components,length(x_achse));
            for mm=1:n_components(kk)
                gmm(mm,:)=obj.PComponents(mm).*normpdf(x_achse,obj.mu(mm),sqrt(obj.Sigma(mm)));
            end
            
            % Pairing of components to material
            intervall_inters1=min(find(x_achse>inters_interv_min));
            intervall_inters2=max(find(x_achse<inters_interv_max));
            mat_ind_th=(inters_interv_min+inters_interv_max)/2;
            ind_w=find(obj.mu>mat_ind_th)
            ind_ti=find(obj.mu<mat_ind_th)
            if isempty(ind_w)
                [~,ind_w]=max(obj.mu);
                ind_ti=ind_ti(ind_ti~=ind_w);
            elseif isempty(ind_ti)
                [~,ind_ti]=min(obj.mu);
                ind_w=ind_w(ind_w~=ind_ti);
            end
            
            %calculation of the threshold by calculation of intersections
            x_inters_matrix=zeros(length(ind_ti),length(ind_w));
            y_inters1_matrix=zeros(length(ind_ti),length(ind_w));
            y_inters2_matrix=zeros(length(ind_ti),length(ind_w));
            
            for mm=1:length(ind_ti)
                for nn=1:length(ind_w)
                    [min_diff, ind_min]=min(abs(gmm(ind_ti(mm),intervall_inters1:intervall_inters2)-gmm(ind_w(nn),intervall_inters1:intervall_inters2)));
                    inters_ind(ind_ti(mm),ind_w(nn))=intervall_inters1+ind_min;
                    inters_temp=inters_ind(ind_ti(mm),ind_w(nn));
                    x_inters_matrix(ind_ti(mm),ind_w(nn))=x_achse(inters_temp);
                    y_inters1_matrix(ind_ti(mm),ind_w(nn))=gmm(ind_ti(mm),inters_temp);
                    y_inters2_matrix(ind_ti(mm),ind_w(nn))=gmm(ind_w(nn),inters_temp);
                end
                
            end
            if size(y_inters2_matrix,1)>1
                [max_val,ind_m1]=max(y_inters1_matrix);
                [max_val,ind_m2]=max(max(y_inters1_matrix));
                ind_m1=ind_m1(ind_m2);
            elseif size(y_inters2_matrix,1)==1
                ind_m1=1;
                [max_val,ind_m2]=max(y_inters1_matrix);
            end
            
            x_inters=x_inters_matrix(ind_m1,ind_m2);
            y_inters=(max(max(y_inters1_matrix))+max(max(y_inters2_matrix)))/2;
            i_inters=inters_ind(ind_m1,ind_m2);
            
            area_uberlapp=trapz(x_achse,[gmm(ind_m1,x_achse<=x_inters)';gmm(ind_m2,x_achse>x_inters)']);
            file2=sprintf('fit_functions_%0.0dKomp.mat',n_components(kk));
            save(char(strcat(file1,file2)),'obj','gmm_sum','gmm','x_achse','x_inters','i_inters','y_inters','area_uberlapp','rep','limit_fit','bar_stacked','norm_Ti','norm_W','xout');
            
            % Plots
            if show_plots==1;
                subplot(2,4,kk)
                xlim([x_start x_end])
                set(gcf, 'Position',[100 100 1600 800])
                hold on
                hArray=bar(xout,bar_stacked','stacked');
                set(hArray(1),'LineWidth',2,'FaceColor','r','EdgeColor','r');
                set(hArray(2),'LineWidth',2,'FaceColor',forestgreen,'EdgeColor',forestgreen);
                plot(x_achse,gmm_sum(kk,:),'--','Linewidth',2,'Color','k')
                xlabel('electron optical density R [pm^{-1}]','fontsize',12)
                ylabel('Probability density [pm]','fontsize',12)
                title_komplett=sprintf('%0.0d components',n_components(kk));
                title(title_komplett,'Fontsize',12)
                set(gcf, 'Color', 'w');
                set(gca,'FontSize',12)
                clear hArray
                
                subplot(2,4,kk+4)
                hold on
                xlim([x_start x_end])
                plot(x_inters,y_inters,'k+','MarkerSize',10,'Linewidth',2)
                for mm=1:n_components(kk)
                    plot(x_achse,gmm(mm,:),char(colormap_comp(mm)))
                end
                lgd=legend(sprintf('threshold: %0.2f',x_inters));
                set(lgd,'fontsize',12)
                legend('boxoff')
                xlabel('electron optical density R [pm^{-1}]','fontsize',12)
                ylabel('Probability density [pm]','fontsize',12)
                set(gcf, 'Color', 'w');
                xlim([x_start x_end])
                hold off
                set(gca,'FontSize',12)
                file2='uebersicht_komp';
                filename=strcat(file1,file2);
                %saveas(gcf,char(strcat(filename,'.fig')),'fig')
            end
        end
        hold off
        
        
        %%
        figure;
        hold on
        xlim([x_start x_end])
        hArray=bar(xout,bar_stacked','stacked');
        set(hArray(1),'LineWidth',2,'FaceColor','r','EdgeColor','r');
        set(hArray(2),'LineWidth',2,'FaceColor',forestgreen,'EdgeColor',forestgreen);
        plot(x_achse,gmm_sum,'--','Linewidth',2,'Color','k')
        xlabel('electron optical density R [pm^{-1}]','fontsize',12)
        ylabel('Probability density [pm]','fontsize',12)
        lgd=legend('TiO_2','WO_3','GMM-Fit','Fontsize',12);
        set(lgd, 'Box', 'off')
        axis tight
        title_komplett=strcat('stacked histogram',title_str,'with fit of ',{' '},zeit,{' '},'with a_{max}=',radius_str,'r');
        title(title_komplett,'Fontsize',12)
        set(gcf, 'Color', 'w');
        xlim([x_start x_end])
        hold off
        file2='Hist_stacked_fit';
        filename=strcat(file1,file2);
        %saveas(gcf,char(strcat(filename,'.fig')),'fig')
        if show_plots==1;
            figure;
            hold on
            xlim([x_start x_end])
            a=plot(x_inters,y_inters,'*','Linewidth',2,'MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',10,'Linewidth',2);
            for mm=1:n_components
                plot(x_achse,gmm(mm,:),char(colormap_comp(mm)))
            end
            plot(x_achse,gmm_sum,'k--','Linewidth',2)
            xlabel('electron optical density R [pm^{-1}]','fontsize',12)
            ylabel('Probability density [pm]','fontsize',12)
            axis tight
            title_komplett=strcat('Fitfunctions',title_str,'of ',{' '},zeit,{' '},'with a_{max}=',radius_str,'r');
            title(title_komplett,'Fontsize',12)
            set(gcf, 'Color', 'w');
            xlim([x_start x_end])
            hold off
            file2='fit';
            filename=strcat(file1,file2);
            %saveas(gcf,char(strcat(filename,'.fig')),'fig')
        end
        
    end
end