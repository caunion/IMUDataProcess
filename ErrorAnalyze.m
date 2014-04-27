
function do()
%     if ~exist('testy.mat')
%         [train,trainy,test,testy] = ReadDataSet(1,20);
%         save('testy.mat','testy');
%     else
%         load('testy.mat');
%     end
    load('ndataset.mat');
    load('predicted_label_G.mat');
    clear train triany test;
    
    errtypes = analyze(ntesty,predicted_label_G);
    ploterr(errtypes);
    
end

function [errtypes] = analyze(realy,predicty)
    errtypes = cell(max(predicty) - min(predicty) + 1,1);
    for i=1:length(predicty)
        if predicty(i) ~= realy(i)
            errtypes{realy(i)}(end+1,:) = predicty(i); 
        end
    end
    save('errtypes.mat','errtypes');
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