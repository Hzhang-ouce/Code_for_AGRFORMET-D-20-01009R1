function [DataInfo_T_HH] = FitQuadratic(TA,NEE,TITLE)
%%
    % This function is used for fitting data to Quadratic.
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
Tpara0 = [prctile(NEE,5), 0, 0];
Fun_T.Quadratic = @(Tpara, T)(Tpara(1) + Tpara(2)*T + Tpara(3)*T.^2);
opts = statset('RobustWgtFun','bisquare','MaxIter',400);
try
    Fit_T.Quadratic = fitnlm (TA,NEE,Fun_T.Quadratic,Tpara0,'Options',opts);
catch
    warning on
    warning(['Quadratic_Regression_failed_in_', TITLE,'_2']);
    warning off
end


DataInfo_T_HH = nan(length(VariableName_T),1);

try
    % calculate p value by parameter correlation coefficient
    Correlation = corrcov(Fit_T.Quadratic.CoefficientCovariance);
    t_statistics_12 = Correlation(1, 2)*sqrt((Fit_T.Quadratic.NumObservations-2)/(1-(Correlation(1, 2))^2));
    t_statistics_13 = Correlation(1, 3)*sqrt((Fit_T.Quadratic.NumObservations-2)/(1-(Correlation(1, 3))^2));
    t_statistics_23 = Correlation(2, 3)*sqrt((Fit_T.Quadratic.NumObservations-2)/(1-(Correlation(2, 3))^2));
    % pValue left
    pValue_12 = tcdf(t_statistics_12, Fit_T.Quadratic.NumObservations-1);
    pValue_13 = tcdf(t_statistics_13, Fit_T.Quadratic.NumObservations-1);
    pValue_23 = tcdf(t_statistics_23, Fit_T.Quadratic.NumObservations-1);
    
    % input data to structure file
    DataInfo_T_HH(strcmp(VariableName_T, 'ModelNum') == 1) = 2;
    DataInfo_T_HH(strcmp(VariableName_T, 'NumObs') == 1) = Fit_T.Quadratic.NumObservations;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rsquared') == 1) = Fit_T.Quadratic.Rsquared.Adjusted;
    DataInfo_T_HH(strcmp(VariableName_T, 'RMSE') == 1) = Fit_T.Quadratic.RMSE;
    DataInfo_T_HH(strcmp(VariableName_T, 'AIC') == 1) = Fit_T.Quadratic.ModelCriterion.AIC;
    DataInfo_T_HH(strcmp(VariableName_T, 'AICc') == 1) = Fit_T.Quadratic.ModelCriterion.AICc;
    DataInfo_T_HH(strcmp(VariableName_T, 'BIC') == 1) = Fit_T.Quadratic.ModelCriterion.BIC;
    
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_Estimated') == 1) = Fit_T.Quadratic.Coefficients.Estimate(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_SE') == 1) = Fit_T.Quadratic.Coefficients.SE(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_p') == 1) = Fit_T.Quadratic.Coefficients.pValue(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_Estimated') == 1) = Fit_T.Quadratic.Coefficients.Estimate(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_SE') == 1) = Fit_T.Quadratic.Coefficients.SE(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_p') == 1) = Fit_T.Quadratic.Coefficients.pValue(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para3_Estimated') == 1) = Fit_T.Quadratic.Coefficients.Estimate(3);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para3_SE') == 1) = Fit_T.Quadratic.Coefficients.SE(3);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para3_p') == 1) = Fit_T.Quadratic.Coefficients.pValue(3);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Raw') == 1) = ttest(Fit_T.Quadratic.Residuals.Raw);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Pearson') == 1) = ttest(Fit_T.Quadratic.Residuals.Pearson);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Student') == 1) = ttest(Fit_T.Quadratic.Residuals.Studentized);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Resudual_Standard') == 1) = ttest(Fit_T.Quadratic.Residuals.Standardized);
    DataInfo_T_HH(strcmp(VariableName_T, 'p_value_f_test') == 1) = coefTest(Fit_T.Quadratic);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'R_12') == 1) = Correlation(1, 2);
    DataInfo_T_HH(strcmp(VariableName_T, 't_12') == 1) = t_statistics_12;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_12') == 1) = pValue_12;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'R_13') == 1) = Correlation(1, 3);
    DataInfo_T_HH(strcmp(VariableName_T, 't_13') == 1) = t_statistics_13;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_13') == 1) = pValue_13;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'R_23') == 1) = Correlation(2, 3);
    DataInfo_T_HH(strcmp(VariableName_T, 't_23') == 1) = t_statistics_23;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_23') == 1) = pValue_23;
catch
    DataInfo_T_HH = nan(length(VariableName_T),1);
    warning on
    warning(['Quadratic_Regression_failed_in_', TITLE,'_2']);
    warning off
end