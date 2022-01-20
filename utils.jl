function ginput_routine(clicks, image_file)
    #waits for a defined number of user's clicks on the image file
    #rounds the click coordinates up or down for correct indexing
    
    #Parameters
    #clicks : int
    #image_file : string
    

    p = ginput(clicks); 
    pp = collect(Iterators.flatten(p));
    if pp[1] > 1
        wmin = Int.(floor(pp[1]));
    else
        wmin = 1;
    end

    if pp[2] > 1
        hmin = Int.(floor(pp[2]));
    else
        hmin = 1;
    end 

    if pp[3] > size(image_file,2)
        wmax = size(image_file,2);
    else
        wmax = Int.(ceil(pp[3]));
    end

    if pp[4] > size(image_file,1)
        hmax = size(image_file,1);
    else
        hmax = Int.(ceil(pp[4]));
    end
    
#crop = kymograph[hmin:hmax,wmin:wmax];
#imshow(crop);
    return hmin, hmax, wmin, wmax

end

function set_gui()
    #setting the correct gui backend to properly display figures and record click coordinates
    ENV["MPLBACKEND"]="tkagg";
    pygui(true);
    return nothing
end

function fit_gaussian(xdata, ydata, a, b, c, d, dsd)
    #fit a gaussian using the LsqFit package
    #Initial parameters:
    #kymoline - one line in the cropped kymograph to fit
    #a - peak height (estimated from initial brightness of the spot)
    #b - peak position (estimated from initial position of the spot)
    #c - peak width
    #d - background
    #dsd - noise (2xSD of background)
    
    @. model(x, y) = y[4] + (y[1]*exp(-((x-y[2])/y[3])^2));

    y0 = [a, b, c, d];

    fit = curve_fit(model, xdata, ydata, y0);
    lb = [a-dsd, b-5, c, d-dsd];
    ub = [a+dsd, b+5, c, d+dsd];
    y0_bounds = [a, b, c, d];

    fit_bounds = curve_fit(model, xdata, ydata, y0_bounds, lower=lb, upper=ub);
       
    return coef(fit)[1],coef(fit)[2],coef(fit)[3],coef(fit)[4]
    
end

function fix_gaussian(xdata, ydata, a, b, c, d, dsd)
    #fit a gaussian using the LsqFit package
    #Initial parameters:
    #kymoline - one line in the cropped kymograph to fit
    #a - peak height (estimated from initial brightness of the spot)
    #b - peak position (estimated from initial position of the spot)
    #c - peak width (set to 1.3)
    #d - background
    #dsd - noise (2xSD of background)
    
    @. model(x, y) = y[4] + (y[1]*exp(-((x-y[2])/y[3])^2));

    y0 = [a, b, c, d];

    fit = curve_fit(model, xdata, ydata, y0);
    lb = [a-d-dsd, b-0.01, c-0.01, d-dsd];
    ub = [a+dsd, b+0.01, c+0.01, d+dsd];
    y0_bounds = [a, b, c, d];

    fit_bounds = curve_fit(model, xdata, ydata, y0_bounds, lower=lb, upper=ub);
       
    return coef(fit)[1],coef(fit)[2],coef(fit)[3],coef(fit)[4]
    
end