function [bianl,QCData,TA,NEE,SWC,numQC0,rateQC0] = DataLoadQCFilter(FileName)
%%  ���ݵ���
% FileName = 'G:\�½��ļ���\ѧϰ\CarbonRecycle\AU\AU-ASM.2010_FULLSET_HH.xls';
% ��������
[data, txt,~] = xlsread(FileName);

% ��Ҫ�ı���
bianl = {'TA_F','P_F','SWC_F_MDS_1','NIGHT','NEE_CUT_MEAN','NEE_CUT_MEAN_QC'};

for ii = 1:4
    a = strcmp(txt(1,:),bianl{ii});          % �ҳ���Ҫ���б���
    b = find(a==1);
    c = bianl{ii};
    eval([c,'=data(:,b);']);          %Ϊ��������ֵ
    eval([c,'(',c,'==-9999',')','=NaN;']);              %����Чֵ�滻ΪNaN
    if isempty(data(:,b))                                       %����ֵ�滻ΪNaN
        QCData(:,ii) = NaN;
    else
        QCData(:,ii) = eval(c);
    end
end

bl = {'NEE_VUT_MEAN','NEE_VUT_MEAN_QC'};
for ii = 5:6
    a = strcmp(txt(1,:),bianl{ii});          % �ҳ���Ҫ���б���
    if any(strcmp(txt(1,:),bianl{5})) == 0
        a = strcmp(txt(1,:),bl{ii-4});          % ��û�С�NEE_CUT_MEAN�����ݣ��Ͷ�ȡ��NEE_VUT_MEAN������
    end
    b = find(a==1);
    c = bianl{ii};
    eval([c,'=data(:,b);']);          %Ϊ��������ֵ
    eval([c,'(',c,'==-9999',')','=NaN;']);              %����Чֵ�滻ΪNaN
    if isempty(data(:,b))                                            %����ֵ�滻ΪNaN
        QCData(:,ii) = NaN;
    else
        QCData(:,ii) = eval(c);
    end
end

% ȥ��NaN��
[x,~] = find(isnan(QCData(:,[1 2 4 5 6])));
QCData(x,:) = [];

% ȥ����Чֵ�����¸�ֵ
for ii = 1:6
    eval([bianl{ii},'= QCData(:,ii);']);
end

clear x a b c data txt ii bl

%% �ж������Ƿ���Ч
b = strfind(FileName,'.xls');
mytitle = FileName(b-22:b-12);
if isempty(QCData)
    disp([mytitle,' have no valid data!!!']);
    bianl=[];QCData=[];TA=[];NEE=[];SWC=[];numQC0=[];rateQC0=[];
else
    %% ������ų�NEE_CUT_MEAN_QCΪ����
    a = find(NEE_CUT_MEAN_QC==0);
    numQC0 = length(a);
    rateQC0 = numQC0/length(QCData);
    QCData(numQC0,:) = [];
    for ii = 1:6
        eval([bianl{ii},'= QCData(:,ii);']);
    end
    clear a
    
    %% ���ֽ�ˮ���
    % ȷ����ˮʱ��
    n = length(P_F);
    PFTime = zeros(n,1);
    n2 = find(P_F ~= 0);
    
    for ii = 0:12
        PFTime(n2+ii) = 1;
    end
    
    if length(P_F) < length(PFTime)
        PFTime(length(P_F)+1:end) = [];
    end
    
    % �жϽ�ˮ���
    % ����������µ��������Ӧ��ʱ����д��ṹ��
    if isnan(PFTime) == 1
        fprintf('HAVE NO PF DATA!!!\r\n');
    else
        a = find(PFTime == 0);
        TA.PF.no.data = TA_F(a);
        NEE.PF.no.data = NEE_CUT_MEAN(a);
        TA.PF.no.num = a;
        NEE.PF.no.num = a;
        
        b = find(PFTime ==1);
        TA.PF.yes.data = TA_F(b);
        NEE.PF.yes.data = NEE_CUT_MEAN(b);
        TA.PF.yes.num = b;
        NEE.PF.yes.num = b;
    end
    
    %% ������ҹ
    if isnan(NIGHT) == 1
        fprintf('Have No Night Data!!\r\n');
    else
        a = find(NIGHT == 0);
        TA.NT.no.data = TA_F(a);
        NEE.NT.no.data = NEE_CUT_MEAN(a);
        SWC.NT.no.data = SWC_F_MDS_1(a);
        TA.NT.no.num = a;
        NEE.NT.no.num = a;
        SWC.NT.no.num = a;
        b = find(NIGHT == 1);
        TA.NT.yes.data = TA_F(b);
        TA.NT.yes.num = b;
        SWC.NT.yes.data = SWC_F_MDS_1(b);
        SWC.NT.yes.num = b;
        c = NEE_CUT_MEAN(b);
        d = find(c<=0);
        c(d) = NaN;        % �޳�ҹ�����Ϊ�����쳣ֵ
        NEE.NT.yes.data = c;
        NEE.NT.yes.num = b;
    end
    clear a b c d
    
    %%  ���ս�ˮ����ҹ�ֳ��Ŀ�����
    
    TA.PFNT.data = TA_F(intersect(TA.NT.yes.num,TA.PF.yes.num));
    TA.PFnoNT.data = TA_F(intersect(TA.NT.no.num,TA.PF.yes.num));
    TA.noPFNT.data = TA_F(intersect(TA.NT.yes.num,TA.PF.no.num));
    TA.noPFnoNT.data = TA_F(intersect(TA.NT.no.num,TA.PF.no.num));
    
    TA.PFNT.num = intersect(TA.NT.yes.num,TA.PF.yes.num);
    TA.PFnoNT.num = intersect(TA.NT.no.num,TA.PF.yes.num);
    TA.noPFNT.num = intersect(TA.NT.yes.num,TA.PF.no.num);
    TA.noPFnoNT.num = intersect(TA.NT.no.num,TA.PF.no.num);
    
    NEE.PFNT.data = NEE_CUT_MEAN(intersect(NEE.NT.yes.num,NEE.PF.yes.num));
    NEE.PFnoNT.data = NEE_CUT_MEAN(intersect(NEE.NT.no.num,NEE.PF.yes.num));
    NEE.noPFNT.data = NEE_CUT_MEAN(intersect(NEE.NT.yes.num,NEE.PF.no.num));
    NEE.noPFnoNT.data = NEE_CUT_MEAN(intersect(NEE.NT.no.num,NEE.PF.no.num));
    
    NEE.PFNT.num = intersect(NEE.NT.yes.num,NEE.PF.yes.num);
    NEE.PFnoNT.num = intersect(NEE.NT.no.num,NEE.PF.yes.num);
    NEE.noPFNT.num = intersect(NEE.NT.yes.num,NEE.PF.no.num);
    NEE.noPFnoNT.num = intersect(NEE.NT.no.num,NEE.PF.no.num);
    
    %% �޳�������ֵ
    a = find(NEE.PFNT.data<0);
    NEE.PFNT.data(a) = nan;
    b = find(NEE.PFnoNT.data<0);
    NEE.PFnoNT.data(b) = nan;
    c = find(NEE.noPFNT.data<0);
    NEE.noPFNT.data(c) = nan;
    d = find(NEE.noPFnoNT.data<0);
    NEE.noPFnoNT.data(d) = nan;
    
end




