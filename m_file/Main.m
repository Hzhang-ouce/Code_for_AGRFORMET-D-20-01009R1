clc
clear
close

% %
% �˳�������������е�Excel�����ȡ�¶ȡ��������ݣ������ս�ˮ������ҹ��������������������(�˹�������xls2mat�ű�ʵ�֣���
% �������ݡ���ˮ���ݡ��ǽ�ˮ���ݷֱ����0.5��ƽ����Ȼ�����9����������ϣ�
% ��Ͻ�����Ϊ3��Excel���

%% ·������
MatOutPutDataPath = 'C:\Users\chenzw\Desktop\mat';  %% �ļ�����ֻ���Ǵ�mat�ļ���Only mat files can exist in the folder)
ExcelOutPutDataPath = 'C:\Users\chenzw\Desktop\xls';

%% mat��Ϣ��ȡ
if isempty(dir(MatOutPutDataPath))==0
    DataDir = dir(MatOutPutDataPath);            % ���������ļ�
    TITLE = cell(length(DataDir)-2,1);
    for ii = 1:length(DataDir)-2
        TITLE{ii} = DataDir(ii+2).name;
        TITLE{ii} = TITLE{ii}(1:end-4);
    end
end

%% ��ͷ����
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
% parpool  %% �������г�
parfor ii = 1:length(TITLE)
    
    %% ���ݵ��롢��������
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
        
        %% �ж�������Ч��
        if rateQC0 > 0.2
            warning on
            warning([TITLE{ii},'''s data are invalid']);
            warning off
        else
            StationYearID = [StationYearID,ii];
            
            %% ��ˮ���ǽ�ˮ�������ݽ���0.5��ƽ��
            NTdata = Average_05_and_constant([TA.NT.yes.data,NEE.NT.yes.data]);      % ˵��:TAΪ�¶ȣ�NEEΪ������NTΪҹ�䣻PFΪ��ˮ��
            PFNTdata = Average_05_and_constant([TA.PFNT.data,NEE.PFNT.data]);        % ����TA.noPFNT.dataָ�޽�ˮҹ����¶����ݣ�
            noPFNTdata = Average_05_and_constant([TA.noPFNT.data,NEE.noPFNT.data]);  %     NEE.PFNT.dataΪ�н�ˮҹ��ĺ������ݡ�
            
            %% ��վ�������ݻ���
            all_NTdata{ii} = NTdata;
            all_PFNTdata{ii} = PFNTdata;
            all_noPFNTdata{ii} = noPFNTdata;
            
            %% ��ȡ�¶���������ݵ����ֵ����Сֵ��ƽ��ֵ����λ��������
            DataDescription(:,ii) = ...
                [max(TA.NT.yes.data);max(NEE.NT.yes.data);max(TA.PFNT.data);max(NEE.PFNT.data);max(TA.noPFNT.data);max(NEE.noPFNT.data);
                min(TA.NT.yes.data);min(NEE.NT.yes.data);min(TA.PFNT.data);min(NEE.PFNT.data);min(TA.noPFNT.data);min(NEE.noPFNT.data);
                nanmean(TA.NT.yes.data);nanmean(NEE.NT.yes.data);nanmean(TA.PFNT.data);nanmean(NEE.PFNT.data);nanmean(TA.noPFNT.data);nanmean(NEE.noPFNT.data);
                nanmedian(TA.NT.yes.data);nanmedian(NEE.NT.yes.data);nanmedian(TA.PFNT.data);nanmedian(NEE.PFNT.data);nanmedian(TA.noPFNT.data);nanmedian(NEE.noPFNT.data);
                mode05(TA.NT.yes.data);mode05(NEE.NT.yes.data);mode05(TA.PFNT.data);mode05(NEE.PFNT.data);mode05(TA.noPFNT.data);mode05(NEE.noPFNT.data)];
            %% �ֱ����9�������������
            DataInfo_T_HH = nan(length(Row1)-1,9);
            ModelName = {'FitLinear','FitQuadratic','FitPower','FitExp_Arrhenius',...
                'FitExp_vantHoff','FitExp_Hunt','FitExp_LT','FitLogistic','FitArctangent'};
            
            % �����������
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
            
            % ��ˮ�������
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
            
            % �ǽ�ˮ�������
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

% delete(gcp('nocreate'))  % �رղ��г�

% %%  �������վ�����������ܵ����
% NTdata = cell2mat(all_NTdata);
% PFNTdata = cell2mat(all_PFNTdata);
% noPFNTdata = cell2mat(all_noPFNTdata);
% % ��ȡ�¶���������ݵ����ֵ����Сֵ��ƽ��ֵ����λ��������
% DataDescription(:,ii) = ...
%     [max(TA.NT.yes.data);max(NEE.NT.yes.data);max(TA.PFNT.data);max(NEE.PFNT.data);max(TA.noPFNT.data);max(NEE.noPFNT.data);
%     min(TA.NT.yes.data);min(NEE.NT.yes.data);min(TA.PFNT.data);min(NEE.PFNT.data);min(TA.noPFNT.data);min(NEE.noPFNT.data);
%     nanmean(TA.NT.yes.data);nanmean(NEE.NT.yes.data);nanmean(TA.PFNT.data);nanmean(NEE.PFNT.data);nanmean(TA.noPFNT.data);nanmean(NEE.noPFNT.data);
%     nanmedian(TA.NT.yes.data);nanmedian(NEE.NT.yes.data);nanmedian(TA.PFNT.data);nanmedian(NEE.PFNT.data);nanmedian(TA.noPFNT.data);nanmedian(NEE.noPFNT.data);
%     mode05(TA.NT.yes.data);mode05(NEE.NT.yes.data);mode05(TA.PFNT.data);mode05(NEE.PFNT.data);mode05(TA.noPFNT.data);mode05(NEE.noPFNT.data)];
% % �ֱ����9�������������
% DataInfo_T_HH = nan(length(Row1)-1,9);
% ModelName = {'FitLinear','FitQuadratic','FitPower','FitExp_Arrhenius',...
%     'FitExp_vantHoff','FitExp_Hunt','FitExp_LT','FitLogistic','FitArctangent'};
% 
% % �����������
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
% % ��ˮ�������
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
% % �ǽ�ˮ�������
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

%% ��������Ϊ����
DataInfo_T_HH_Result = cell2mat(DataInfo_T);
DataInfo_T_HH_Precipitation_Result = cell2mat(DataInfo_T_Precipitation);
DataInfo_T_HH_NonPrecipitation_Result = cell2mat(DataInfo_T_NonPrecipitation);



%% ��DataDescription���������������
% ��������кϲ���ֻ��ע�͵�ǰ�ڡ�
[~,a] = find(isnan(DataDescription(1,:)));
DataDescription(:,a) = [];
[~,b] = size(DataDescription);
DataDescriptionLarge = nan(length(Row2),9*b);         %�˴���bΪ��Ч���ݼ�����
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
    for jj = 1:9                 %% ע��˴�����eval
        i = find(StationYearID==ii);
        Line1{jj+(i-1)*9} = [TITLE{ii},'_',num2str(eval(num2str(jj)))];
    end
end

%% �������ΪExcel
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



