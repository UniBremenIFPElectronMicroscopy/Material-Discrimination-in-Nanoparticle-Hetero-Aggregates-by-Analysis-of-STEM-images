function draw_all_particles_function(all_particles,img,cmap)
% draws the PPs, contained in 'all_particles' onto the image 'img' with the
% colormap 'cmap'

colormapbg = {[0 1 0],[1 0 0],[226 0 116],[0 1 1]};
bereich=[1:size(img,1)].*all_particles.px2nm;
figure;
axis image
imagesc(bereich, bereich,img);
hold on
xlabel('x in nm','FontSize',16)
ylabel('y in nm','FontSize',16)
colormap(cmap)
axis image
set(gca,'FontSize',16)
pos = get(gca, 'Position');
hold on
if all_particles.number ~=0
    gcf
    hold on
    for ii = 1:all_particles.number
        fortschritt = 'Partikel %4.0f von %4.0f \n';
        fprintf(fortschritt,ii,all_particles.number)
        center_coord = all_particles.center_coord(ii,:).*all_particles.px2nm;
        radius = all_particles.radius(ii).*all_particles.px2nm;
        index1 = all_particles.index(ii);
        colortouse = colormapbg{all_particles.element(ii)};
        
        hl(ii)=plot(center_coord(1),center_coord(2),'Color',colortouse,'LineWidth',1);
        hold on
        x1=radius*sind([0:5:360])+center_coord(1);
        y1=radius*cosd([0:5:360])+center_coord(2);
        set(hl(ii),'XData',x1,'YData',y1);
    end
    
    annotation('textbox', [.65 .71 .09 .09], 'String', 'TiO_2','EdgeColor','r','FontSize',16,...
        'Linewidth',2,'BackgroundColor','none','Color','r','Margin',0,'HorizontalAlignment','center','VerticalAlignment','middle')
    annotation('textbox', [.65 .83 .09 .09], 'String', 'WO_3','EdgeColor','g','FontSize',16,...
        'Linewidth',2,'BackgroundColor','none','Color','g','Margin',0,'HorizontalAlignment','center','VerticalAlignment','middle')
end
drawnow
colorbar
hold off
set(gca,'FontSize',16)
end