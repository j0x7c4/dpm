function run_my_train(cls, n, pos_data, neg_data, numPos, numNeg)
%cls: class name of data
%n=3: number of groups
%pos_data: path of pos data
%neg_data: path of neg data
%numPos: number of pos data
%numNeg: number of neg data


% At every "checkpoint" in the training process we reset the 
% RNG's seed to a fixed value so that experimental results are 
% reproducible.
initrand();

globals;
note = datestr(datevec(now()), 'HH-MM-SS');
% record a log of the training procedure
diary([cachedir cls '.log']);

try
  load([cachedir cls '_train_' VOCyear]);
catch
    pos = data_pos(pos_data,numPos);
    neg = data_neg(neg_data,numNeg);
    file_name = [cachedir cls '_train_' VOCyear];
    disp(file_name);
    save(file_name,'pos','neg');
end
% split data by aspect ratio into n groups
spos = split(cls, pos, n);
cachesize = 24000;
maxneg = 200;
if maxneg>numNeg
    maxneg = numNeg;
end

% train root filters using warped positives & random negatives
try
  load([cachedir cls '_lrsplit1']);
catch
  initrand();
  for i = 1:n
    % split data into two groups: left vs. right facing instances
    
    models{i} = initmodel(cls, spos{i}, note, 'N');
    inds = lrsplit(models{i}, spos{i}, i);
    models{i} = train(cls, models{i}, spos{i}(inds), neg, i, 1, 1, 1, ...
                      cachesize, true, 0.7, false, ['lrsplit1_' num2str(i)]);
  end
  save([cachedir cls '_lrsplit1'], 'models');
end

% train root left vs. right facing root filters using latent detections
% and hard negatives
try
  load([cachedir cls '_lrsplit2']);
catch
  initrand();
  for i = 1:n
    models{i} = lrmodel(models{i});
    models{i} = train(cls, models{i}, spos{i}, neg(1:maxneg), 0, 0, 4, 3, ...
                      cachesize, true, 0.7, false, ['lrsplit2_' num2str(i)]);
  end
  save([cachedir cls '_lrsplit2'], 'models');
end

% merge models and train using latent detections & hard negatives
try 
  load([cachedir cls '_mix']);
catch
  initrand();
  model = mergemodels(models);
  model = train(cls, model, pos, neg(1:maxneg), 0, 0, 1, 5, ...
                cachesize, true, 0.7, false, 'mix');
  save([cachedir cls '_mix'], 'model');
end

% add parts and update models using latent detections & hard negatives.
try 
  load([cachedir cls '_parts']);
catch
  initrand();
  for i = 1:2:2*n
    model = model_addparts(model, model.start, i, i, 8, [6 6]);
  end
  model = train(cls, model, pos, neg(1:maxneg), 0, 0, 8, 10, ...
                cachesize, true, 0.7, false, 'parts_1');
  model = train(cls, model, pos, neg, 0, 0, 1, 5, ...
                cachesize, true, 0.7, true, 'parts_2');
  save([cachedir cls '_parts'], 'model');
end

save([cachedir cls '_final'], 'model');