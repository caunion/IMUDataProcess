%% Generate Frequency Feature over Single Item
% Author: Jia Daoyuan
% Data  : 14/4/23
% Input : filtered and interpolated item, a 6-by-N matrix; dim 1 to 3 are
%         respectively liear acc of dim x, y, z; dim 4 to 6 are 3 dim of
%         gyro data.
% Output : a 1x48 feature vector. Respectively acc and gyro mean * 6;
%          acc and gyro standard deviation * 6; acc and gyro variance * 6;
%          acc and gyro interquartile range * 6; acc correlation
%          coefficient * 3, gyro correlation coefficient * 3; acc and gyro
%          MAD * 6; acc and gyro root mean square * 6; acc and gyro
%          energy (mean square of DFT items)* 6
%
function [feature] = SingleFeatureGen(iitem)
    [m,n] = size(iitem);
    feature = [];
    if m ~= 6
        return;
    end
    lacc = iitem(1:3,:);
    gyro = iitem(4:6,:);
    
    Mean = mean(lacc,2);
    feature(end+1:end+3,:) = Mean;
    Mean = mean(gyro,2);
    feature(end+1:end+3,:) = Mean;
    
    Std  = std(lacc,0,2);
    feature(end+1:end+3,:) = Std;
    Std  = std(gyro,0,2);
    feature(end+1:end+3,:) = Std;
    
    Var  = var(lacc,0,2);
    feature(end+1:end+3,:) = Var;
    Var  = var(gyro,0,2);
    feature(end+1:end+3,:) = Var;
    
    Iqr  = iqr(lacc,2);
    feature(end+1:end+3,:) = Iqr;
    Iqr  = iqr(gyro,2);
    feature(end+1:end+3,:) = Iqr;
    
    CORRM= corr(lacc');
    Corr = [CORRM(1,2),CORRM(1,3),CORRM(2,3)]';
    feature(end+1:end+3,:) = Corr;
    CORRM= corr(gyro');
    Corr = [CORRM(1,2),CORRM(1,3),CORRM(2,3)]';
    feature(end+1:end+3,:) = Corr;
    
    Mad  = mad(lacc,0,2);
    feature(end+1:end+3,:) = Mad;
    Mad  = mad(gyro,0,2);
    feature(end+1:end+3,:) = Mad;
    
    Rms  = rms(lacc,2);
    feature(end+1:end+3,:) = Rms;
    Rms  = rms(gyro,2);
    feature(end+1:end+3,:) = Rms;
    
    Energy = mad(fft(lacc,[],2),0,2).^2;
    feature(end+1:end+3,:) = Energy;
    Energy = mad(fft(gyro,[],2),0,2).^2;
    feature(end+1:end+3,:) = Energy;
    
    feature = feature';
end