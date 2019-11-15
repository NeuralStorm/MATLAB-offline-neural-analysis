function [cop_table] = grf_bias_correction(bias_table, biased_data)
    %% Given Sensor Calibration values and calculated bias's
    %Matrix Values were found from the Transformed Matrix and the UserAxis
    %Values
    %Hind Right Limb - RHL (data labels ai 18-23) (columns 1-6) FT26922
    RHL = [0.08060 0.03167 -0.16084 3.04062 0.09592 -3.24682; ...
        0.26493 -3.69102 -0.03981 1.75333 -0.13508 1.82602; ...
        5.22021 -0.29510 5.49562 -0.21773 4.98753 -0.12914; ...
        0.00228 -0.01979 0.07629 0.00624 -0.07329 0.01161; ...
        -0.08712 0.00521 0.04448 -0.01849 0.04256 0.01632; ...
        0.00270 -0.04502 0.00183 -0.04283 0.00237 -0.04535];
    biasRHL = biasVector(1, bias_table);
    %Front limbs - FL (data labels ai 38-39, 48-51) (columns 13-18) FT19676
    FL = [-0.00947 -0.01906 0.01012 3.02919 0.09204 -3.09867; ...
        0.03518 -3.71063 -0.02565 1.72619 -0.04224 1.81516; ...
        5.19697 0.05604 5.23834 0.06818 5.19859 -0.01149; ...
        0.00102 -0.01982 0.07448 0.01194 -0.07248 0.00815; ...
        -0.08618 -0.00281 0.04346 -0.01479 0.04207 0.01750; ...
        0.00018 -0.04453 0.00025 -0.04224 0.00139 -0.04353];
    biasFL = biasVector(13, bias_table);
    %Hind Left Limb - LHL (data labels ai 32 - 37) (columns 7-12) FT19675
    LHL = [0.01323 -0.03068 0.01750 3.07380 -0.10279 -2.88656; ...
            0.03325 -3.64990 0.06109 1.77467 0.01640 1.67326; ...
            5.29486 -0.02791 5.04964 0.02401 5.38979 -0.08599; ...
            0.00003 -0.01960 0.07370 0.01028 -0.07419 0.00983; ...
            -0.08654 0.00024 0.04139 -0.01621 0.04406 0.01504; ...
            0.00054 -0.04365 0.00046 -0.04199 -0.00141 -0.03978];
    biasLHL = biasVector(7, bias_table);

    %create a usable data table with the force/torque/time values
    unbiased_data = correct_bias(biased_data, RHL,LHL,FL,biasRHL,biasLHL,biasFL);

    % %Concatinate the Center of Pressure calculations to the graph
    cop_table = CoPTableConcat(unbiased_data);
    cop_table = removevars(cop_table, 'Timestamp');
end

%% Creation of Sensor Data Table, convert from Volatage to Force and Torque

