% {intensity_threshold, channel filename character}
y_param = {0.12, 'y'};
r_param = {0.07, 'r'};
area_thresh = 400;
num_doses = 64; 

usrC = strsplit(pwd,'/');
currpath =strjoin(usrC,'/');
data_path = [currpath '/'];
fex_code_path = ['/Users/' usrC{3} '/Documents/MIT/Weiss Lab/microscopy/cbrewer'];
addpath(genpath(fex_code_path))

simdirs = {'replicate1_sim/', 'replicate2_sim/', 'replicate3_sim/'};
expdirs = {'replicate1_exp/', 'replicate2_exp/', 'replicate3_exp/'};

if ~exist('data_sim.mat')
        threshold_sim_rep1()
        threshold_sim_rep2()
        threshold_sim_rep3()
        out_y = clust_stats(y_param, num_doses, area_thresh, dirs);
        out_r = clust_stats(r_param, num_doses, area_thresh, dirs);
        data_sim = {out_y, out_r};
        save('data_sim','data_sim')
else 
    load('data_sim.mat')
    out_y = data_sim{1};
    out_r = data_sim{2};
end


    numClustArray = out_y{1};
    areaClustArray = out_y{2};
    
    % scale area to convert between simulated & experimental images
    % since each pixel is 5 uM, multiply by 5^2
    areaClustArray = areaClustArray .* 25 ;
    
    % show heat maps of array with image(<Array>)
    fig = figure('Position', [525 1 563 804]);
    t = tiledlayout(2,1,'TileSpacing','Compact');
    title(t, ['Simulations Y channel'])
   
    nexttile;
    h = heatmap(numClustArray, 'CellLabelColor','none');
    h.GridVisible = 'off';
    colormap viridis
    title("Avg. Number Clusters")
    caxis([0 5])
    colorbar
    
    nexttile;
    h = heatmap(areaClustArray, 'CellLabelColor','none');
    h.GridVisible = 'off';
    colormap viridis
    title("Avg. Area Clusters (sq. uM)")
    caxis([0 5e4])
    colorbar

    saveas(t, "Y-sim-heatmaps.png");
    
    numClustArray = out_r{1};
    areaClustArray = out_r{2};
    
    % scale area to convert between simulated & experimental images
    % since each pixel is 5 uM, multiply by 5^2
    areaClustArray = areaClustArray .* 25 ;
    
    fig = figure('Position', [525 1 563 804]);
    t = tiledlayout(2,1,'TileSpacing','Compact');
    title(t, ['Simulations R channel'])
    
    nexttile;
    h = heatmap(numClustArray, 'CellLabelColor','none');
    colormap viridis
    h.GridVisible = 'off';
    title("Avg. Number Clusters")
    caxis([0 5])
    colorbar
    
    nexttile;
    h = heatmap(areaClustArray, 'CellLabelColor','none');
    colormap viridis
    h.GridVisible = 'off';
    title("Avg. Area Clusters (sq. uM)")
    caxis([0 5e4])
    colorbar

    saveas(t, "R-sim-heatmaps.png");
    
if ~exist('data_exp.mat')
        out_y = clust_stats(y_param, num_doses, area_thresh, expdirs);
        out_r = clust_stats(r_param, num_doses, area_thresh, expdirs);
        data_exp = {out_y, out_r};
        save('data_exp','data_exp')
else 
    load('data_exp.mat')
    out_y = data_exp{1};
    out_r = data_exp{2};
end

numClustArray = out_y{1};
    areaClustArray = out_y{2};
    
    % show heat maps of array with image(<Array>)
    fig = figure('Position', [525 1 563 804]);
    t = tiledlayout(2,1,'TileSpacing','Compact');
    title(t, ['Experimental Y channel'])
   
    nexttile;
    h = heatmap(numClustArray, 'CellLabelColor','none');
    h.GridVisible = 'off';
    colormap viridis
    title("Avg. Number Clusters")
    caxis([0 5])
    colorbar
    
    nexttile;
    h = heatmap(areaClustArray, 'CellLabelColor','none');
    h.GridVisible = 'off';
    colormap viridis
    title("Avg. Area Clusters (sq. uM)")
    caxis([0 5e4])
    colorbar

    saveas(t, "Y-exp-heatmaps.png");
    
    numClustArray = out_r{1};
    areaClustArray = out_r{2};
    
    fig = figure('Position', [525 1 563 804]);
    t = tiledlayout(2,1,'TileSpacing','Compact');
    title(t, ['Experimental R channel'])
    
    nexttile;
    h = heatmap(numClustArray, 'CellLabelColor','none');
    colormap viridis
    h.GridVisible = 'off';
    title("Avg. Number Clusters")
    caxis([0 5])
    colorbar
    
    nexttile;
    h = heatmap(areaClustArray, 'CellLabelColor','none');
    colormap viridis
    h.GridVisible = 'off';
    title("Avg. Area Clusters (sq. uM)")
    caxis([0 5e4])
    colorbar

    saveas(t, "R-exp-heatmaps.png");


function out = clust_stats(chan_param, num_doses, area_thresh, dirs)
    intens_tresh = chan_param{1,1};
    chan = chan_param{1,2};
    
    % data structures formatted as 64 wells X channel

    [numClusters, areaClusters, malClusters] = deal(zeros(64,1));
    
    
    for d = 1:length(dirs)
       
        %parpool(3);
        for f = 1:num_doses
            
            fName = [dirs{d} 'clustered_' chan '_' num2str(f) '.png'];
            fprintf("Processing %s \n", fName)

            I = imread(fName);

            [labeled, num] = bwlabel(I);

            numClusters(f, 1) = numClusters(f, 1) + num;
            stats = regionprops(I, "Area", "MajorAxisLength");
            areaClusters(f, 1) = areaClusters(f, 1) + sum([stats(:).Area]).*.62;

           
            
        end
    end

    avg_areaClusters = areaClusters./numClusters;
    avg_malClusters = malClusters./numClusters;

    idx = 1;
    numClustArray = reshape(numClusters(:, idx), [8 8])' ./ 3;
   
    areaClustArray = reshape(avg_areaClusters(:, idx), [8 8])' ./ 3;
    areaClustArray(isnan(areaClustArray)) = 0;
    
    out{1} = numClustArray;
    out{2} = areaClustArray;
end
    
    


