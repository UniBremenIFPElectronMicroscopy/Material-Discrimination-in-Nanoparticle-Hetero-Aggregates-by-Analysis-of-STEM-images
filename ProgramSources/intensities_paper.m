%This script calculates the projected thickness of the aggregate in each
%pixel from the geometric model and writes a list of intensity-values,
%which belong to PPs and excludes overlapping regions. These values are saved in a .mat file
%named like a timestamp followed by "_1.0_intensities", e.g. "11.47.17_1.0_intensities.mat".
%If you didn't change the 'PARTICLE_DATA'-STRUCT, you can omit this step
%and proceed with the script 'histograms_paper', as this takes some time.

close all
clear all
[partfile_multi,partpath] = uigetfile('*PARTICLE_DATA.mat','MultiSelect','on','Select particledata .mat');

if iscell(partfile_multi)
    anzahl_files=size(partfile_multi,2);
else
    anzahl_files=1;
end

for iii=1:anzahl_files
    clearvars -except anzahl_files partfile_multi partpath iii
    
    if iscell(partfile_multi)
        partfile=char(partfile_multi(iii));
    else
        partfile=char(partfile_multi);
    end
    [matchstr splitstr] = regexp(partfile, '_', 'match','split');
    zeit=splitstr(1);
    imagefile=char(strcat(zeit,'.mat'));
    imagepath=partpath;
    load([imagepath,imagefile]);
    load([partpath,partfile])
    
    img=myimage;
    bereich=[1:size(img,1)].*all_particles.px2nm;
    bereichx=(length(img)-1)*pixsizex;
    bereichy=(length(img)-1)*pixsizey;
    
    colormapbg = {'r','b','m','cyan'};
    clear figure(25)
    draw_all_particles_function(all_particles,img,'jet')
    hold off
    
    
    %% creation of a mask to exclude overlapping regions
    img_anzahl=all_particles.image_filtered.*0;
    
    for ii = 1:all_particles.number;%all_particles.number
        fortschritt = 'Partikel %4.0f von %4.0f \n';
        fprintf(fortschritt,ii,all_particles.number)
        koordsX = round(all_particles.center_coord(ii,1)-all_particles.radius(ii):all_particles.center_coord(ii,1)+all_particles.radius(ii));
        koordsY = round(all_particles.center_coord(ii,2)-all_particles.radius(ii):all_particles.center_coord(ii,2)+all_particles.radius(ii));
        if max( koordsX)>size(img_anzahl,1) | min( koordsX)<1
            koordsX = koordsX(find(koordsX>=1 & koordsX<=size(img_anzahl,1)));
        end
        if max( koordsY)>size(img_anzahl,2) | min( koordsY)<1
            koordsY = koordsY(find(koordsY>=1 & koordsY<=size(img_anzahl,2)));
        end
        
        patch_quad_anzahl=  img_anzahl(koordsY,koordsX);
        
        [X Y] = meshgrid(linspace(-size(patch_quad_anzahl,1)/2,size(patch_quad_anzahl,1)/2,size(patch_quad_anzahl,1)),linspace(-size(patch_quad_anzahl,2)/2,size(patch_quad_anzahl,2)/2,size(patch_quad_anzahl,2)));
        distances = sqrt(X.^2 + Y.^2);
        distances_maske=distances;
        distances_maske(find(distances_maske<=all_particles.radius(ii)))=1;
        distances_maske(find(distances_maske>all_particles.radius(ii)))=0;
        
        patch_pp_anzahl=distances_maske;
        img_anzahl(koordsY,koordsX) = img_anzahl(koordsY,koordsX)+patch_pp_anzahl;
        
    end
    
    figure;
    imagesc(img_anzahl,'XData',[0,bereichx],'YData',[0,bereichy])
    title('number of PPs in each pixel')
    colormap jet
    colorbar
    xlabel('x in nm','FontSize',16)
    ylabel('y in nm','FontSize',16)
    axis on
    axis image
    set(gca,'FontSize',16)
    pos = get(gca, 'Position');
    set(gca, 'Position', [pos(1) pos(2)+0.05 pos(3) pos(4)-0.05]);
    set(gcf, 'Color', 'w');
    filename=char(strcat(imagepath,zeit,'maske'));
    
    
    img_single=img_anzahl;
    img_single(find(img_single>=2))=0;
    img_single=logical(img_single);
    figure;
    imagesc(img_single,'XData',[0,bereichx],'YData',[0,bereichy])
    colormap gray
    title('Regions with only one PP')
    xlabel('x in nm','FontSize',16)
    ylabel('y in nm','FontSize',16)
    axis on
    axis image
    set(gca,'FontSize',16)
    pos = get(gca, 'Position');
    set(gca, 'Position', [pos(1) pos(2)+0.05 pos(3) pos(4)-0.05]);
    set(gcf, 'Color', 'w');
    filename=char(strcat(imagepath,zeit,'maske_bw'))
    %saveas(gcf,[filename,'.fig'],'fig')
    
    %% Calculations
    max_radius=1;
    bwimg = all_particles.image_filtered.*0;
    sehne_ges=[];
    int_ges=[];
    part_nummer_ges=[];
    ind_W_liste=[];
    ind_Ti_liste=[];
    koordsY_ges=[];
    koordsX_ges=[];
    dist_durch_radius_ges=[];
    portion=8;
    for mm=1:floor(all_particles.number/portion);
        sehne=[];
        int=[];
        part_nummer=[];
        koordsY_pp=[];
        koordsX_pp=[];
        dist_pp=[];
        for ii =(mm-1)*portion+1:mm*portion;
            fortschritt = 'Partikel %4.0f von %4.0f \n';
            fprintf(fortschritt,ii,all_particles.number)
            koordsX = round(all_particles.center_coord(ii,1)-all_particles.radius(ii):all_particles.center_coord(ii,1)+all_particles.radius(ii));
            koordsY = round(all_particles.center_coord(ii,2)-all_particles.radius(ii):all_particles.center_coord(ii,2)+all_particles.radius(ii));
            if max( koordsX)>size(bwimg,1) | min( koordsX)<1
                koordsX = koordsX(find(koordsX>=1 & koordsX<=size(bwimg,1)));
            end
            if max( koordsY)>size(bwimg,2) | min( koordsY)<1
                koordsY = koordsY(find(koordsY>=1 & koordsY<=size(bwimg,2)));
            end
            patch_quad = bwimg(koordsY,koordsX);
            [X Y] = meshgrid(linspace(-size(patch_quad,1)/2,size(patch_quad,1)/2,size(patch_quad,1)),linspace(-size(patch_quad,2)/2,size(patch_quad,2)/2,size(patch_quad,2)));
            distances = sqrt(X.^2 + Y.^2);
            
            bwimg(koordsY,koordsX) = patch_quad;
            
            for jj=1:size(patch_quad,1)
                for kk=1:size(patch_quad,2)
                    if distances(jj,kk)<=all_particles.radius(ii).*max_radius && img_single(koordsY(jj),koordsX(kk))==1;
                        segmenthoehe=all_particles.radius(ii)-distances(jj,kk);
                        sehne_temp=2*sqrt(2.*all_particles.radius(ii).*segmenthoehe-segmenthoehe.^2);
                        sehne=[sehne sehne_temp];
                        int=[int myimage(koordsY(jj),koordsX(kk))];
                        part_nummer=[part_nummer ii];
                        koordsY_pp=[koordsY_pp koordsY(jj)];
                        koordsX_pp=[koordsX_pp koordsX(kk)];
                        dist_pp=[dist_pp distances(jj,kk)/all_particles.radius(ii)];
                        if all_particles.element(ii)==1
                            ind_W_liste=[ind_W_liste 1];
                            ind_Ti_liste=[ind_Ti_liste 0];
                        elseif all_particles.element(ii)==2
                            ind_W_liste=[ind_W_liste 0];
                            ind_Ti_liste=[ind_Ti_liste 1];
                        end
                    end
                end
            end
        end
        
        koordsY_ges=[koordsY_ges koordsY_pp];
        koordsX_ges=[koordsX_ges koordsX_pp];
        dist_durch_radius_ges=[dist_durch_radius_ges dist_pp];
        sehne_ges=[sehne_ges sehne];
        part_nummer_ges=[part_nummer_ges part_nummer];
        int_ges=[int_ges int];
    end
    sehne=[];
    int=[];
    part_nummer=[];
    koordsY_pp=[];
    koordsX_pp=[];
    dist_pp=[];
    rest=mod(all_particles.number,portion);
    for ii=mm*portion+1:mm*portion+rest
        fortschritt = 'Partikel %4.0f von %4.0f \n';
        fprintf(fortschritt,ii,all_particles.number)
        koordsX = round(all_particles.center_coord(ii,1)-all_particles.radius(ii):all_particles.center_coord(ii,1)+all_particles.radius(ii));
        koordsY = round(all_particles.center_coord(ii,2)-all_particles.radius(ii):all_particles.center_coord(ii,2)+all_particles.radius(ii));
        if max( koordsX)>size(bwimg,1) | min( koordsX)<1
            koordsX = koordsX(find(koordsX>=1 & koordsX<=size(bwimg,1)));
        end
        if max( koordsY)>size(bwimg,2) | min( koordsY)<1
            koordsY = koordsY(find(koordsY>=1 & koordsY<=size(bwimg,2)));
        end
        
        patch_quad = bwimg(koordsY,koordsX);
        [X Y] = meshgrid(linspace(-size(patch_quad,1)/2,size(patch_quad,1)/2,size(patch_quad,1)),linspace(-size(patch_quad,2)/2,size(patch_quad,2)/2,size(patch_quad,2)));
        distances = sqrt(X.^2 + Y.^2);
        
        bwimg(koordsY,koordsX) = patch_quad;
        for jj=1:size(patch_quad,1)
            for kk=1:size(patch_quad,2)
                if distances(jj,kk)<=all_particles.radius(ii).*max_radius && img_single(koordsY(jj),koordsX(kk))==1;
                    segmenthoehe=all_particles.radius(ii)-distances(jj,kk);
                    sehne_temp=2*sqrt(2.*all_particles.radius(ii).*segmenthoehe-segmenthoehe.^2);
                    sehne=[sehne sehne_temp];
                    int=[int myimage(koordsY(jj),koordsX(kk))];
                    part_nummer=[part_nummer ii];
                    koordsY_pp=[koordsY_pp koordsY(jj)];
                    koordsX_pp=[koordsX_pp koordsX(kk)];
                    dist_pp=[dist_pp distances(jj,kk)/all_particles.radius(ii)];
                    if all_particles.element(ii)==1
                        ind_W_liste=[ind_W_liste 1];
                        ind_Ti_liste=[ind_Ti_liste 0];
                    elseif all_particles.element(ii)==2
                        ind_W_liste=[ind_W_liste 0];
                        ind_Ti_liste=[ind_Ti_liste 1];
                    end
                end
            end
        end
    end
    
    
    koordsY_ges=[koordsY_ges koordsY_pp];
    koordsX_ges=[koordsX_ges koordsX_pp];
    dist_durch_radius_ges=[dist_durch_radius_ges dist_pp];
    sehne_ges=[sehne_ges sehne];
    part_nummer_ges=[part_nummer_ges part_nummer];
    int_ges=[int_ges int];
    ind_W_liste=logical(ind_W_liste);
    ind_Ti_liste=logical(ind_Ti_liste);
    int_log=-log(1-int_ges);
    sehne_nm=sehne_ges.*pixsizex;
    y_werte_W=int_log(ind_W_liste)./sehne_nm(ind_W_liste);
    y_werte_Ti=int_log(ind_Ti_liste)./sehne_nm(ind_Ti_liste);
    
    %% Bar-chart
    max_bin=0.005
    min_bin=0
    xbin=min_bin:max_bin/1000:max_bin;
    n_W=hist(y_werte_W,xbin);
    n_Ti=hist(y_werte_Ti,xbin);
    clear Y
    Y(:,1)=n_W;
    Y(:,2)=n_Ti;
    
    figure;
    bar(xbin,Y,'stacked');
    hold on
    ylabel('frequency','FontSize',12)
    xlabel('ratio of -log(1-Int) to thickness in nm','FontSize',10)
    hleg1=legend('Wolfram','Titan','FontSize',12,'Location','northeast')
    legend('boxoff')
    set(gca,'FontSize',12)
    xlim([min_bin max_bin])
    hold off
    
    %% Saving variables
    filename=char(strcat(imagepath,zeit,sprintf('_%1.1f_intensities.mat',max_radius)));
    if exist('det_I_max','var')
        save(filename,'dist_durch_radius_ges','max_radius','koordsY_ges','koordsX_ges','myimage','img_single','bereichx','bereichy','pixsizex','pixsizey','det_I_max','det_I_min','sehne_ges','part_nummer_ges','int_ges','ind_W_liste','ind_Ti_liste','y_werte_W','y_werte_Ti');
    else
        save(filename,'dist_durch_radius_ges','max_radius','koordsY_ges','koordsX_ges','myimage','img_single','bereichx','bereichy','pixsizex','pixsizey','sehne_ges','part_nummer_ges','int_ges','ind_W_liste','ind_Ti_liste','y_werte_W','y_werte_Ti');
    end
    
    
end
