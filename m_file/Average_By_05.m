function [ Modified_table_out ] = Average_By_05( Raw_Table_in )
%This function is to calculate expected respiration under 0.5 interval of
%temperature, Written by Huanyuan Zhang in December 2018
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
Raw_Table=array2table(Raw_Table);


%% Read file

    
%Raw_Table=readtable(fileName{filecount},'ReadVariableNames',true);%read raw table

%Raw_Table(Raw_Table.NIGHT==0,:)=[]; %Delete anything in daytime; anything night=1
%Raw_Table=Raw_Table(:,{'TA_F','NEE_CUT_MEAN'});%we only want temperature and respiration
func = @(x) (round(x*2))/2; %round temperature to 0.5 interval
Raw_Table(:,'Raw_Table1')=varfun(func,Raw_Table(:,'Raw_Table1'));
Modified_table=varfun(@nanmean,Raw_Table,'GroupingVariables','Raw_Table1');%find mean respiration for any temperature point
%save(sprintf('mean_%s.mat',fileName{filecount}),'Modified_table');
Modified_table(:,2)=[];
Modified_table=table2array(Modified_table);
Modified_table_out=Modified_table;
end
end