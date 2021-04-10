clc
clear
close all

%% 
% 该脚本用于将xls文件转化为mat文件
% 输入：xls格式
% 输出：mat格式（'TA','NEE','mytitle','rateQC0'）

%% 路径设置
LoadInDataPath = 'C:\Users\chenzw\Desktop\example_data';
MatOutPutDataPath = 'C:\Users\chenzw\Desktop\mat';

%% Excel信息获取
Title = {};
DataDir = dir(LoadInDataPath);            % 遍历所有文件
for i = 1:length(DataDir)
    if(isequal(DataDir(i).name,'.')||...            % 去除系统自带的两个隐文件夹
            isequal(DataDir(i).name,'..')||...
            ~DataDir(i).isdir)            % 去除遍历中不是文件夹的
        continue;
    end
    xlsDir = dir([LoadInDataPath,'\',DataDir(i).name,'\*.xls']);           %获取该目录下所有子文件夹中的xls文件名
    
    for iii = 1:length(xlsDir)
        Title = [Title,[xlsDir(iii).folder,'\',xlsDir(iii).name]];                  %路径+文件名
    end
    
end

TITLE = {};
for i  = 1:length(Title)
    a = Title{i};
    b = strfind(Title{1},'_FULLSET_HH.xls');
    TITLE = [TITLE,a(b-11:b-1)];                      %%根据xls文件名（即站点+时间）作为出错警告语的文件标识
end

parfor ii = 1:length(TITLE)
    mytitle = TITLE{ii}
    [~,~,TA,NEE,~,~,rateQC0] = DataLoadQCFilter(Title{ii});             %%数据导入
    var_name = {'TA','NEE','mytitle','rateQC0'};
    parsave([MatOutPutDataPath,'\',mytitle,'.mat'],var_name,TA,NEE,mytitle,rateQC0);           %%数据保存
end