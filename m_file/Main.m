clc
clear
close

% %
% 此程序用于针对已有的Excel表格，提取温度、呼吸数据，并按照降水与否和昼夜分类整理，保存上述数据(此功能现以xls2mat脚本实现）；
% 对总数据、降水数据、非降水数据分别进行0.5℃平均，然后进行9个函数的拟合；
% 拟合结果输出为3个Excel表格。

%% 路径设置
MatOutPutDataPath = 'C:\Users\chenzw\Desktop\mat';  %% 文件夹中只能是纯mat文件（Only mat files can exist in the folder)
ExcelOutPutDataPath = 'C:\Users\chenzw\Desktop\xls';

%% mat信息获取
if isempty(dir(MatOutPutDataPath))==0
    DataDir = dir(MatOutPutDataPath);            % 遍历所有文件
    TITLE = cell(length(DataDir)-2,1);
    for ii = 1:length(DataDir)-2
        TITLE{ii} = DataDir(ii+2).name;
        TITLE{ii} = TITLE{ii}(1:end-4);
    end
end

%% 表头制作
Row1 = {'VariableName',...
    'ModelNum', 'NumObs',...
    'Rsquared', 'RMSE', 'AIC', 'AICc', 'BIC',...
    'Para1_Estimated', 'Para1_SE', 'Para1_p', 'Para2_Estimated', 'Para2_SE', 'Para2_p','Para3_Estimated', 'Para3_SE', 'Para3_p', 'Para4_Estimated', 'Para4_SE', 'Para4_p',...
    'Tref', 'Q10', 'Tmin', 'Rref',...
    'Normality_Residual_Raw', 'Normality_Residual_Pearson', 'Normality_Residual_Student','Normality_Resudual_Standard','p_value_f_test',...
    'R_12', 't_12', 'p_12', 'R_13', 't_13', 'p_13', 'R_23', 't_23', 'p_23'};
Row2 = {'TemperatureMAX';'RespirationMAX';'PrecipitationTemperatureMAX';
    'PrecipitationRespirationMAX';'NonPrecipitationTemperatureMAX';'NonPrecipitationRespirationMAX';
    'TemperatureMIN';'RespirationMIN';'PrecipitationTemperatureMIN';
    'PrecipitationRespirationMIN';'NonPrecipitationTemperatureMIN';'NonPrecipitationRespirationMIN';
    'TemperatureMEAN';'RespirationMEAN';'PrecipitationTemperatureMEAN';
    'PrecipitationRespirationMEAN';'NonPrecipitationTemperatureMEAN';'NonPrecipitationRespirationMEAN';
    'TemperatureMEDIAN';'RespirationMEDIAN';'PrecipitationTemperatureMEDIAN';
    'PrecipitationRespirationMEDIAN';'NonPrecipitationTemperatureMEDIAN';'NonPrecipitationRespirationMEDIAN';
    'TemperatureMODE';'RespirationMODE';'PrecipitationTemperatureMODE';
    'PrecipitationRespirationMODE';'NonPrecipitationTemperatureMODE';'NonPrecipitationRespirationMODE'};


