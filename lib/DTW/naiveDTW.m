if ~exist('isInit','var') || ~isInit
    clear;
    load('D:\Î¢ÔÆÍøÅÌ\357812021\WorkSpace\TsinghuaLab\data\6dmg\test96.mat','test_data','test_y');
    load('D:\Î¢ÔÆÍøÅÌ\357812021\WorkSpace\TsinghuaLab\data\6dmg\train96.mat','train_data','train_y');
    fprintf('Test and train data loaded\n');
    isInit = true;
end

gest_types = 20; %gesture type to train/test
trinst_per_type = 21000; %items per type in trian set
tsinst_per_type = 7000; %items per type in test set
dims = 576;
single_dim = 96
ndim = 6;
train_mean = [];
train_mean2 = [];
test_mean = [];
size_test = zeros(20,1);
size_train= zeros(20,1);
    
for i = 1: length(train_y)
    size_train(train_y(i,1),1) = size_train(train_y(i,1),1)+ 1;
end

for i = 1: length(test_y)
    size_test( test_y(i,1),1) = size_test(test_y(i,1),1) + 1; 
end

last = 1;
for i = 1 : 20
    train_mean(i,:) = mean(train_data( last:last + size_train(i,1) - 1 ,:));
    last = last + size_train(i,1);
end

correct = 0;
wrong = 0;
ntest_types = 20;
nstart_idx = 8;
ntests_per_type = 20;
fprintf('test begin \n');

for idx = nstart_idx : ntest_types
    eidx = sum(size_test(1:idx));
    sidx = eidx - size_test(idx) + 1;
    test_idx = sidx + randi(size_test(idx), 20 ,1) - 1;
    for l = 1:20
        j = test_idx(l);
        min = inf;
        minId = 0;
        for i = nstart_idx : ntest_types
            total_dist = 0;
            for k = 1: ndim
                y = k:6:dims-6+k;
                [dist] = dtw(train_mean(i,y)',test_data(j,y)',30);
                total_dist = total_dist + dist;
            end
            
            if total_dist < min
                min = total_dist;
                minId = i;
            end
        end   
        real_type = idx;
        pred_type = minId;
        if real_type == pred_type
            correct = correct + 1;
        else
            fprintf('wrong guess at %dth item test set! real : %d, calc: %d\n',j ,real_type, pred_type);
            wrong = wrong + 1;
        end
    end
    fprintf('just tested: 20 tests. currect: %dth \n', idx * ntests_per_type);
end

rate = correct / ((ntest_types - nstart_idx + 1) * ntests_per_type);
fprintf('total rate %f\ncorrect: %d\nwrong %d\n',rate,correct,wrong);
