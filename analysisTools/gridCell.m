close all; clearvars;
cwd = pwd;
selpath = uigetdir;
cd(selpath)
mat = dir('*.mat');

for k=1:length(mat)
    m = matfile(mat(k).name,'Writable',true);
    load(mat(k).name);
    
    xmin = min(cellTrace(:,1));
    ymin = min(cellTrace(:,2));
    xmax = max(cellTrace(:,1));
    ymax = max(cellTrace(:,2));
    biggrid = polyshape([xmin xmax xmax xmin],[ymin ymin ymax ymax]);
    
    gridsize = 36;
    
    index = 0;
    % lgrid = cell((ceil((xmax-xmin)./gridsize).*(ceil((ymax-ymin)./gridsize))),1);
    
    for x = xmin:gridsize:xmax
        for y = ymin:gridsize:ymax
            vertices = [[x,y]; [x+gridsize,y]; [x+gridsize,y+gridsize]; [x,y+gridsize]];
            cond = inpolygon(vertices(:,1),vertices(:,2),cellTrace(:,1),cellTrace(:,2));
            cond2 = inpolygon(cellTrace(:,1),cellTrace(:,2),vertices(:,1),vertices(:,2));
            if any(cond(:) > 0) || any(cond2(:) > 0 )
                sgrid = polyshape([x x+gridsize x+gridsize x],[y y y+gridsize y+gridsize]);
                index = index+1;
                lgrid{index} = sgrid;
            end
        end
    end
    
    % figure()
    % hold on
    % plot(cellTrace(:,1),cellTrace(:,2),'r.')
    % plot(xn,yn,'k.')
    % for i = 1:1:index
    %     plot(lgrid{i})
    % end
    % hold off
    
    inTrace = inpolygon(xn,yn,cellTrace(:,1),cellTrace(:,2));
    xfil = xn(inTrace);
    yfil = yn(inTrace);
    xstressf = xstress(inTrace);
    ystressf = ystress(inTrace);
    
    figure()
    hold on
    plot(cellTrace(:,1),cellTrace(:,2),'r.')
    plot(xfil,yfil,'k.')
    for i = 1:1:index
        plot(lgrid{i})
    end
    hold off
    
    % figure()
    % hold on
    % plot(cellTrace(:,1),cellTrace(:,2),'r.')
    % quiver(xfil,yfil,xstressf,ystressf)
    % hold off
    
    for k=1:index
        inrect = inpolygon(xfil,yfil,lgrid{k}.Vertices(:,1),lgrid{k}.Vertices(:,2));
        xpos = xfil(inrect);
        ypos = yfil(inrect);
        xstr = xstressf(inrect);
        ystr = ystressf(inrect);
        
        %     figure()
        %     hold on
        %     plot(cellTrace(:,1),cellTrace(:,2),'r.')
        %     plot(xpos,ypos,'k.')
        %     quiver(xpos,ypos,xstr,ystr)
        %     plot(lgrid{k})
        %     hold off
        
        if ~(length(xstr) < 1 || length(ystr) < 1)
            xnew = mean(xstr);
            ynew = mean(ystr);
            theta = zeros(length(xstr),1);
            for i = 1:length(xstr)
                theta(i) = atan2d(xstr(i).*ynew-xnew.*ystr(i), ...
                    xstr(i).*xnew+ystr(i).*ynew);
            end
            s(k) = mean((3.*cosd(theta).^2 - 1)./2);
        end
    end
    m.ordergrid = mean(s);
end