DataDescription = nan(length(Row2),length(TITLE));
DataInfo_T = cell(1,length(TITLE));
DataInfo_T_Precipitation = cell(1,length(TITLE));
DataInfo_T_NonPrecipitation = cell(1,length(TITLE));
StationYearID = [];
all_NTdata = cell(length(TITLE),1);
all_PFNTdata = cell(length(TITLE),1);
all_noPFNTdata = cell(length(TITLE),1);
%%
% parpool  %% 开启并行池
parfor ii = 1:length(TITLE)
    
    %% 数据导入、整理、保存
    mytitle = TITLE{ii};
    
    if exist([MatOutPutDataPath,'\',mytitle,'.mat'],'file') == 2
        Temp = load([MatOutPutDataPath,'\',mytitle,'.mat']);
        TA = Temp.TA;
        NEE = Temp.NEE;
        rateQC0 = Temp.rateQC0;
    end
    
    % for ii = 1:length(TITLE)
    %     mytitle = TITLE{ii};
    %     if exist([MatOutPutDataPath,'\',mytitle,'.mat'])
    %         load([MatOutPutDataPath,'\',mytitle,'.mat']);
    %     else
    %         [bianl,~,TA,NEE,~,~,rateQC0] = DataLoadQCFilter(Title{ii});
    %     end
    
    if isempty(TA)==0 && isempty(NEE)==0
        
        %% 判断数据有效性
        if rateQC0 > 0.2
            warning on
            warning([TITLE{ii},'''s data are invalid']);
            warning off
        else
            StationYearID = [StationYearID,ii];
            
            %% 降水、非降水、总数据进行0.5℃平均
            NTdata = Average_05_and_constant([TA.NT.yes.data,NEE.NT.yes.data]);      % 说明:TA为温度；NEE为呼吸；NT为夜间；PF为降水；
            PFNTdata = Average_05_and_constant([TA.PFNT.data,NEE.PFNT.data]);        % 例：TA.noPFNT.data指无降水夜间的温度数据；
            noPFNTdata = Average_05_and_constant([TA.noPFNT.data,NEE.noPFNT.data]);  %     NEE.PFNT.data为有降水夜间的呼吸数据。
            
            %% 各站点年数据汇总
            all_NTdata{ii} = NTdata;
            all_PFNTdata{ii} = PFNTdata;
            all_noPFNTdata{ii} = noPFNTdata;
            
            %% 求取温度与呼吸数据的最大值、最小值、平均值、中位数、众数
            DataDescription(:,ii) = ...
                [max(TA.NT.yes.data);max(NEE.NT.yes.data);max(TA.PFNT.data);max(NEE.PFNT.data);max(TA.noPFNT.data);max(NEE.noPFNT.data);
                min(TA.NT.yes.data);min(NEE.NT.yes.data);min(TA.PFNT.data);min(NEE.PFNT.data);min(TA.noPFNT.data);min(NEE.noPFNT.data);
                nanmean(TA.NT.yes.data);nanmean(NEE.NT.yes.data);nanmean(TA.PFNT.data);nanmean(NEE.PFNT.data);nanmean(TA.noPFNT.data);nanmean(NEE.noPFNT.data);
                nanmedian(TA.NT.yes.data);nanmedian(NEE.NT.yes.data);nanmedian(TA.PFNT.data);nanmedian(NEE.PFNT.data);nanmedian(TA.noPFNT.data);nanmedian(NEE.noPFNT.data);
                mode05(TA.NT.yes.data);mode05(NEE.NT.yes.data);mode05(TA.PFNT.data);mode05(NEE.PFNT.data);mode05(TA.noPFNT.data);mode05(NEE.noPFNT.data)];
            %% 分别针对9个函数进行拟合
            DataInfo_T_HH = nan(length(Row1)-1,9);
            ModelName = {'FitLinear','FitQuadratic','FitPower','FitExp_Arrhenius',...
                'FitExp_vantHoff','FitExp_Hunt','FitExp_LT','FitLogistic','FitArctangent'};
            
            % 所有数据拟合
            DataInfo_T_HH(:,1) = FitLinear(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,2) = FitQuadratic(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,3) = FitPower(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,4) = FitExp_Arrhenius(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,5) = FitExp_vantHoff(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,6) = FitExp_Hunt(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,7) = FitExp_LT(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,8) = FitLogistic(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,9) = FitArctangent(NTdata(:,1),NTdata(:,2),TITLE{ii});
            DataInfo_T{ii} = DataInfo_T_HH;
            
            % 降水数据拟合
            DataInfo_T_HH(:,1) = FitLinear(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,2) = FitQuadratic(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,3) = FitPower(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,4) = FitExp_Arrhenius(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,5) = FitExp_vantHoff(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,6) = FitExp_Hunt(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,7) = FitExp_LT(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,8) = FitLogistic(PFNTdata(:,1),PFNTdata(:,2),mytitle);
            DataInfo_T_HH(:,9) = FitArctangent(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
            DataInfo_T_Precipitation{ii} = DataInfo_T_HH;
            
            % 非降水数据拟合
            DataInfo_T_HH(:,1) = FitLinear(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,2) = FitQuadratic(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,3) = FitPower(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,4) = FitExp_Arrhenius(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,5) = FitExp_vantHoff(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,6) = FitExp_Hunt(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,7) = FitExp_LT(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,8) = FitLogistic(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_HH(:,9) = FitArctangent(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
            DataInfo_T_NonPrecipitation{ii} = DataInfo_T_HH;
            disp(['The regressions of ',TITLE{ii},' are finished.']);
        end
    end
end

% delete(gcp('nocreate'))  % 关闭并行池

% %%  针对所有站点年数据做总的拟合
% NTdata = cell2mat(all_NTdata);
% PFNTdata = cell2mat(all_PFNTdata);
% noPFNTdata = cell2mat(all_noPFNTdata);
% % 求取温度与呼吸数据的最大值、最小值、平均值、中位数、众数
% DataDescription(:,ii) = ...
%     [max(TA.NT.yes.data);max(NEE.NT.yes.data);max(TA.PFNT.data);max(NEE.PFNT.data);max(TA.noPFNT.data);max(NEE.noPFNT.data);
%     min(TA.NT.yes.data);min(NEE.NT.yes.data);min(TA.PFNT.data);min(NEE.PFNT.data);min(TA.noPFNT.data);min(NEE.noPFNT.data);
%     nanmean(TA.NT.yes.data);nanmean(NEE.NT.yes.data);nanmean(TA.PFNT.data);nanmean(NEE.PFNT.data);nanmean(TA.noPFNT.data);nanmean(NEE.noPFNT.data);
%     nanmedian(TA.NT.yes.data);nanmedian(NEE.NT.yes.data);nanmedian(TA.PFNT.data);nanmedian(NEE.PFNT.data);nanmedian(TA.noPFNT.data);nanmedian(NEE.noPFNT.data);
%     mode05(TA.NT.yes.data);mode05(NEE.NT.yes.data);mode05(TA.PFNT.data);mode05(NEE.PFNT.data);mode05(TA.noPFNT.data);mode05(NEE.noPFNT.data)];
% % 分别针对9个函数进行拟合
% DataInfo_T_HH = nan(length(Row1)-1,9);
% ModelName = {'FitLinear','FitQuadratic','FitPower','FitExp_Arrhenius',...
%     'FitExp_vantHoff','FitExp_Hunt','FitExp_LT','FitLogistic','FitArctangent'};
% 
% % 所有数据拟合
% DataInfo_T_HH(:,1) = FitLinear(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,2) = FitQuadratic(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,3) = FitPower(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,4) = FitExp_Arrhenius(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,5) = FitExp_vantHoff(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,6) = FitExp_Hunt(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,7) = FitExp_LT(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,8) = FitLogistic(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,9) = FitArctangent(NTdata(:,1),NTdata(:,2),TITLE{ii});
% DataInfo_T{ii} = DataInfo_T_HH;
% 
% % 降水数据拟合
% DataInfo_T_HH(:,1) = FitLinear(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,2) = FitQuadratic(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,3) = FitPower(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,4) = FitExp_Arrhenius(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,5) = FitExp_vantHoff(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,6) = FitExp_Hunt(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,7) = FitExp_LT(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,8) = FitLogistic(PFNTdata(:,1),PFNTdata(:,2),mytitle);
% DataInfo_T_HH(:,9) = FitArctangent(PFNTdata(:,1),PFNTdata(:,2),TITLE{ii});
% DataInfo_T_Precipitation{ii} = DataInfo_T_HH;
% 
% % 非降水数据拟合
% DataInfo_T_HH(:,1) = FitLinear(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,2) = FitQuadratic(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,3) = FitPower(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,4) = FitExp_Arrhenius(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,5) = FitExp_vantHoff(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,6) = FitExp_Hunt(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,7) = FitExp_LT(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,8) = FitLogistic(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_HH(:,9) = FitArctangent(noPFNTdata(:,1),noPFNTdata(:,2),TITLE{ii});
% DataInfo_T_NonPrecipitation{ii} = DataInfo_T_HH;
% disp('The regressions are finished.');

%% 数据整理为矩阵
DataInfo_T_HH_Result = cell2mat(DataInfo_T);
DataInfo_T_HH_Precipitation_Result = cell2mat(DataInfo_T_Precipitation);
DataInfo_T_HH_NonPrecipitation_Result = cell2mat(DataInfo_T_NonPrecipitation);



%% 将DataDescription并入其他三个表格
% 若不想进行合并，只需注释当前节。
[~,a] = find(isnan(DataDescription(1,:)));
DataDescription(:,a) = [];
[~,b] = size(DataDescription);
DataDescriptionLarge = nan(length(Row2),9*b);         %此处的b为有效数据集个数
[~,c] = size(DataInfo_T_HH_Result);
for ii = 1:c/9
    for jj = 1:9
        DataDescriptionLarge(:,(ii-1)*9+jj) = DataDescription(:,ii);
    end
end

Row1 = [Row1,Row2'];
DataInfo_T_HH_Result = [DataInfo_T_HH_Result;DataDescriptionLarge];
DataInfo_T_HH_NonPrecipitation_Result = [DataInfo_T_HH_NonPrecipitation_Result;DataDescriptionLarge];
DataInfo_T_HH_Precipitation_Result = [DataInfo_T_HH_Precipitation_Result;DataDescriptionLarge];

Line1 = cell(1,b*9);
for ii = StationYearID
    for jj = 1:9                 %% 注意此处存在eval
        i = find(StationYearID==ii);
        Line1{jj+(i-1)*9} = [TITLE{ii},'_',num2str(eval(num2str(jj)))];
    end
end

%% 数据输出为Excel
xlswrite([ExcelOutPutDataPath,'\SummaryData.xlsx'],Row1);
% xlswrite([ExcelOutPutDataPath,'\SummaryData.xlsx'],Line1','sheet1','A2');
xlswrite([ExcelOutPutDataPath,'\SummaryData.xlsx'],DataInfo_T_HH_Result','sheet1','B2');

xlswrite([ExcelOutPutDataPath,'\SummaryDataPrecipitation.xlsx'],Row1);
% xlswrite([ExcelOutPutDataPath,'\SummaryDataPrecipitation.xlsx'],Line1','sheet1','A2');
xlswrite([ExcelOutPutDataPath,'\SummaryDataPrecipitation.xlsx'],DataInfo_T_HH_Precipitation_Result','sheet1','B2');

xlswrite([ExcelOutPutDataPath,'\SummaryDataNonPrecipitation.xlsx'],Row1);
% xlswrite([ExcelOutPutDataPath,'\SummaryDataNonPrecipitation.xlsx'],Line1','sheet1','A2');
xlswrite([ExcelOutPutDataPath,'\SummaryDataNonPrecipitation.xlsx'],DataInfo_T_HH_NonPrecipitation_Result','sheet1','B2');

xlswrite([ExcelOutPutDataPath,'\DataDescription.xlsx'],Row2','sheet1','B1');
% xlswrite([ExcelOutPutDataPath,'\DataDescription.xlsx'],TITLE,'sheet1','A2');
xlswrite([ExcelOutPutDataPath,'\DataDescription.xlsx'],DataDescription','sheet1','B2');