function raw_table = correct_bias(raw_table, RHL,LHL,FL,biasRHL,biasLHL,biasFL)
    %! Correctly sample table

    %format the table with useful headers
    raw_table.Properties.VariableNames{'Dev6_ai18'} = 'RHL_Fx';
    raw_table.Properties.VariableNames{'Dev6_ai19'} = 'RHL_Fy';
    raw_table.Properties.VariableNames{'Dev6_ai20'} = 'RHL_Fz';
    raw_table.Properties.VariableNames{'Dev6_ai21'} = 'RHL_Tx';
    raw_table.Properties.VariableNames{'Dev6_ai22'} = 'RHL_Ty';
    raw_table.Properties.VariableNames{'Dev6_ai23'} = 'RHL_Tz';
    raw_table.Properties.VariableNames{'Dev6_ai32'} = 'LHL_Fx';
    raw_table.Properties.VariableNames{'Dev6_ai33'} = 'LHL_Fy';
    raw_table.Properties.VariableNames{'Dev6_ai34'} = 'LHL_Fz';
    raw_table.Properties.VariableNames{'Dev6_ai35'} = 'LHL_Tx';
    raw_table.Properties.VariableNames{'Dev6_ai36'} = 'LHL_Ty';
    raw_table.Properties.VariableNames{'Dev6_ai37'} = 'LHL_Tz';
    raw_table.Properties.VariableNames{'Dev6_ai38'} = 'FL_Fx';
    raw_table.Properties.VariableNames{'Dev6_ai39'} = 'FL_Fy';
    raw_table.Properties.VariableNames{'Dev6_ai48'} = 'FL_Fz';
    raw_table.Properties.VariableNames{'Dev6_ai49'} = 'FL_Tx';
    raw_table.Properties.VariableNames{'Dev6_ai50'} = 'FL_Ty';
    raw_table.Properties.VariableNames{'Dev6_ai51'} = 'FL_Tz';

    t0 = raw_table.Timestamp(1);
    raw_table.Timestamp = raw_table.Timestamp - t0;


   %subtract the biases from each voltage in order to get rid of the force of the plexiglass 
   raw_table{:, 1:6} = raw_table{:, 1:6} - biasRHL;
   raw_table{:, 7:12} = raw_table{:, 7:12} - biasLHL;
   raw_table{:, 13:18} = raw_table{:, 13:18} - biasFL;

   %multiply the working matrix and the best voltage output matrix
   raw_table{:, 1:6} = (RHL * raw_table{:, 1:6}')';
   raw_table{:, 7:12} = (LHL * raw_table{:, 7:12}')';
   raw_table{:, 13:18} = (FL * raw_table{:, 13:18}')';

end

function bias = biasVector(columnStart,biasTable)
    %take the mean of each row that coresponds to the the sensor we are
    %finding the bias for. The mean leaves out the outliers in the data
    bias = [
        mean(rmoutliers(biasTable{:,columnStart})), ...
        mean(rmoutliers(biasTable{:,columnStart+1})), ...
        mean(rmoutliers(biasTable{:,columnStart+2})), ...
        mean(rmoutliers(biasTable{:,columnStart+3})), ...
        mean(rmoutliers(biasTable{:,columnStart+4})), ...
        mean(rmoutliers(biasTable{:,columnStart+5}))
        ];
end

function T = CoPTableConcat(T)
    %thickness of plexiglass in meters (unsure of this value thus far)
    z = 0.0056;

    %Calculated values that put the sensors on the same plane with the
    %same orientation
    RHL_rotation_angle = -177.3;
    RHLy_translation = .1332;
    RHLx_translation = 0.11126;
    %find the x and y value for the RHL sensor and align those values
    %with the entire platform.
    xRHL = ((z * T.RHL_Fx(:)) - T.RHL_Ty(:)) ./ T.RHL_Fz(:);
    yRHL = (T.RHL_Tx(:) - (z * T.RHL_Fy(:))) ./ T.RHL_Fz(:);
    xiRHL = ((xRHL .* cosd(-177.3)) + (yRHL .* sind(RHL_rotation_angle))) + RHLx_translation;
    yiRHL = ((-(xRHL) .*sind(-177.3)) + (yRHL .*cosd(RHL_rotation_angle))) + RHLy_translation;
    
    %Calculated values that put the sensors on the same plane with the
    %same orientation
    LHL_rotation_angle = 161.4;
    LHLy_translation = .044;
    LHLx_translation = 0.11126;
    %find the x and y value for the LHL sensor and align those values
    %with the entire platform.
    xLHL = ((z .*T.LHL_Fx(:)) - T.LHL_Ty(:)) ./ T.LHL_Fz(:);
    yLHL = (T.LHL_Tx(:) - (z .* T.LHL_Fy(:))) ./ T.LHL_Fz(:);
    xiLHL = ((xLHL .* cosd(LHL_rotation_angle)) + (yLHL .*sind(LHL_rotation_angle))) + LHLx_translation;
    yiLHL = ((-(xLHL) .* sind(LHL_rotation_angle)) + (yLHL .*cosd(LHL_rotation_angle))) + LHLy_translation;

    %Calculated values that put the sensors on the same plane with the
    %same orientation
    FL_rotation_angle = -162.7;
    FLy_translation = .0886;
    FLx_translation = 0.03216;
    %find the x and y value for the FL sensor and align those values
    %with the entire platform.
    xFL = ((z .* T.FL_Fx(:)) - T.FL_Ty(:)) ./ T.FL_Fz(:);
    yFL = (T.FL_Tx(:) - (z .* T.FL_Fy(:))) ./ T.FL_Fz(:);
    xiFL = ((xFL .* cosd(FL_rotation_angle)) + (yFL .* sind(FL_rotation_angle))) + FLx_translation;
    yiFL = ((-(xFL) .* sind(FL_rotation_angle)) + (yFL .* cosd(FL_rotation_angle))) + FLy_translation;
    
    %Find the x center of Pressure between all three sensors
    CoPx = ((T.RHL_Fz(:) .* xiRHL) + (T.LHL_Fz(:) .* xiLHL) + (T.FL_Fz(:) .* xiFL)) ./ (T.RHL_Fz(:) + T.LHL_Fz(:) + T.FL_Fz(:));

    %Find the x center of Pressure between all three sensors
    CoPy = ((T.RHL_Fz(:) .* yiRHL) + (T.LHL_Fz(:) .* yiLHL) + (T.FL_Fz(:) .* yiFL)) ./ (T.RHL_Fz(:) + T.LHL_Fz(:) + T.FL_Fz(:));

    % Append center of pressure data to table
    T = [T table(CoPy)];
    T = [T table(CoPx)];

    T = [T, table(xiRHL)];
    T.Properties.VariableNames{'xiRHL'} ='CoPxRHL';
    T = [T table(xiLHL)];
    T.Properties.VariableNames{'xiLHL'} ='CoPxLHL';
    T = [T, table(xiFL)];
    T.Properties.VariableNames{'xiFL'} ='CoPxFL';
    
    T = [T, table(yiRHL)];
    T.Properties.VariableNames{'yiRHL'} ='CoPyRHL';
    T = [T table(yiLHL)];
    T.Properties.VariableNames{'yiLHL'} ='CoPyLHL';
    T = [T, table(yiFL)];
    T.Properties.VariableNames{'yiFL'} ='CoPyFL';
end