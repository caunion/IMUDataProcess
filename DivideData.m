function [train,trainy,test,testy]= DivideData(data,label,test_ratio)
    if test_ratio >= 1 || test_ratio <= 0
        return;
    end
    [num,dim] = size(data);
    test = [];
    
    train = [];
    trainy=[];
    test = [];
    testy=[];
    
    ys = unique(label);
    for i = 1:length(ys)
        I = find(label == ys(i) );
        ntest = floor(test_ratio * length(I));
        ntrain = length(I) - ntest;
        
        tesI = randsample(I,ntest);
        traI = setdiff(I,tesI);
        test(end+1:end+ ntest,:) =  data(tesI,:);
        train(end+1:end+ ntrain,:) = data(traI,:);
        testy(end+1:end+ntest,:) = label(tesI,:);
        trainy(end+1:end+ ntrain,:) = label(traI,:);
    end
end