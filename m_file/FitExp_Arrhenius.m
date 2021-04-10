function [DataInfo_T_HH] = FitExp_Arrhenius(TA,NEE,TITLE)
%%
% This function is used for fitting data to Exp_Arrhenius.
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
Tpara0 = [50000,prctile(TA,50)];
Fit_T.Exp_Arrhenius = [];
Rsquared_Compare = 0;
Tref_Best = NaN;
Rref = prctile(NEE,50);
try
    Fun_T.Exp_Arrhenius = @(Tpara, T)(Rref*(exp(Tpara(1)/8.314*(1/(Tpara(2)+273.15)-1./(T+273.15)))));
    opts = statset('RobustWgtFun','bisquare','MaxIter',400);
    % clear last warning before regression
    lastwarn('');
    % regression
    Fit_T.Exp_Arrhenius_Compare = ...
        fitnlm (TA,NEE, Fun_T.Exp_Arrhenius, Tpara0,'Options',opts);
    % catch marning message
    [~, msgid] = lastwarn;
    if isempty(msgid) == 0
        % clear warning after identification
        lastwarn('');
    end
    if Fit_T.Exp_Arrhenius_Compare.Rsquared.Adjusted > Rsquared_Compare
        Rsquared_Compare = Fit_T.Exp_Arrhenius_Compare.Rsquared.Adjusted;
        Fit_T.Exp_Arrhenius = Fit_T.Exp_Arrhenius_Compare;
        Tref_Best = Fit_T.Exp_Arrhenius.Coefficients.Estimate(2);
    end
catch
    warning on
    warning(['Arrhenius_Regression_failed_in_', TITLE, '_4']);
    warning off
end


DataInfo_T_HH = nan(length(VariableName_T),1);
if Rsquared_Compare > 0
    % input data to structure file
    DataInfo_T_HH(strcmp(VariableName_T, 'ModelNum') == 1) = 4;
    DataInfo_T_HH(strcmp(VariableName_T, 'NumObs') == 1) = Fit_T.Exp_Arrhenius.NumObservations;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rsquared') == 1) = Fit_T.Exp_Arrhenius.Rsquared.Adjusted;
    DataInfo_T_HH(strcmp(VariableName_T, 'RMSE') == 1) = Fit_T.Exp_Arrhenius.RMSE;
    DataInfo_T_HH(strcmp(VariableName_T, 'AIC') == 1) = Fit_T.Exp_Arrhenius.ModelCriterion.AIC;
    DataInfo_T_HH(strcmp(VariableName_T, 'AICc') == 1) = Fit_T.Exp_Arrhenius.ModelCriterion.AICc;
    DataInfo_T_HH(strcmp(VariableName_T, 'BIC') == 1) = Fit_T.Exp_Arrhenius.ModelCriterion.BIC;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_Estimated') == 1) = Fit_T.Exp_Arrhenius.Coefficients.Estimate(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_SE') == 1) = Fit_T.Exp_Arrhenius.Coefficients.SE(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para1_p') == 1) = Fit_T.Exp_Arrhenius.Coefficients.pValue(1);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_Estimated') == 1) = Fit_T.Exp_Arrhenius.Coefficients.Estimate(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_SE') == 1) = Fit_T.Exp_Arrhenius.Coefficients.SE(2);
    DataInfo_T_HH(strcmp(VariableName_T, 'Para2_p') == 1) = Fit_T.Exp_Arrhenius.Coefficients.pValue(2);
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Tref') == 1) = Tref_Best;
    DataInfo_T_HH(strcmp(VariableName_T, 'Rref') == 1) = Rref;
    
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Raw') == 1) = ttest(Fit_T.Exp_Arrhenius.Residuals.Raw);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Pearson') == 1) = ttest(Fit_T.Exp_Arrhenius.Residuals.Pearson);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Student') == 1) = ttest(Fit_T.Exp_Arrhenius.Residuals.Studentized);
    DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Resudual_Standard') == 1) = ttest(Fit_T.Exp_Arrhenius.Residuals.Standardized);
    DataInfo_T_HH(strcmp(VariableName_T, 'p_value_f_test') == 1) = coefTest(Fit_T.Exp_Arrhenius);
else
    DataInfo_T_HH = nan(length(VariableName_T),1);
    warning on
    warning(['Arrhenius_Regression_failed_in_', TITLE, '_4']);
    warning off
end