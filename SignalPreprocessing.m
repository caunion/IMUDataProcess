%% Feature Extraction from Gesture Data
% Author: Daoyuan jia
% Data  : 2014/4/22
function do()
   clear;
   doanyway = true;
   if ~exist('rdata.mat','file') || doanyway
       read();
   end
   load('rdata.mat');
   
   if ~exist('fstruct.mat','file') || doanyway
        filter(rawdata);
   end
   load('fstruct.mat');
   
   if ~exist('idata.mat','file') || doanyway
        interpolate(fdata,maxl);
   end
   load('idata.mat');
   
   if ~exist('rfeature.mat','file') || doanyway
        featuregen(idata);
   end
   load('rfeature.mat');
   
   
end

function [rfeatures] = featuregen(idata)
    [m,n] = size(idata);
    rfeatures = zeros(floor(m/6),48);
    idx = 1;
    for i = 1:6:m
        iitem = idata(i:i+5,:);
        [feature] = SingleFeatureGen(iitem);
        rfeatures(idx,:) = feature;
        idx = idx + 1; 
    end
    
    save('rfeature.mat','rfeatures');
end

function [idata] = interpolate(fdata,maxl)
    idata = zeros(length(fdata) * 6, maxl);
    idx = 1;
    for i = 1 : length(fdata)
        idata_item = [];
        item = fdata{i};
        len  = length(item);
        ndiff = maxl - len;
        if ndiff > 0
            interp_pos = floor(interp1([1,ndiff+2],[1,len],[1+1:ndiff+1],'linear'));
            last_pos = 0;
            count = 1;
            for j = 1: length(interp_pos)
                pos = interp_pos(j);
                if last_pos == pos
                    count = count + 1;
                    continue;
                end
                
                %backup old data
                for old = last_pos : pos
                     if old == 0
                         continue;
                     end
                     idata_item(end + 1,:) = item(old,:);
                end
                
                
                %interpolate
                buf = zeros(count,6);
                for dim = 1:6
                   x = [1,count+2];
                   y = [item(pos,dim),item(pos+1,dim)];
                   buf(:,dim) = interp1(x,y,[2:count+1],'linear');
                end
                idata_item(end + 1,:) = buf;                
                last_pos = pos+1;
            end
            
            %back up old data remains
            for old = last_pos : length(item)
                 if old == 0
                    continue;
                 end
                 idata_item(end + 1,:) = item(old,:);
            end
            
            idata(i*6-5: i*6,:) = idata_item';
        else
            idata(i*6-5: i*6,:) = item';
        end
            
    end
    
    save('idata.mat','idata');
end

%
%
%
function [fstruct] = filter(rawdata)
   minl = 1000000000;
   maxl = 0;
   n = length(rawdata);
   fdata = cell(n,1);
   idx  = 1;
   for i = 1: n
        item        = rawdata{i};
        mindim     = min(length(item.linear_acc{1}),length(item.gyro{1}));
        if mindim < minl
            minl = mindim;
        end
        if mindim > maxl
            maxl = mindim;
        end;
            
        matrix      = item.linear_acc{1}(1:mindim,:);
        new_item    = zeros(length(matrix),6);
        new_item(:,1:3)  = average_filter(matrix,8); %process acc data with avg filter, window size 8
        
        matrix      = item.gyro{1}(1:mindim,:);
        new_item(:,4:6) = average_filter(matrix,8); %process gyro data with avg filter, window size 8
        
        fdata{idx} = new_item;
        idx = idx + 1;
   end
   fstruct = struct('fdata',{fdata},'minl',{minl},'maxl',{maxl});
   save('fstruct.mat','-struct','fstruct');
end

