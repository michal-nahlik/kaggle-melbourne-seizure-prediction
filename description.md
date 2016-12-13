Description
-----------
This is code used for [Melbourne University AES/MathWorks/NIH Seizure Prediction](https://www.kaggle.com/c/melbourne-university-seizure-prediction) 2016. My solution ended **8th on the private leaderboard** and it is based on **Classification decision trees** with **0.80396 AUC** on public leaderboard and **0.79074 AUC** on private leaderboard.

Software
--------
Matlab 2014a

Data
----
I used all data files marked as safe in *train_and_test_data_labels_safe.csv*. No preprocessing was done.

Features
--------
Features were calculated on the whole 10 minute files for each channel without splitting into any shorter epochs. 

I basically took all the features from sample submission script and added few more based on my hunch and some articles about this topic. The features included:

-	mean value, standard deviation, skewness, kurtosis, spectral edge, Shannon’s entropy (for signal and Dyads), Hjorth parameters, several types of fractal dimensions
-	singular values of 10 scale wavelet transformation using Morlet wave
-	maximum correlation between channels in interval -0.5,+0.5 seconds, correlation between channels in frequency domains, correlation between channels power spectrums at each dyadic level

I had 73 features in total for each channel, only the real part of features was used.

Cross validation
----------------
I used *cvpartition* from Statistical toolbox which can create random partitions where each subsample has equal size and roughly the same class proportions. I did not care about sequences which caused my local AUC results to be around 0.1 higher than the leaderboard ones.

Model
-----
A classification decision tree model was created for each channel and patient, the mean output across channels for the patient was used as the outcome. Models were trained with 10 fold cross validation to prevent overfitting.
Because we had only 2 classes the *Exact* training algorithm was used (see Matlab documentation for *fitctree* for more details).

Training models and generating output for each patient took in all cases under one minute.

The most important predictors across all decision trees were: correlation between channel power spectrums at dyadic levels, spectral edge, Shannon’s entropy for Dyads, mean value and 3rd estimate of fractional Brownian motion.

Discussion
----------
I tried to make both single subject models and general model as the general model might be more useful. Both approaches actually reached the same scores on leaderboard, which is probably caused by the fact that the general model was trained on all subjects on which it was then tested. That might allow decision trees to grow different branches for each subject at some part and thus reaching the same score as single subject models. When I tried to cross validate general model by subject (2 subjects used for training, 1 subject for testing) the results got much worse, around 0.6 AUC. In guess I would have to normalize the features to make the general model work for unseen subjects, but I did not have time to pursue this idea.


File structure description
------------------
- **/explore** - calculates predictor importance of the saved models
- **/features** - code to calculate features
- **/main** - functions to execute (train/load and run) the models 
- **/model** - helper functions for working with models
- **/opt** - model options optimization for each subject
- **/util** - functions for loading data, setting environment, evaluation, creating submission ...
- **settings.m** - file containing basic settings including data paths
- **models.zip** - archive containing pretrained models for each subject and channels which can be loaded and used to create submission with */main/run_trained_dt.m* 

Instructions
------------
 **Preparation**

 1. Download and unpack [data](https://www.kaggle.com/c/melbourne-university-seizure-prediction/data), train_and_test_data_labels_safe.csv and sample_submission.csv
 2. Change file/folder paths in **settings.m**

**Feature extraction**

 1. execute **/features/run_generate_features.m** 
 2. copy features from the old (leaked) test files into the the training feature folders (test_1 -> train_1, ...)

**Running the model**

Execute **/main/run_dt.m** to load the features, cross validate the solution and create submission. Model for each subject and channel will be created and if *opts.save_model* in settings.m is set to true, the models used for creating submission will be saved to *opts.modelDir*.

**/main/run_trained_dt.m** can be used to load the saved models and create submission for the testing data.

**/main/run_dt_general_model.m** loads data for all subjects and creates a general model (across subjects) for each channel, cross validates the solution and creates submission. This solution is cross validated the standart way and then by subject (2 subjects for training, 1 subject for testing). 

**Evaluation on new data**

Probably the easiest way is:

1. add new training data file names, classes and safe indication into the *train_and_test_data_labels_safe.csv*
2. store the new data in folders using the current naming conventions
3. create new submission file with new test files using the same structure
4. change all paths, subject names, data folders accordingly in settings and feature extractor
5. run feature extractor and execute model
