function [RMSE,maxerr] = rmse(err)
    [m,n] = size(err);
    if m>n  
        RMSE = sqrt(1/length(err)*sum(err.^2,1));  %����������
    else
        RMSE = sqrt(1/length(err)*sum(err.^2,2)); %����������
    end
    
    maxerr = max(abs(err));
end