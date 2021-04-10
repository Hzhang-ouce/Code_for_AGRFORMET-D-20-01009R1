function [DataInfo_T_HH] = FitExp_vantHoff(TA,NEE,TITLE)
%%
% This function is used for fitting data to Exp_VantHoff.
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
Tpara0 = [2, prctile(TA,50)];
Fit_T.Exp_vantHoff = [];
Rsquared_Compare = 0;
Rref = prctile(NEE,50);
try
    Fun_T.Exp_vantHoff = @(Tpara, T)(Rref*Tpara(1).^((T-Tpara(2))/10));
    opts = statset('RobustWgtFun','bisquare','MaxIter',400);
    % clear last warning before regression
    lastwarn('');
    % regression
    Fit_T.Exp_vantHoff_Compare = ...
        fitnlm (TA,NEE, Fun_T.Exp_vantHoff, Tpara0,'Options',opts);
    % catch marning message
    [~, msgid] = lastwarn;
    if isempty(msgid) == 0
        % clear warning after identification
        lastwarn('');
    end
    if Fit_T.Exp_vantHoff_Compare.Rsquared.Adjusted > Rsquared_Compare
        Rsquared_Compare = Fit_T.Exp_vantHoff_Compare.Rsquared.Adjusted;
        Fit_T.Exp_vantHoff = Fit_T.Exp_vantHoff_Compare;
        Tref_Best = Fit_T.Exp_vantHoff.Coefficients.Estimate(2);
    end
catch
    warning on
    warning(['vantHoff_Regression_failed_in_', TITLE,'_5']);
    warning off
end


DataInfo_T_HH = nan(length(VariableName_T),1);
if Rsquared_Compare > 0
    
    % input statistical data
    Correlation = corrcov(Fit_T.Exp_vantHoff.CoefficientCovariance);
    t_statistics_12 = Correlation(1, 2)*sqrt((Fit_T.Exp_vantHoff.NumObservations-2)/(1-(Correlation(1, 2))^2));
    % pValue left
    pValue_12 = tcdf(t_statistics_12, Fit_T.Exp_vantHoff.NumObservations-1);
    % input data to structure file
    DataInfo_T_HH(strcmp(VariableName_T, 'ModelNum') == 1) = 5;
    DataInfo_T_HH(strcmp(VariableName_T, 'NumObs') == 1) = Fit_T.Exp_vantHoff.NumObservations;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rsquared') == 1) = Fit_T.Exp_vantHoff.Rsquared.Adjusted;
    DataInfo_T_HH(strcmp(VariableName_T, 'RMSE') == 1) = Fit_T.Exp_vantHoff.RMSE;
    DataInfo_T_HH(strcmp(VariableName_T, 'AIC') == 1) = Fit_T.Exp_vantHoff.ModelCriterion.AIC;
    DataInfo_T_HH(strcmp(VariableName_T, 'AICc') == 1) = Fit_T.Exp_vantHoff.ModelCriterion.AICc;
    DataInfo_T_HH(strcmp(VariableName_T, 'BIC') == 1) = Fit_T.Exp_vantHoff.ModelCriterion.BIC;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Tref') == 1) = Tref_Best;
    DataInfo_T_HH(strcmp(VariableName_T, 'Q10') == 1) = Fit_T.Exp_vantHoff.Coefficients.Estimate(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Rref') == 1) = Rref;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_Estimated') == 1) = Fit_T.Exp_vantHoff.Coefficients.Estimate(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_SE') == 1) = Fit_T.Exp_vantHoff.Coefficients.SE(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_p') == 1) = Fit_T.Exp_vantHoff.Coefficients.pValue(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_Estimated') == 1) = Fit_T.Exp_vantHoff.Coefficients.Estimate(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_SE') == 1) = Fit_T.Exp_vantHoff.Coefficients.SE(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_p') == 1) = Fit_T.Exp_vantHoff.Coefficients.pValue(2);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Raw') == 1) = ttest(Fit_T.Exp_vantHoff.Residuals.Raw);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Pearson') == 1) = ttest(Fit_T.Exp_vantHoff.Residuals.Pearson);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Student') == 1) = ttest(Fit_T.Exp_vantHoff.Residuals.Studentized);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Resudual_Standard') == 1) = ttest(Fit_T.Exp_vantHoff.Residuals.Standardized);
    DataInfo_T_HH(strcmp(VariableName_T, 'p_value_f_test') == 1) = coefTest(Fit_T.Exp_vantHoff);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'R_12') == 1) = Correlation(1, 2);
    DataInfo_T_HH(strcmp(VariableName_T, 't_12') == 1) = t_statistics_12;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_12') == 1) = pValue_12;
else
    DataInfo_T_HH = nan(length(VariableName_T),1);
    warning on
    warning(['vantHoff_Regression_failed_in_', TITLE,'_5']);
    warning off
end

