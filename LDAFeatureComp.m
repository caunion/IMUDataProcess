%% Feature Compression using Linear Discrimination Analysis
%
function [minFeatures] = LDAFeatureComp(features,label)
    minFeatures = [];
    [num,dim] = size(features);
    seg = [];
    
    [label,I] = sort(label);
    features = features(I,:);
    
    last = min(label);
    seg(end+1) = last;
    for i= 1: num
        if( label(i) > last)
            seg(end+1) = i;
            last = label(i);
        end
    end
    seg(end+1) = num+1;
    
    ntype = length(seg) - 1;
    m = zeros(ntype, dim);
    for i = 1: ntype
        m(i,:) = mean(features(seg(i):seg(i+1)-1,:),1);
    end
    mall = mean(features,1);
    
    Sw = zeros(dim,dim);
    for i = 1: ntype
        Ni  = seg(i+1) - seg(i);
        Swi = cov(features(seg(i):seg(i+1) - 1,:), 1) * Ni;
        Sw = Sw + Swi;
    end
    
    Sb = zeros(dim,dim);
    for i = 1: ntype
        Ni = seg(i+1) - seg(i);
        Sb = Sb + (m(i) - mall) * (m(i) -mall)' * Ni;
    end
    
    if det(Sw) ~= 0
        iSwSb = Sw\Sb;
        [V,D] = eig(iSwSb);
        
        lambda = diag(D);
        I = real(lambda) == lambda;
        W = V(:,I);
        minFeatures = features*W;
    end
end