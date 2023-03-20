%PARTICLE SUITE Limited (Tim Grieb, Beeke Gerken)
%
%Manual:
% Step 1: start matlab and select the folder with the scripts as your current folder
% Step 2: start this program by typing "ParticleSuite_LTD" in the command window
% Step 3: type "11" in the command window and select an image to be marked, this has to be a .mat file, 
% which contains: image (img) and the size of a pixel in nm (pixsizex and pixsizey)
% Step 5: (optional) type "12", displays the image
% Step 6: marking of the W-PPs: type "21", type "1" to mark Tungstenoxide-PPs as you would identify them by the help of a EDXS map.
%         click in the image and move the mouse courser and click again to mark a PP, then repeat for the next PP,
%         when you are finished with W-PPs, you can press "esc" and confirm adding this markings to your data struct by pressing "1".
% Step 7: marking of Ti-PPs:  type "21", type "2" to mark Ti-PPs, proceed analogous to Step 6
% Step 8: (optional) if you are not satisfied by your markings, you can delete single PPs by typing "22" and 
%         typing the numbers of PPs, which you would like to delete. You can repeat Steps 6 and 7 to add markings.
% Step 9: save your data by typing "91". you could choose a different filename to the suggested one, 
%         but the following scripts expect this suggested filename.
% Step 10: type "-1" to exit the program
        

if ~exist('agregate')
    agregate=[];
end
counter = 0;

what=123;

