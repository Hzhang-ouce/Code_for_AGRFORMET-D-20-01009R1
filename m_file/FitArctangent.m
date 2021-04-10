function [DataInfo_T_HH] = FitArctangent(TA,NEE,TITLE)
%%
% This function is used for fitting data to Exp_Arctangent.
% Input data contains two columns and a string.
% Temperature is on the left, respiration is in the middle, and the title is on the right.
%% Summary info
VariableName_T = {...
    'ModelNum', 'NumObs', ...
    'Rsquared', 'RMSE', 'AIC', 'AICc', 'BIC',...
    'Para1_Estimated', 'Para1_SE', 'Para1_p', 'Para2_Estimated', 'Para2_SE', 'Para2_p','Para3_Estimated', 'Para3_SE', 'Para3_p', 'Para4_Estimated', 'Para4_SE', 'Para4_p',...
    'Tref', 'Q10', 'Tmin', 'Rref',...
    'Normality_Residual_Raw', 'Normality_Residual_Pearson', 'Normality_Residual_Student','Normality_Resudual_Standard','p_value_f_test',...
    'R_12', 't_12', 'p_12', 'R_13', 't_13', 'p_13', 'R_23', 't_23', 'p_23'};

%% Fit and Input

% model regression
Tpara0 = [prctile(NEE,50), prctile(NEE,50)-prctile(NEE,5), 2,prctile(TA,50)];
Fit_T.Arctangent = [];
Rsquared_Compare = 0;
try
    Fun_T.Arctangent = @(Tpara,T)(Tpara(1)+(Tpara(2)*atan(Tpara(3)*pi*(T-Tpara(4))))/pi);
    opts = statset('RobustWgtFun','logistic','MaxIter',400);
    % clear last warning before regression
    lastwarn('');
    % regression
    Fit_T.Arctangent_Compare = ...
        fitnlm (TA,NEE, Fun_T.Arctangent, Tpara0,'Options',opts);
    % catch marning message
    [~, msgid] = lastwarn;
    if isempty(msgid) == 0
        % clear warning after identification
        lastwarn('');
    end
    if Fit_T.Arctangent_Compare.Rsquared.Adjusted > Rsquared_Compare
        Rsquared_Compare = Fit_T.Arctangent_Compare.Rsquared.Adjusted;
        Fit_T.Arctangent = Fit_T.Arctangent_Compare;
        Tref_Best = Fit_T.Arctangent.Coefficients.Estimate(4);
    end
catch
    warning on
    warning(['Arctangent_Regression_failed_in_', TITLE, '_9']);
    warning off
end


if Rsquared_Compare > 0
    % calculate p value by parameter correlation coefficient
    Correlation = corrcov(Fit_T.Arctangent.CoefficientCovariance);
    t_statistics_12 = Correlation(1, 2)*sqrt((Fit_T.Arctangent.NumObservations-2)/(1-(Correlation(1, 2))^2));
    t_statistics_13 = Correlation(1, 3)*sqrt((Fit_T.Arctangent.NumObservations-2)/(1-(Correlation(1, 3))^2));
    t_statistics_23 = Correlation(2, 3)*sqrt((Fit_T.Arctangent.NumObservations-2)/(1-(Correlation(2, 3))^2));
    % pValue left
    pValue_12 = tcdf(t_statistics_12, Fit_T.Arctangent.NumObservations-1);
    pValue_13 = tcdf(t_statistics_13, Fit_T.Arctangent.NumObservations-1);
    pValue_23 = tcdf(t_statistics_23, Fit_T.Arctangent.NumObservations-1);
    
    % input data to structure file
    DataInfo_T_HH = nan(length(VariableName_T),1);
    DataInfo_T_HH(strcmp(VariableName_T, 'ModelNum') == 1) = 9;
    DataInfo_T_HH(strcmp(VariableName_T, 'NumObs') == 1) = Fit_T.Arctangent.NumObservations;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rsquared') == 1) = Fit_T.Arctangent.Rsquared.Adjusted;
    DataInfo_T_HH(strcmp(VariableName_T, 'RMSE') == 1) = Fit_T.Arctangent.RMSE;
    DataInfo_T_HH(strcmp(VariableName_T, 'AIC') == 1) = Fit_T.Arctangent.ModelCriterion.AIC;
    DataInfo_T_HH(strcmp(VariableName_T, 'AICc') == 1) = Fit_T.Arctangent.ModelCriterion.AICc;
    DataInfo_T_HH(strcmp(VariableName_T, 'BIC') == 1) = Fit_T.Arctangent.ModelCriterion.BIC;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_Estimated') == 1) = Fit_T.Arctangent.Coefficients.Estimate(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_SE') == 1) = Fit_T.Arctangent.Coefficients.SE(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_p') == 1) = Fit_T.Arctangent.Coefficients.pValue(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_Estimated') == 1) = Fit_T.Arctangent.Coefficients.Estimate(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_SE') == 1) = Fit_T.Arctangent.Coefficients.SE(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_p') == 1) = Fit_T.Arctangent.Coefficients.pValue(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para3_Estimated') == 1) = Fit_T.Arctangent.Coefficients.Estimate(3);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para3_SE') == 1) = Fit_T.Arctangent.Coefficients.SE(3);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para3_p') == 1) = Fit_T.Arctangent.Coefficients.pValue(3);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para4_Estimated') == 1) = Fit_T.Arctangent.Coefficients.Estimate(4);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para4_SE') == 1) = Fit_T.Arctangent.Coefficients.SE(4);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para4_p') == 1) = Fit_T.Arctangent.Coefficients.pValue(4);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Raw') == 1) = ttest(Fit_T.Arctangent.Residuals.Raw);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Pearson') == 1) = ttest(Fit_T.Arctangent.Residuals.Pearson);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Student') == 1) = ttest(Fit_T.Arctangent.Residuals.Studentized);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Resudual_Standard') == 1) = ttest(Fit_T.Arctangent.Residuals.Standardized);
    DataInfo_T_HH(strcmp(VariableName_T, 'p_value_f_test') == 1) = coefTest(Fit_T.Arctangent);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Tref') == 1) = Tref_Best;
        
    DataInfo_T_HH(strcmp(VariableName_T, 'R_12') == 1) = Correlation(1, 2);
    DataInfo_T_HH(strcmp(VariableName_T, 't_12') == 1) = t_statistics_12;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_12') == 1) = pValue_12;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'R_13') == 1) = Correlation(1, 3);
    DataInfo_T_HH(strcmp(VariableName_T, 't_13') == 1) = t_statistics_13;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_13') == 1) = pValue_13;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'R_23') == 1) = Correlation(2, 3);
    DataInfo_T_HH(strcmp(VariableName_T, 't_23') == 1) = t_statistics_23;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_23') == 1) = pValue_23;
else
    DataInfo_T_HH = nan(length(VariableName_T),1);
    warning on
    warning(['Arctangent_Regression_failed_in_', TITLE, '_9']);
    warning off
end