function [type] = name2type(name)
    switch name
        case{'顺时针画圈'}, type = 1;
        case{'逆时针画圈'}, type = 2;
        case{'画勾（V）'}, type = 3;
        case{'画叉（X）'}, type = 4;
        case{'数字1'}, type = 5;
        case{'数字2'}, type = 6;
        case{'数字3'}, type = 7;
        case{'数字4'}, type = 8;
        case{'数字5'}, type = 9;
        case{'数字6'}, type = 10;
        case{'数字7'}, type = 11;
        case{'数字8'}, type = 12;
        case{'数字9'}, type = 13;
        case{'数字10'}, type = 14;
        otherwise, type = 15;
    end;
end
function [rawdata,rawlabel] = read()
    dataPath    = 'D:\微云网盘\357812021\DropBox\Dropbox\Lab\毕设\dataset\第三期\动作传感器数据收集\张晓泉\action_records\';
    %init data
    folders     = get_folders(dataPath);
    rawdata = cell(length(folders),1);
    rawlabel = zeros(length(folders),1);
    idx = 1;
    for i = 1: length(folders)
        folder = strcat(dataPath,folders{i},'\');
        files = get_files(folder);
        item = struct('linear_acc', [] ,'gyro',[]);
        type = 100;
        for j = 1:length(files)
            file_name = files{j};
            file =  strcat(folder, file_name);
            n = regexp(file_name,'(?<sensor>[\x00-\xff]+)_(?<type>[^\x00-\xff][^_]+)_(?<time>\d)s','names');
            type = name2type(n.type);
            if strcmp(n.sensor,'linear_acc') || strcmp(n.sensor,'gyro')
                [item_data,item_timestamp,ret,m] = read_file(file);
                if ret < 0
                    fprintf('error read file %s',file);
                    continue;
                end
                item.(n.sensor) = {item_data, item_timestamp};
            end  
        end
        rawdata{idx} = item;
        rawlabel(idx) = type;
        idx = idx + 1;
    end
    [rawlabel,I] = sort(rawlabel);
    rawdata = rawdata(I);
    save ('rdata.mat','rawdata','rawlabel');
end

function [fData] = average_filter(data, window)
    [m,dims]= size(data);
    fData = zeros(m,dims);
    hwindow = floor(window/2);
    for i = 1:dims
        for j = 1 : m
            pool = zeros(window,1);
            idx = 1;
            for k = j : j + window -1
                l = 0;
                if k > 0
                    l = k;
                end
                if k > m
                    l = m;
                end
                pool(idx) = data(l,i);
                idx = idx+1;
            end
            fData(j,i) = mean(pool);
        end
    end
end

function [data,timestamps,ret,m] = read_file(fname)
    timestamps = [];
    data = [];
    [fid,m] = fopen(fname,'r','b'); %java is big endian
    if fid < 0
        ret  = -1;
        return;
    end
    idx = 1;
    finfo = dir(fname);
    fsize = finfo.bytes;
    linesize = 3*4 + 1*8; % 3 float(3*4B) for values of 3 dim, 1 long(1*8B) for timestamp
    n = fsize / linesize;
    data = zeros(n,3);
    timestamps = zeros(n,1);
    while idx <= n
        data(idx,:) = [fread(fid,3,'float=>float')'];
        timestamps(idx) = fread(fid,1,'uint64=>uint64');
        idx = idx +1;
    end
    
    ret = 1;
    fclose(fid);
    return;
end

function [nameFolds] = get_folders(pathFolder)
    d = dir(pathFolder);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];
end

function [files] = get_files(folder)
    d = dir(folder);
    isub = ~[d(:).isdir]; %# returns logical vector
    files = {d(isub).name}';
    files(ismember(files,{'.','..'})) = [];
end

function [fData] = resample()

end

function [fData] = middle_filter(data,window)
    [m,dims]= size(data);
    fData = zeros(m,dims);
    hwindow = floor(window /2);
    for i = 1:dims
        for j = 1:m
            pool = zeros(window,1);
            idx = 1;
           for k = j - hwindow: j+ hwindow
                l = 0
                if k > 0  
                    l= k;
                end
                if k > m
                    l = m;
                end
                pool(idx) = data(l,j);
                idx = idx + 1;
           end
           y = sort(pool);
           fData(j,i) = y(hwindow);
        end
    end
end