close all; clearvars;
cwd = pwd;
selpath = uigetdir;
cd(selpath)
mat = dir('*.mat');

for k=1:length(mat)
    
    m = matfile(mat(k).name,'Writable',true);
    load(mat(k).name);
    
    % screening
    xCell = cellTrace(:,1);
    yCell = cellTrace(:,2);
    
    [inCell onCell]= inpolygon(xn,yn,xCell,yCell);
    flooridx = abs(xstress)>1;
    flooridy = abs(ystress)>1;
    
    xstr=xstress(inCell&flooridx&flooridy);
    ystr=ystress(inCell&flooridx&flooridy);
    xnn=xn(inCell&flooridx&flooridy);
    ynn=yn(inCell&flooridx&flooridy);
    
    
    % filtering
    
    [dotp,distance] = deal(NaN(length(xstr)));
    % [thetax,thetan,idx,idn,xp,yp,pairing] = deal(zeros(length(xstr),1));s
    
    % for i = 1:length(xstr)
    %     for j = 1:length(xstr)
    %         xp(i) = xnn(i)-xnn(j);
    %         yp(i) = ynn(i)-ynn(j);
    %     end
    % end
    
    for i = 1:length(xstr)
        for j = 1:length(xstr)
            if j >= i
                %         theta(i,j) = atan2d(xstr(i).*ystr(j)-xstr(j).*ystr(i), ...
                %             xstr(i).*xstr(j)+ystr(i).*ystr(j));
                dotp(i,j) = dot([xstr(i) ystr(i)]./norm([xstr(i) ystr(i)]), ...
                    [xstr(j) ystr(j)]./norm([xstr(j) ystr(j)]));
                distance(i,j) = round(sqrt((xnn(i)-xnn(j)).^2 + (ynn(i)-ynn(j)).^2));
            end
        end
    end
    
    dist = unique(distance(:));
    dist = dist(~isnan(dist));
    [R,C] = arrayfun(@(n)find(distance==n),dist,'Uni',0);
    pos = cellfun(@(r,c)[r(:),c(:)],R,C,'Uni',0);
    lengthofpos=cellfun(@(x) numel(x),pos);
    
    moa = NaN(length(pos),max(lengthofpos)./2);
    
    for ii = 1:length(pos)
        for jj = 1:size(pos{ii},1)
            moa(ii,jj) = abs(dotp(pos{ii}(jj,1),pos{ii}(jj,2)));
            %         aoa{ii,jj} = dotp(pos{ii}(jj,1),pos{ii}(jj,2));
        end
    end
    
    %% plot all angle vs dist
    % figure
    % hold all
    % for k1 = 1:numel(dist)
    %     plot(ones(1,numel(aoa{k1}))*dist(k1), aoa{k1}, 'k.')
    % end
    % hold off
    
    avg_angle = nanmean(moa,2);
    
    m.uniquedist = dist;
    m.avgangle = avg_angle;
end