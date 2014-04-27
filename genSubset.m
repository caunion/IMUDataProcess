function gensubset(types, max_per_type, tar, save_prefix)
    p = 'D:\Î¢ÔÆÍøÅÌ\357812021\DropBox\Dropbox\Lab\±ÏÉè\dataset\';
    subp = 'D:\Î¢ÔÆÍøÅÌ\357812021\DropBox\Dropbox\Lab\±ÏÉè\dataset\subset\';
    df= '';
    lf= '';
    switch (tar)
        case {'rtr',0},
            df = 'train96';
            dl = 'trainy';
        case {'rte',1},
            df = 'test96';
            dl = 'testy';
        case {'rftr',3},
            df = 'trainfeatures';
            dl = 'trainy';
        case {'rfte',4},
            df = 'testfeatures';
            dl = 'testy';
        case {'mftr',5},
            df = 'mtrainFeatures';
            dl = 'trainy';
        case {'mfte',6},
            df = 'mtestFeatures';
            dl = 'testy';
    end
    
    load(strcat(p,df,'.mat'));
    load(strcat(p,dl,'.mat'));
    data = eval(df);
    label= eval(dl);
    
    [data,label] = parse(types,max_per_type,data,label);
    save(sprintf('%s%s_data.mat',subp,save_prefix),'data');
    save(sprintf('%s%s_label.mat',subp,save_prefix),'label');
    
end

function [subdata,sublabel] =  parse(types,max_per_type,data,label)
    [types] = sort(types);
    subdata = [];
    sublabel= [];
    if max(types) > max(label) || min(types) < min(label)
        return;
    end
    
    for i = 1:length(types)
        I = find(label == types(i));
        if  length(I) > max_per_type
            I = randsample(I,max_per_type);
        end
        n = length(I);
        subdata(end+1:end+n,:) = data(I,:);
        sublabel(end+1:end+n,:)= label(I,:);
    end
    return;
end