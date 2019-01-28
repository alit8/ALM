function [ np, spread ] = calcNarrowPathAndSpread( rangey, page, R, ymax )

    dark_scan = cumsum(page, 1);
    np = zeros(size(page, 2), 1);
    spread = zeros(size(page, 2), 1);

    for cnt = 1:size(page, 2)
        ind1 = find(dark_scan(:, cnt) <= dark_scan(end, cnt) / 2, 1, 'last');
        ind2 = find(dark_scan(:, cnt) >= dark_scan(end, cnt) / 2, 1, 'first');
        np(cnt) = (rangey(ind1) + rangey(ind2)) / 2;
    end
    %np = mean((rangey.' * ones(1, size(page, 2))) .* page, 1).';
    for cnt = 1:size(page, 2)
            ind1 = find(page(:, cnt) > 0, 1, 'first');
            ind2 = find(page(:, cnt) > 0, 1, 'last');
            if (isempty(ind1))
                ind1 = 0;
            end
            if (isempty(ind2))
                ind2 = size(page, 1) + 1;
            end 
            step_size = rangey(2) - rangey(1);
            spread(cnt) = step_size * (ind2 - ind1 + 1);
    end
    %cs = 1.1 * (2 * R + 1);
    %rs = 0.2;
    %ymax = step_size * (size(page, 1) + 1 - 0 + 1);
    %ymax = max(rangey);


    %spread = std((rangey.' * ones(1, size(page, 2))) .* page, 0, 1);
    %spread = std(((1:length(rangey)).' * ones(1, length(rangex))) .* page, 1, 1);
    % all(isreal((((spread - cs) / ymax / rs) .^ 2)))
    % pause
    %spread = exp(-(((spread - cs) / ymax / rs) .^ 2));
    
end
