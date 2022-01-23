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
    lb = [a-dsd, b-6, c*1.1, d-dsd];
    ub = [a+dsd, b+6, c*0.9, d+dsd];
    y0_bounds = [a, b, c, d];

    fit_bounds = curve_fit(model, xdata, ydata, y0_bounds, lower=lb, upper=ub);
    return fit.param[1],fit.param[2],fit.param[3],fit.param[4]   
#    return coef(fit)[1],coef(fit)[2],coef(fit)[3],coef(fit)[4]
    
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

function sort_positions(datapath, size_threshold, windowlength);
    fnames = (filter(ext->endswith(ext, ".txt"), readdir(datapath)));
    fluo_count = zeros(length(fnames));
    timestep = readdlm(string(datapath, fnames[1]))[1,1];
    window = Int.(ceil(windowlength/timestep));
    wpositions = [];    
    ncount = [];
    for m in 1:length(fnames)
        timesec = readdlm(string(datapath, fnames[m]))[:,1];
        position = readdlm(string(datapath, fnames[m]))[:,2];
        intensity = readdlm(string(datapath, fnames[m]))[:,3];
        
        if length(intensity) < window 
            fluo_count[m] = mean(intensity)/fluo_price;
        else
            fluo_count[m] = mean(intensity[1:window])/fluo_price;
        end
        
        if fluo_count[m] > size_threshold
            continue
        elseif length(intensity) < window
            continue
        else
            l_iter = length(position) - (window-1);
            for j in 1:l_iter
                append!(wpositions, position[j:window+j-1]);
            end
        end
    end
    for i in 1:length(fluo_count)
        if fluo_count[i] < size_threshold
            append!(ncount, 1);
        end
    end
    all_positions = copy(reshape(wpositions, window, :));    
    sqdisp = zeros(size(all_positions));
    output = zeros(size(sqdisp)[1],5);
    
    for p in 1:size(all_positions)[2]
        for q in 1:window
            sqdisp[q,p] = (all_positions[q,p] - all_positions[1,p])^2;
        end
    end
    for l in 1:size(sqdisp)[1]
        output[l,1] = timestep * (l-1);
        output[l,2] = mean(sqdisp[l,:]);
        output[l,3] = std(sqdisp[l,:]);
        output[l,5] = sum(ncount);
        output[l,4] = output[l,3]/(output[l,5]^0.5);
    end
    
    return sqdisp, fluo_count, output
end

function linfit_o(xdata,ydata,slope,intercept)
    @. linmodel(x, y) = y[2] + y[1]*x;
    y0 = [slope,intercept];
    fit = curve_fit(linmodel, xdata, ydata, y0);
    lb = [slope*0.8, 0];
    ub = [slope*1.2, 0];
    y0_bounds = [slope,intercept];
    fit_bounds = curve_fit(linmodel, xdata, ydata, y0_bounds, lower=lb, upper=ub);
    
    return coef(fit)[1], coef(fit)[2]
end