while(~(what==-1))
    
    
    menu_str=sprintf('SINGLE IMAGE:\n11 load image\n');
    menu_str=sprintf('%s12 show image\n',menu_str);
    menu_str=sprintf('%s13 Clear Particles\n\n',menu_str);
    
    menu_str=sprintf('%s21 Select Particles\n',menu_str);
    menu_str=sprintf('%s22 Delet Single Particles\n\n',menu_str);
    
    menu_str=sprintf('%s91 Save Data\n',menu_str);
    menu_str=sprintf('%s92 Load Data\n\n',menu_str);
    
    menu_str=sprintf('%s-1 Exit\n',menu_str);
    disp(menu_str);
    
    what=input('Enter number: ');
    if (~(what==-1))
        close all;
    end
    
    colormaptg = {'r','g','g','y'};
    
    switch(what)
        
        
        %______________________________________________________________________
        %______________________________________________________________________
        %______________________________________________________________________
        case 11
            
            dummy =input('\nreally? loading image clears particles 1/0...\n');
            if dummy ==1
                
                if ~exist('path_orig')
                    path_orig = '';
                end
                fprintf('Select .mat file of the image\n')
                [file_orig path_orig] = uigetfile({'*.mat'},'Select mat-file with image',path_orig);
                fprintf(['Selected image: ' file_orig  '\n\n'])
                
                load([path_orig file_orig]);
                img=myimage;
                px2nm=pixsizex;
                px2nmX = pixsizex;
                px2nmY = pixsizey;
                
                img_filt=img;
                all_particles = [];
                all_particles.number = 0;
                
            end
            
            %______________________________________________________________________
            %______________________________________________________________________
            %______________________________________________________________________
        case 12
            
            figure(12)
            imagesc(img_filt)
            colormap('jet')
            
            if exist('all_particles')
                ParticleSuite_draw_all_particles;
            end
            
            %______________________________________________________________________
            %______________________________________________________________________
            %______________________________________________________________________
        case 13
            
            dummy =input('\nreally? 1/0...\n');
            if dummy ==1
                all_particles = [];
                all_particles.number = 0;
            end
            
            %______________________________________________________________________
            %______________________________________________________________________
            %______________________________________________________________________
            
        case 21%get particles
            
            figure(12)
            imagesc(img_filt)
            colormap('jet')
            
            fprintf('You can zoom in before choosing element.\nBut leave magnification mode after zooming!\n')
            
            element =input('\nChoose W(1) or Ti(2)...\n');
            
            ParticleSuite_draw_all_particles;
            
            goon = 1;
            getparts =[];
            cnt = 0;
            while goon == 1
                cnt = cnt +1;
                [center_coord,radius,hl]=Particle_Suit_get_circle(cnt);
                getparts(cnt).center_coord = center_coord;
                getparts(cnt).radius = radius;
                getparts(cnt).hl = hl;
                getparts(cnt).number = cnt;
                getparts(cnt).element = element;
                
                k = waitforbuttonpress;
                if k == 1
                    goon=0;
                end
            end
            close figure 12
            
            %-------------------------------------------
            dummy =[];
            while isempty(dummy)
                dummy =input('\nAdd to Particles? 1/0...\n');
                if dummy ==1
                    cnt = all_particles.number;
                    for ii = 1:length(getparts)
                        if ~isempty(getparts(ii).radius)
                            cnt = cnt+1;
                            all_particles.number = all_particles.number + 1;
                            all_particles.index(cnt,1) = cnt;
                            all_particles.radius(cnt,1) = getparts(ii).radius;
                            all_particles.element(cnt,1) = getparts(ii).element;
                            all_particles.center_coord(cnt,:) = getparts(ii).center_coord;
                            all_particles.px2nm  = [px2nmX];
                            all_particles.image_file = file_orig;
                            all_particles.image_path = path_orig;
                            if isfield(all_particles,'cluster_manual')
                                all_particles.cluster_manual(cnt) =0;
                            end
                        end
                    end
                    all_particles.image_filtered = img_filt;
                end
            end
            
            %-------------------------------------------
            
            %draw all particles
            figure(12)
            imagesc(img_filt)
            colormap('jet')
            ParticleSuite_draw_all_particles;
            %-------------------------------------------
            
            
            %______________________________________________________________________
            %______________________________________________________________________
            %______________________________________________________________________
        case 22
            %delete single partikles
            figure(12)
            imagesc(img_filt)
            colormap('jet')
            
            ParticleSuite_draw_all_particles;
            
            todelete = input('\nDelete the following particles z.B. [1 2 45 190]:   ')
            
            if ~isempty(todelete) & todelete~=0
                all_particles_save = all_particles;
                all_particles = [];
                
                indnotdelet = find(~ismember(all_particles_save.index,todelete));
                
                all_particles.image_file = all_particles_save.image_file;
                all_particles.image_path = all_particles_save.image_path;
                all_particles.px2nm = all_particles_save.px2nm;
                all_particles.radius =  all_particles_save.radius(indnotdelet);
                all_particles.element =  all_particles_save.element(indnotdelet);
                all_particles.center_coord =  all_particles_save.center_coord(indnotdelet,:);
                all_particles.number = all_particles_save.number - length(todelete);
                all_particles.index(:,1) =  [1:1:all_particles.number];
                if isfield(all_particles,'cluster_manual')
                    all_particles.cluster_manual =  all_particles_save.cluster_manual(indnotdelet);
                end
                
                clear all_particles_save
            end
            
            
            %______________________________________________________________________
            %______________________________________________________________________
            %______________________________________________________________________
        case 91
            %save data for image
            all_particles.image_filtered=img_filt;%%neu
            inddot = findstr(all_particles.image_file,'.');
            if length(all_particles.image_file)>=8
                filename_save = all_particles.image_file(1:8);
            else
                filename_save = all_particles.image_file(1:end-4);
            end
            %filename_save(inddot) = '_';
            filename_save = [filename_save '_PARTICLE_DATA.mat'];
            
            [file_save path_save filter_save] = uiputfile('.mat','save file',[all_particles.image_path '/' filename_save])
            if filter_save
                save([path_save file_save],'all_particles')
            end
            
            %______________________________________________________________________
            %______________________________________________________________________
            %______________________________________________________________________
        case 92
            %load data
            if ~exist('path_orig')
                path_orig = '';
            end
            fprintf('Select PARTICLE_DATA file\n')
            [file_load path_load] = uigetfile('*.mat','Select DATA  file',path_orig);
            fprintf(['Selected file: ' file_load  '\n\n'])
            
            clear all_particles
            load([path_load file_load])
            path_orig = all_particles.image_path;
            file_orig  = all_particles.image_file;
            
            img_filt =  all_particles.image_filtered;
            
            figure(12)
            imagesc(img_filt)
            colormap('jet')
            
            ParticleSuite_draw_all_particles;
            
            
    end
    
end