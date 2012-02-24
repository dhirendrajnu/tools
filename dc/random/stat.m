% Output Variable Statistics
% USAGE : stat(VAR) OR stat VAR

% Deepak Cherian
% TODO: Accept cell, struct input
%       missing columns in each row
%       missing rows in each column

% CHANGE LOG:
% Prevent computing median if n > 10^6                          23 Feb 2012
% Small bugfixes to output formatting criterion                 21 Feb 2012
% Changed 'if' output criterion from min -> median              06 Feb 2012
% Catches structure / cell input and prints error.              16 Jan 2012
% Colored output for complex and empty variables!               16 Jan 2012
% Now outputs name too.                                         04 Jan 2012
% More neatness changes                                         30 Dec 2011
% Appends ellipsis if number of missing columns > 10            04 Dec 2011
% Added median to output and neatened output formatting         04 Dec 2011
% Skips calculating rank / std if there are Inf's               24 Apr 2011
% Maximum number of empty column numbers printed out is now 10. 18 Feb 2011
% Upper bound on maximum number of elements (10^6)              15 Feb 2011
% Quits early if input is a logical variable                    07 Jan 2011
% Outputs type of variable & isreal()                           22 Nov 2010
% Added support for dim > 2 variables. Skips rank,var,std.      17 Nov 2010
% Exponential notation when input < .2f precision               17 Oct 2010
% Supports 'stat var1' syntax,                                  13 Oct 2010
% Original Version,                                             17 Aug 2010

function [] = stat(var1)

    name = inputname(1);

    if ischar(var1)
       name = var1;
       var1 = evalin('caller',var1);
    end   
    
    % Print out size first
    s = size(var1);
    n = numel(var1);
    fprintf('\n\t %15s: %s \n\t %15s: %s ','Name',name,'Data Type', class(var1));
    
    if isreal(var1)
        fprintf('\n\t %15s: Real ', 'IsReal');
    else % complex output
        try
            cprintf('Red','\n\t %15s: Complex ', 'IsReal');
        catch ME
            fprintf('\n\t %15s: Complex*** ', 'IsReal');
        end
    end
    
    fprintf('\n\n\t %15s:  [','Size');
    fprintf('%d ', s);
    fprintf('\b]');
    
    if ~isnumeric(var1)
        try
            cprintf('Red','\n\t\t\t Variable is not numeric: Structure / cell?.\n\n');
        catch ME
            fprintf('\n\t\t\t Variable is not numeric: Structure / cell?.\n\n');           
        end
        return
    end
    
    if isempty(var1)
        try
            cprintf('Red','\n\t\t\t Variable is empty.\n\n');
        catch ME
            fprintf('\n\t\t\t Variable is empty.\n\n');           
        end
        return
    end
    
    miss = find(isnan(var1));
    if ~isempty(miss)
        miss = length(miss);
    else
        miss = 0;
    end
    
    if n < 10^6
        comp = abs(nanmedian(var1(:))); 
        med = comp; 
    else
        comp = abs(nanmin(var1(:)));
        med = NaN;
    end
    
    % Now print standard statistics
    if (comp > 0.005 || comp == 0) && (comp < 500000)
        fprintf(' \n\t %15s: % 6.2f \n\t %15s: % 6.2f \n\t %15s: % 6.2f \n\t %15s: % 6.2f ', ...% ...
                'Max',nanmax(var1(:)), 'Min', nanmin(var1(:)), 'Mean', nanmean(var1(:)), ...
                'Median', med);
    else
        fprintf(' \n\t %15s: % 1.3e \n\t %15s: % 1.3e \n\t %15s: % 1.3e \n\t %15s: % 1.3e ', ...% ...
                'Max',nanmax(var1(:)), 'Min',nanmin(var1(:)), 'Mean',nanmean(var1(:)), ...
                'Median',med);
    end
    
    mcount = 0;
    
    % Rank, Var & Std don't work for dim > 2 arrays    
    % Skipping missing columns because that doesnt seem to make much sense for ND arrays
    % None of the rest is valid for logical arrays either
    if ~(length(s) > 2 || islogical(var1))    
    
        if n > 10^6, warning('\n\n Terminating because array is too large. \n\n'); return; end

        % Ouput var, std   
        if comp > 0.005 && (comp < 500000)
            fprintf('\n\t %15s: % 6.2f \n\t %15s: % 6.2f', 'Variance', nanvar(var1(:)), 'Std', nanstd(var1(:)));
        else
            fprintf('\n\t %15s: % 1.3e \n\t %15s: % 1.3e', 'Variance', nanvar(var1(:)), 'Std', nanstd(var1(:)));
        end
        
        % Output missing data information
        if (comp > 0.005 || comp == 0) && (comp < 500000)
            fprintf(' \n\t %15s:  %d/%d (%.2f %%) | Difference = %d', ...% ...
                    'Missing', miss, n, miss/(n)*100, n-miss);
        else
            fprintf(' \n\t %15s:  %d/%d (%.2f %%) | Difference = %d', ...% ...
                    'Missing',miss, n, miss/n*100, n-miss);
        end    

        % If NaN's in multi-column array check whether entire column is NaN
        if s(2)~=1 && miss ~= 0
            for i=1:s(2)
                miss1=size(find(isnan(var1(:,i))),1);
                if miss1 == s(1)
                    mcount = mcount+1;
                    ind(mcount)=i;
                end
            end

            if mcount ~= 0 
                fprintf('\n\t %15s:  %d (', 'Missing Columns', mcount);       
                for i=1:min(10,mcount)
                    fprintf('%d ', ind(i));
                end
                if mcount > 10, fprintf('... '); end
                fprintf('\b)');
            end
        end

        if max(var1(:)) == Inf, fprintf('\n\n');return; end
        % Calculate rank only when there are no NaN's
        if miss == 0 , fprintf('\n\t %15s:  %d/%d  \n\n','Rank', rank(var1),s(2)); end
    
    else
        % Output missing data information
        if (comp > 0.005 || comp == 0)  && (comp < 500000)
            fprintf(' \n\t %15s:  %d/%d (%.2f %%) | Difference = %d', ...% ...
                    'Missing', miss, n, miss/(n)*100, n-miss);
        else
            fprintf(' \n\t %15s:  %d/%d (%.2f %%) | Difference = %d', ...% ...
                    'Missing',miss, n, miss/n*100, n-miss);
        end
        
        fprintf('\n\n');
        return; 
    end
    
    