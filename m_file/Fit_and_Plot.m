clc
clear

%%
MATPath = 'G:\本科\学习\TA-NEE\CarbonRecycle\MAT Data\';
FigPath = 'G:\本科\学习\TA-NEE\figure';
file = dir([MATPath,'*.mat']);
FileName = sortrows({file.name}');
for ii = 1:length(file)
    load([MATPath,FileName{ii}]);
    if ~isempty(TA)
        NTdata = Average_05_and_constant([TA.NT.yes.data,NEE.NT.yes.data]);
        TA = NTdata(:,1);
        NEE = NTdata(:,2);
        [xData, yData] = prepareCurveData( TA, NEE );
        
        % Set up fittype and options.
        ft = fittype( '(1./(a+(10.^b).^(-(x-c)/10)))+d', 'independent', 'x', 'dependent', 'y' );
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        opts.StartPoint = [1/(prctile(NEE,95)-prctile(NEE,5)), 1, prctile(TA,50),prctile(NEE,5)];
        
        % Fit model to data.
        [fitresult, gof] = fit( xData, yData, ft, opts );
        
        % Plot fit with data.
%         figure( 'Name', 'untitled fit 1' );
        h = plot( fitresult, xData, yData );
        legend( h, 'nee vs. ta', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
        % Label axes
        xlabel( 'Ta', 'Interpreter', 'none' );
        ylabel( 'Nee', 'Interpreter', 'none' );
        title(FileName{ii})
        grid on
        print(gcf,'-r600','-dpng',[FigPath,'\',FileName{ii}(1:end-4),'.png']);
    end
end