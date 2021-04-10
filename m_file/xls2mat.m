clc
clear
close all

%% 
% �ýű����ڽ�xls�ļ�ת��Ϊmat�ļ�
% ���룺xls��ʽ
% �����mat��ʽ��'TA','NEE','mytitle','rateQC0'��

%% ·������
LoadInDataPath = 'C:\Users\chenzw\Desktop\example_data';
MatOutPutDataPath = 'C:\Users\chenzw\Desktop\mat';

%% Excel��Ϣ��ȡ
Title = {};
DataDir = dir(LoadInDataPath);            % ���������ļ�
for i = 1:length(DataDir)
    if(isequal(DataDir(i).name,'.')||...            % ȥ��ϵͳ�Դ����������ļ���
            isequal(DataDir(i).name,'..')||...
            ~DataDir(i).isdir)            % ȥ�������в����ļ��е�
        continue;
    end
    xlsDir = dir([LoadInDataPath,'\',DataDir(i).name,'\*.xls']);           %��ȡ��Ŀ¼���������ļ����е�xls�ļ���
    
    for iii = 1:length(xlsDir)
        Title = [Title,[xlsDir(iii).folder,'\',xlsDir(iii).name]];                  %·��+�ļ���
    end
    
end

TITLE = {};
for i  = 1:length(Title)
    a = Title{i};
    b = strfind(Title{1},'_FULLSET_HH.xls');
    TITLE = [TITLE,a(b-11:b-1)];                      %%����xls�ļ�������վ��+ʱ�䣩��Ϊ����������ļ���ʶ
end

parfor ii = 1:length(TITLE)
    mytitle = TITLE{ii}
    [~,~,TA,NEE,~,~,rateQC0] = DataLoadQCFilter(Title{ii});             %%���ݵ���
    var_name = {'TA','NEE','mytitle','rateQC0'};
    parsave([MatOutPutDataPath,'\',mytitle,'.mat'],var_name,TA,NEE,mytitle,rateQC0);           %%���ݱ���
end