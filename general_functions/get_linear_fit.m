function [R2, r] = get_linear_fit(x_values, y_values)
    %% Finding line of best fit and linear values
    p = polyfit(x_values, y_values, 1);   % p returns 2 coefficients fitting r = a_1 * x + a_2
    r = p(1) .* x_values + p(2); % compute a new vector r that has matching datapoints in x
    %% Calculate 2^2
    f = polyval(p, x_values);
    Bbar = mean(y_values);
    SStot = sum((y_values - Bbar).^2);
    SSres = sum((y_values - f).^2);
    R2 = 1 - SSres/SStot;
end