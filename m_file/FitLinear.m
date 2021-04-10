    function [DataInfo_T_HH] = FitLinear(TA,NEE,TITLE)
    %%
    % This function is used for linear fitting of data.
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

        try
        Fit_T.Linear = fitlm (TA,NEE);

        % calculate p value by parameter correlation coefficient
        Correlation = corrcov(Fit_T.Linear.CoefficientCovariance);
        t_statistics_12 = Correlation(1, 2)*sqrt((Fit_T.Linear.NumObservations-2)/(1-(Correlation(1, 2))^2));
        % pValue left
        pValue_12 = tcdf(t_statistics_12, Fit_T.Linear.NumObservations-1);

        DataInfo_T_HH = nan(length(VariableName_T),1);

        % input data to structure file
        DataInfo_T_HH(strcmp(VariableName_T, 'ModelNum') == 1) = 1;
        DataInfo_T_HH(strcmp(VariableName_T, 'NumObs') == 1) = Fit_T.Linear.NumObservations;
        DataInfo_T_HH(strcmp(VariableName_T, 'Rsquared') == 1) = Fit_T.Linear.Rsquared.Adjusted;
        DataInfo_T_HH(strcmp(VariableName_T, 'RMSE') == 1) = Fit_T.Linear.RMSE;
        DataInfo_T_HH(strcmp(VariableName_T, 'AIC') == 1) = Fit_T.Linear.ModelCriterion.AIC;
        DataInfo_T_HH(strcmp(VariableName_T, 'AICc') == 1) = Fit_T.Linear.ModelCriterion.AICc;
        DataInfo_T_HH(strcmp(VariableName_T, 'BIC') == 1) = Fit_T.Linear.ModelCriterion.BIC;

        DataInfo_T_HH(strcmp(VariableName_T, 'Para1_Estimated') == 1) = Fit_T.Linear.Coefficients.Estimate(1);
        DataInfo_T_HH(strcmp(VariableName_T, 'Para1_SE') == 1) = Fit_T.Linear.Coefficients.SE(1);
        DataInfo_T_HH(strcmp(VariableName_T, 'Para1_p') == 1) = Fit_T.Linear.Coefficients.pValue(1);
        DataInfo_T_HH(strcmp(VariableName_T, 'Para2_Estimated') == 1) = Fit_T.Linear.Coefficients.Estimate(2);
        DataInfo_T_HH(strcmp(VariableName_T, 'Para2_SE') == 1) = Fit_T.Linear.Coefficients.SE(2);
        DataInfo_T_HH(strcmp(VariableName_T, 'Para2_p') == 1) = Fit_T.Linear.Coefficients.pValue(2);

        DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Raw') == 1) = ttest(Fit_T.Linear.Residuals.Raw);
        DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Pearson') == 1) = ttest(Fit_T.Linear.Residuals.Pearson);
        DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Residual_Student') == 1) = ttest(Fit_T.Linear.Residuals.Studentized);
        DataInfo_T_HH(strcmp(VariableName_T, 'Normality_Resudual_Standard') == 1) = ttest(Fit_T.Linear.Residuals.Standardized);
        DataInfo_T_HH(strcmp(VariableName_T, 'p_value_f_test') == 1) = coefTest(Fit_T.Linear);
        
        DataInfo_T_HH(strcmp(VariableName_T, 'R_12') == 1) = Correlation(1, 2);
        DataInfo_T_HH(strcmp(VariableName_T, 't_12') == 1) = t_statistics_12;
        DataInfo_T_HH(strcmp(VariableName_T, 'p_12') == 1) = pValue_12;
         catch
            DataInfo_T_HH = nan(length(VariableName_T),1);
            warning on
            warning(['Linear_Regression_failed_in_', TITLE,'_1']);
            warning off
        end


