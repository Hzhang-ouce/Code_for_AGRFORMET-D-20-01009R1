function [DataInfo_T_HH] = FitExp_LT(TA,NEE,TITLE)
%%
    % This function is used for fitting data to Exp_LT.
    % Input data contains two columns and a string.
    % Temperature is on the left, respiration is in the middle, and the title is on the right.
%% Summary info
VariableName_T = {...
    'ModelNum', 'NumObs',...
    'Rsquared', 'RMSE', 'AIC', 'AICc', 'BIC',...
    'Para1_Estimated', 'Para1_SE', 'Para1_p', 'Para2_Estimated', 'Para2_SE', 'Para2_p','Para3_Estimated', 'Para3_SE', 'Para3_p', 'Para4_Estimated', 'Para4_SE', 'Para4_p',...
    'Tref', 'Q10', 'Tmin', 'Rref',...
    'Normality_Residual_Raw', 'Normality_Residual_Pearson', 'Normality_Residual_Student','Normality_Resudual_Standard','p_value_f_test',...
    'R_12', 't_12', 'p_12', 'R_13', 't_13', 'p_13', 'R_23', 't_23', 'p_23'};

%% Fit and Input

% model regression
Tpara0 = [308, prctile(TA,50)];
Fit_T.Exp_LT = [];
Rsquared_Compare = 0;
Rref = prctile(NEE,50);
try
    Fun_T.Exp_LT = @(Tpara,T)(Rref*exp(Tpara(1)*(1/(Tpara(2)+46.02)-1./(T+46.02))));
    opts = statset('RobustWgtFun','bisquare','MaxIter',400);
    % clear last warning before regression
    lastwarn('');
    % regression
    Fit_T.Exp_LT_Compare = ...
        fitnlm (TA,NEE, Fun_T.Exp_LT, Tpara0,'Options',opts);
    % catch marning message
    [~, msgid] = lastwarn;
    if isempty(msgid) == 0
        % clear warning after identification
        lastwarn('');
    end
    if Fit_T.Exp_LT_Compare.Rsquared.Adjusted > Rsquared_Compare
        Rsquared_Compare = Fit_T.Exp_LT_Compare.Rsquared.Adjusted;
        Fit_T.Exp_LT = Fit_T.Exp_LT_Compare;
        Tref_Best = Fit_T.Exp_LT.Coefficients.Estimate(2);
    end
catch
    warning on
    warning(['LT_Regression_failed_in_', TITLE, '_7']);
    warning off
end

DataInfo_T_HH = nan(length(VariableName_T),1);
if Rsquared_Compare > 0
    
    % calculate p value by parameter correlation coefficient
    Correlation = corrcov(Fit_T.Exp_LT.CoefficientCovariance);
    t_statistics_12 = Correlation(1, 2)*sqrt((Fit_T.Exp_LT.NumObservations-2)/(1-(Correlation(1, 2))^2));
    % pValue left
    pValue_12 = tcdf(t_statistics_12, Fit_T.Exp_LT.NumObservations-1);
    
    % input data to structure file
    DataInfo_T_HH(strcmp(VariableName_T, 'ModelNum') == 1) = 7;
    DataInfo_T_HH(strcmp(VariableName_T, 'NumObs') == 1) = Fit_T.Exp_LT.NumObservations;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rsquared') == 1) = Fit_T.Exp_LT.Rsquared.Adjusted;
    DataInfo_T_HH(strcmp(VariableName_T, 'RMSE') == 1) = Fit_T.Exp_LT.RMSE;
    DataInfo_T_HH(strcmp(VariableName_T, 'AIC') == 1) = Fit_T.Exp_LT.ModelCriterion.AIC;
    DataInfo_T_HH(strcmp(VariableName_T, 'AICc') == 1) = Fit_T.Exp_LT.ModelCriterion.AICc;
    DataInfo_T_HH(strcmp(VariableName_T, 'BIC') == 1) = Fit_T.Exp_LT.ModelCriterion.BIC;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_Estimated') == 1) = Fit_T.Exp_LT.Coefficients.Estimate(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_SE') == 1) = Fit_T.Exp_LT.Coefficients.SE(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_p') == 1) = Fit_T.Exp_LT.Coefficients.pValue(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_Estimated') == 1) = Fit_T.Exp_LT.Coefficients.Estimate(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_SE') == 1) = Fit_T.Exp_LT.Coefficients.SE(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_p') == 1) = Fit_T.Exp_LT.Coefficients.pValue(2);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Tref') == 1) = Tref_Best;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rref') == 1) = Rref;
        
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Raw') == 1) = ttest(Fit_T.Exp_LT.Residuals.Raw);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Pearson') == 1) = ttest(Fit_T.Exp_LT.Residuals.Pearson);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Student') == 1) = ttest(Fit_T.Exp_LT.Residuals.Studentized);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Resudual_Standard') == 1) = ttest(Fit_T.Exp_LT.Residuals.Standardized);
    DataInfo_T_HH(strcmp(VariableName_T, 'p_value_f_test') == 1) = coefTest(Fit_T.Exp_LT);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'R_12') == 1) = Correlation(1, 2);
    DataInfo_T_HH(strcmp(VariableName_T, 't_12') == 1) = t_statistics_12;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_12') == 1) = pValue_12;
else
    DataInfo_T_HH = nan(length(VariableName_T),1);
    warning on
    warning(['LT_Regression_failed_in_', TITLE, '_7']);
    warning off
end