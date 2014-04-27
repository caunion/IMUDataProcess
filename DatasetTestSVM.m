function do()
    svmpath = 'lib\SVM\libsvm-master\libsvm-master\windows';
    datapath= '..\dataset\';
    sbdtpath= '..\dataset\subset\';
    path(svmpath,path);
    path(datapath,path);
    path(sbdtpath,path);
    
    %startt = 1;
    %endt = 8;
    %[train,trainy,test,testy]=ReadDataSet(startt,endt);
    %[train,test] = loadFeature(startt,endt,trainy,testy);
    load('trainfeatures.mat');
    load('trainy.mat');
    load('testfeatures.mat');
    load('testy.mat');
    train = trainfeatures;
    test = testfeatures;
    [data,label] = mergeData(train,trainy,test,testy);
    [train,trainy,test,testy] = DivideData(data,label,0.2);
    
    fprintf('data loaded!\n');
    [train_scale,test_scale] = scale(train,test);
    LinearKernelSVM(train_scale,trainy,test_scale,testy);
    GaussianKernelSVM(train_scale,trainy,test_scale,testy);
end
function [train_cale,test_scale] = scale(train,test)
    minimums = min(train, [], 1);
    ranges = max(train, [], 1) - minimums;
    train_cale = (train - repmat(minimums, size(train, 1), 1)) ./ repmat(ranges, size(train, 1), 1);
    test_scale = (test - repmat(minimums, size(test, 1), 1)) ./ repmat(ranges, size(test, 1), 1);
end

function [data,label] = mergeData(train,trainy,test,testy)
    if size(train,2) ~= size(test,2)
        return;
    end
    dim = size(train,2);
    
    labels = union(trainy,testy);
    data  = zeros(size(train,1) + size(test,1), dim);
    label = zeros(size(train,1) + size(test,1), 1);
    idx = 0;
    for i = 1 : length(labels)
        type = labels(i);
        traI = find(trainy == type);
        tesI = find(testy == type);
        num = length(traI) + length(tesI);
        data(idx + 1 : idx + num,:) = [train(traI,:);test(tesI,:)];
        label(idx + 1 : idx + num, :) = [trainy(traI,:);testy(tesI,:)];
        idx = idx + num;
    end
end
function [train,test] = loadFeature(startt,endt,trainy,testy)
    load('trainfeatures.mat');
    load('testfeatures.mat');
    startp =0;
    for i = 1: length(trainy)
        if trainy(i) ==startt
            startp = i;
            break;
        end
    end
    
    for endp = startp : length(trainy)
        if trainy(endp) == endt + 1
            endp = endp - 1;
            break;
        end
    end
    train = trainfeatures(startp:endp,:);
    
    startp =0;
    for i = 1: length(testy)
        if testy(i) ==startt
            startp = i;
            break;
        end
    end
    
    for endp = startp : length(testy)
        if testy(endp) == endt + 1
            endp = endp - 1;
            break;
        end
    end
    test  = testfeatures(startp:endp,:);
end

function LinearKernelSVM(train,trainy,test,testy)
    %linear kernel
    fprintf('Linear train begin\n');
    model_linear = svmtrain(trainy,train,'-t 0');
    fprintf('Linear train finished\n');
    save('model_linear.mat','model_linear');
    fprintf('Linear train saved, begin to test\n');
    [predicted_label_L, accuracy_L, prob_estimates_L] = svmpredict(testy, test, model_linear);
    disp(accuracy_L);
    save('accuracy_L.mat','accuracy_L');
    save('predicted_label_L.mat','predicted_label_L');
    fprintf('Linear test finished!\n\n');
end

function GaussianKernelSVM(train,trainy,test,testy)
    %Gaussian/RBF kernel 
    fprintf('Gaussian/RBF kernel train begin\n');
    model_gaussian = svmtrain(trainy, train,'-t 2');
    fprintf('Gaussian/RBF train finished\n');
    [predicted_label_G, accuracy_G, prob_estimates_G] = svmpredict(testy, test, model_gaussian);
    disp(accuracy_G);
    save('accuracy_G.mat','accuracy_G');
    save('predicted_label_G.mat','predicted_label_G');
    save('model_gaussian.mat','model_gaussian');
    fprintf('Gaussian/RBF test finished!\n\n');
end