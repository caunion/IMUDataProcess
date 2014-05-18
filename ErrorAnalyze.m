%%
%
%
function ErrorAnalyze(realy,predy)
    errtypes = analyze(realy,predy);
    accurate = accurancy(errtypes,realy);
    confuseM = confuseMatrix(realy,predy);
    fprintf('total accurancy: %d',accurate);
    ploterr(errtypes);
    
    
end

function [confuseM] = confuseMatrix(realy, predicty)
    types = union(realy,realy);
    confuseM = zeros(length(types),length(types));
    for i = 1 : length(types)
        rtype = types(i);
        rI = find(realy == rtype);
        pred = predicty(rI);
        tnum = length(rI);
        for j = 1 : length(types)
            ptype = types(j);
            pI = find(pred == ptype);
            pnum = length(pI);
            confuseM(i,j) = pnum / tnum;
        end
    end
end
function [errtypes] = analyze(realy,predicty)
    if size(predicty,2) ~= 1 || size(realy,2) ~= 1 || size(realy,1) ~= size(predicty,1)
        return;
    end
    types  = union(realy,realy);
    errtypes = cell( size(types,1),1);
    for i=1:length(predicty)
        if predicty(i) ~= realy(i)
            errtypes{realy(i)}(end+1,:) = predicty(i); 
        end
    end
end

function [accurancies] = accurancy(errtypes,realy)
    totalerr = 0;
    for i =1:length(errtypes)
        totalerr = totalerr + length(errtypes{i});
    end
    accurancies = 1- totalerr / length(realy) ;
    
end

function ploterr(errtypes)
    overall = zeros(length(errtypes),1);
    for i = 1:length(errtypes)
        overall(i) = size(errtypes{i},1);
    end
    
    x = 1:20;
    plot(x,overall,'r-+');
    xlabel('type');
    ylabel('errnum');
    title('prediction err num');
    set(gca,'XTick',1:length(errtypes));
    
    for i = 1:length(errtypes)
        figure(1+i);
        data = errtypes{i};
        y = [];
        for j = 1:length(errtypes)
            y(j) = length(find(data == j));
        end
        
        subplot(2,1,1);
        bar(x,y);
        title(sprintf('%dth err analysis',i));
        set(gca,'XTick',1:length(errtypes));
        
        subplot(2,1,2);
        plot(data);
        set(gca,'YTick',1:length(errtypes));
    end
end