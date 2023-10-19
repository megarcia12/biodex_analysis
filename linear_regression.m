function [equation, r_squared, rmse] = linear_regression(x, y)
    % x and y are two arrays of data
    % Calculate the coefficients
    coeffs = polyfit(x, y, 1);
    slope = coeffs(1);
    intercept = coeffs(2);
    % Create the equation
    equation = sprintf('y = %.4fx + %.4f', slope, intercept);
    % Calculate the correlation coefficient R2
    y_fit = polyval(coeffs, x);  % Evaluate the line
    r_squared = 1 - sum((y - y_fit).^2) / sum((y - mean(y)).^2);
    predicted = (x .*slope) + intercept;
    sumDiff = 0;
    for i = 1:numel(x)
        sumDiff = sumDiff + (y(i) - predicted(i))^2;
    end
    rmse = sqrt(sumDiff / numel(x));
end