%%
%
function do()
    svmpath  = 'D:\Î¢ÔÆÍøÅÌ\357812021\DropBox\Dropbox\Lab\±ÏÉè\SVM\libsvm-master\libsvm-master\windows\';
    procpath = 'D:\Î¢ÔÆÍøÅÌ\357812021\DropBox\Dropbox\Lab\±ÏÉè\DataProcess\';
    datapath = 'D:\Î¢ÔÆÍøÅÌ\357812021\WorkSpace\TsinghuaLab\data\6dmg';
    path(path, svmpath);
    path(path, procpath);
    path(path, datapath);
    
    load('trainfeatures.mat');
    load('trainy.mat');
    [mtrainFeatures] = LDAFeatureComp(trainfeatures,trainy);
    [ntrain,ntrainy,ntest,ntesty] = rebuild(mtrainFeatures,trainy, 1000);
    
    save('ndataset.mat','ntrain','ntrainy','ntest','ntesty');
end

function [train, trainy, test, testy] = rebuild(origin, originy, testSize)
    [num,dim] = size(origin);
    seg = [];
    label = originy;
    last = min(label);
    seg(end+1) = last;
    for i= 1: num
        if( label(i) > last)
            seg(end+1) = i;
            last = label(i);
        end
    end
    seg(end+1) = num+1;
    ntypes = length(seg)-1;
    
    test = zeros(ntypes*testSize, dim);
    testy= zeros(ntypes*testSize, 1);
    mask = [];
    idx  =1;
    for i = 1: ntypes
        testMask = randsample(seg(i): seg(i+1)-1, testSize);
        test( (i-1)*testSize + 1: i*testSize,:) = origin(testMask,:);
        testy((i-1)*testSize + 1: i*testSize,:) = originy(testMask,:);
        mask(end+1:end + testSize) = testMask;
    end
    
    origin(mask,:) = [];
    originy(mask,:) = [];
    train = origin;
    trainy = originy;
    
end