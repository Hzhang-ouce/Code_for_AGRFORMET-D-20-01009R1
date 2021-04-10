function [DataInfo_T_HH] = FitPower(TA,NEE,TITLE)

%%
% This function is used for fitting data to Power.
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
Tpara0 = [0.1, 4.194];
Fit_T.Power = [];
Rsquared_Compare = 0;
Tmin = min(- 26.5,min(TA)-2) ;
try
    Fun_T.Power = @(Tpara, T)(Tpara(1)*(T - Tmin).^Tpara(2));
    opts = statset('RobustWgtFun','bisquare','MaxIter',400);
    Fit_T.Power = fitnlm (TA,NEE, Fun_T.Power, Tpara0,'Options',opts);
    % catch warning message
    [~, msgid] = lastwarn;
    if isempty(msgid) == 0
        % clear warning after identification
        lastwarn('');
    end
    if Fit_T.Power.Rsquared.Adjusted > Rsquared_Compare
        Rsquared_Compare = Fit_T.Power.Rsquared.Adjusted;
    end
catch
    warning on
    warning(['Power_Regression_failed_in_', TITLE,'_3']);
    warning off
end


if Rsquared_Compare > 0
    % input statistical data
    Correlation = corrcov(Fit_T.Power.CoefficientCovariance);
    t_statistics_12 = Correlation(1, 2)*sqrt((Fit_T.Power.NumObservations-2)/(1-(Correlation(1, 2))^2));
    % pValue left
    pValue_12 = tcdf(t_statistics_12, Fit_T.Power.NumObservations-1);
    % input data to structure file
    DataInfo_T_HH = nan(length(VariableName_T),1);
    DataInfo_T_HH(strcmp(VariableName_T, 'ModelNum') == 1) = 3;
    DataInfo_T_HH(strcmp(VariableName_T, 'NumObs') == 1) = Fit_T.Power.NumObservations;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rsquared') == 1) = Fit_T.Power.Rsquared.Adjusted;
    DataInfo_T_HH(strcmp(VariableName_T, 'RMSE') == 1) = Fit_T.Power.RMSE;
    DataInfo_T_HH(strcmp(VariableName_T, 'AIC') == 1) = Fit_T.Power.ModelCriterion.AIC;
    DataInfo_T_HH(strcmp(VariableName_T, 'AICc') == 1) = Fit_T.Power.ModelCriterion.AICc;
    DataInfo_T_HH(strcmp(VariableName_T, 'BIC') == 1) = Fit_T.Power.ModelCriterion.BIC;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Tmin') == 1) = Tmin;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rref') == 1) = Fit_T.Power.Coefficients.Estimate(1);
        
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_Estimated') == 1) = Fit_T.Power.Coefficients.Estimate(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_SE') == 1) = Fit_T.Power.Coefficients.SE(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_p') == 1) = Fit_T.Power.Coefficients.pValue(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_Estimated') == 1) = Fit_T.Power.Coefficients.Estimate(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_SE') == 1) = Fit_T.Power.Coefficients.SE(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_p') == 1) = Fit_T.Power.Coefficients.pValue(2);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Raw') == 1) = ttest(Fit_T.Power.Residuals.Raw);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Pearson') == 1) = ttest(Fit_T.Power.Residuals.Pearson);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Student') == 1) = ttest(Fit_T.Power.Residuals.Studentized);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Resudual_Standard') == 1) = ttest(Fit_T.Power.Residuals.Standardized);
    DataInfo_T_HH(strcmp(VariableName_T, 'p_value_f_test') == 1) = coefTest(Fit_T.Power);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'R_12') == 1) = Correlation(1, 2);
    DataInfo_T_HH(strcmp(VariableName_T, 't_12') == 1) = t_statistics_12;
    DataInfo_T_HH(strcmp(VariableName_T, 'p_12') == 1) = pValue_12;
else
    DataInfo_T_HH = nan(length(VariableName_T),1);
    warning on
    warning(['Power_Regression_failed_in_', TITLE,'_3']);
    warning off
end

end

