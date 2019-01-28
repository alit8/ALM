function [X, narrow_path, spread] = ids(x, y, showfigs)

    endpx = [min(x) - 0.1, max(x) + 0.1];
    rangex = endpx(1):.01:endpx(2);

    endpy = [min(y) - 0.1, max(y) + 0.1];
    rangey = endpy(1):.01:endpy(2);
    [pX, pY] = meshgrid(rangex, rangey);

    for r_coeff = [.1, .2, .5, 1]
            page = zeros(length(rangey), length(rangex));
            R = r_coeff * sqrt((rangex(end) - rangex(1)) .^ 2 + (rangey(end) - rangey(1)) .^ 2);
            for cnt = 1:length(y)
                cnt
                x0 = x(cnt);
                y0 = y(cnt);

                exfunc = @(x, y) floor(R + 1 - sqrt((x - x0) .* (x - x0) + (y - y0) .* (y - y0))) * double(R + 1 - sqrt((x - x0) .* (x - x0) + (y - y0) .* (y - y0)) > 0); 
                page = page + arrayfun(exfunc, pX, pY);
            end
            thrsh = (page ~= 0);
            CC = bwconncomp(thrsh, 8);
         if CC.NumObjects == 1
             break;
         end
    end

    X = rangex.';
    [narrow_path, spread] = calcNarrowPathAndSpread(rangey, page, R, max(y));
    if showfigs
        plotfig = figure; 
        plot(X, narrow_path);
        % hgsave(['plot', num2str(plotfig), '.fig']);
        img = uint8(255 - 255 * page /max(max(page)));
        imgfig = figure; imshow(img(end:-1:1, :));
        %hgsave(['ids', num2str(imgfig), '.fig']);
    end
end