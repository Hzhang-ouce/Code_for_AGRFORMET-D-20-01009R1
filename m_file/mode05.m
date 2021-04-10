function [Modified_table_out]=mode05(Raw_Table_in)

if isempty(Raw_Table_in)
    Modified_table_out = [];
else

%% convert to table
Raw_Table=Raw_Table_in;
Raw_Table=array2table(Raw_Table);


%% Read filez

    
%Raw_Table=readtable(fileName{filecount},'ReadVariableNames',true);%read raw table

%Raw_Table(Raw_Table.NIGHT==0,:)=[]; %Delete anything in daytime; anything night=1
%Raw_Table=Raw_Table(:,{'TA_F','NEE_CUT_MEAN'});%we only want temperature and respiration
func = @(x) (round(x*2))/2; %round temperature to 0.5 interval
row=varfun(func,Raw_Table(:,'Raw_Table'));
row=table2array(row);
Modified_table_out=mode(row);
end
end