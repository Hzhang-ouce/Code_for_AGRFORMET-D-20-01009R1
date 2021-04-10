function [ Modified_table_out ] = Average_05_and_constant( Raw_Table_in )
%This function is to calculate expected respiration by a constant.
%Written by Huanyuan Zhang in December 2018
%Input table must be an 2-d array with two columns, temperature on the left
%and respiration on the right, no headers.
if isempty(Raw_Table_in)
    Modified_table_out = [];
else

%% remove of outliers ( 4d method )
RES = Raw_Table_in(:,2);
MEAN = nanmean(RES);
AD = nanmean(abs(RES-MEAN));
RES(RES>4*AD-MEAN | RES<MEAN-4*AD)=NaN;
a = find(isnan(RES),1);
Raw_Table_in(a,:)=[];
% if ~isempty(a)
% disp(['第',num2str(a),'个数据是偏离值。']);
% end
    

%% convert to table
Raw_Table=Raw_Table_in;

%% 
TA_max = max(Raw_Table(:,1));
TA_min = min(Raw_Table(:,1));
n = (round(TA_max)-round(TA_min))/0.5+1;  %%按0.5取平均的观察数
N = length(Raw_Table);  
m = ceil(N/(n-1))-1;  %%每m个数求平均
M = m;
Raw_Table = sortrows(Raw_Table,-1);  %%表格降序排列
TA = Raw_Table(:,1);
NEE = Raw_Table(:,2);

% 假设原来这个站点年有N个记录，于是每ceil(N/n)取一个平均。
% 现在的新做法是：把原记录从低温到高温排列，假设ceil(N/n)=100，于是第1 to 50（最低温）个点取一个平均值，
% 第51 to 100个点取一个平均值，第（N-50）to  N 个点 （最高温）取一个平均值，
% 第 （N-100）to(N-51）个点又取一个平均值。
a1 = nanmean(TA(1:M));
a2 = nanmean(TA(1+M:2*M));
a3 = nanmean(TA(end-M+1:end));
a4 = nanmean(TA(end-2*M+1:end-M));
b1 = nanmean(NEE(1:M));
b2 = nanmean(NEE(1+M:2*M));
b3 = nanmean(NEE(end-M+1:end));
b4 = nanmean(NEE(end-2*M+1:end-M));
% 剩下的点再套用0.5度平均的算法。
x = Average_By_05(Raw_Table);
% 两种算法得到的数据合并
a_front = find(x(:,1)<a4);
a_behind = find(x(:,1)>a2);
if isempty(a_front)==0
x(1:a_front(end),:) = NaN;
end
if isempty(a_behind)==0
x(a_behind(1):end,:)=NaN;
end
[y1,~] = find(isnan(x));
x(y1,:) = [];
a = [a3;a4;x(:,1);a2;a1];
b = [b3;b4;x(:,2);b2;b1];
Modified_table_out = [a,b];
   
end
end