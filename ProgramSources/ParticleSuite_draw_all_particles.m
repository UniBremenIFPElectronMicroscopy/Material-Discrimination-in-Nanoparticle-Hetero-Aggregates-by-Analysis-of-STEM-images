
%needs all_particles, colormaptg

if all_particles.number ~=0
            gcf
            hold on
            for ii = 1:all_particles.number
            center_coord = all_particles.center_coord(ii,:);
            radius = all_particles.radius(ii);
            index1 = all_particles.index(ii);
            colortouse =   char(colormaptg(all_particles.element(ii)));
            
            hl(1)=plot(center_coord(1),center_coord(2),colortouse);
            hltext(1)=text(center_coord(1),center_coord(2),num2str(index1),'color',  colortouse);
            x1=radius*sind([0:5:360])+center_coord(1);
            y1=radius*cosd([0:5:360])+center_coord(2);
            set(hl(1),'XData',x1,'YData',y1);
            end
            hold off
end