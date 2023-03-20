function [center_coord,radius,hl]=Particle_Suit_get_circle(number1)

%based on KM routine

x_coord=[];
y_coord=[];
radius=[];
center_coord=[];

cy=[];
fhdl=gcf;


ah=get(fhdl,'Currentaxes');

cnt=0;
set(fhdl,'WindowButtonDownFcn',@drawit);


ah=gca;

%for ka=1:length(ah)
%set(ah(ka),'DrawMode','fast');
%end
hold on


hl=[];
hltext=[];

waitfor(fhdl,'WindowButtonDownFcn');

hl=[hl hltext];

    function drawit(src,evnt)
        
        pos=get(ah(1),'CurrentPoint');
        x=pos(1,1);
        y=pos(1,2);
        
        cnt=cnt+1;
        
        if cnt==1;
            x_coord=x;
            y_coord=y;
            hl(1)=plot(x_coord,y_coord,'y-');
            hltext(1)=text(x_coord,y_coord,num2str(number1),'color','y');
            %hl(2)=plot(x_coord,y_coord,'y-');
            %set(hl(2),'visible','off');
            
            
            set(fhdl,'WindowButtonMotionFcn',@drawit1);
            drawnow
            return;
        end
        if cnt==2
            
            drawnow
            set(fhdl,'WindowButtonDownFcn','');
            set(fhdl,'WindowButtonMotionFcn','');
        end
        
        function drawit1(src,evnt)
            pos=get(ah(1),'CurrentPoint');
            x=pos(1,1);
            y=pos(1,2);
            center_coord(1)=0.5*x_coord+0.5*x;
            center_coord(2)=0.5*y_coord+0.5*y;
            radius=norm([0.5*(x-x_coord) 0.5*(y-y_coord)]);
            x1=radius*sind([0:5:360])+center_coord(1);
            y1=radius*cosd([0:5:360])+center_coord(2);
            set(hl(1),'XData',x1,'YData',y1);
            
            
        end
        
    end
end