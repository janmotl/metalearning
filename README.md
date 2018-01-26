Feature Meta-learning on Relational Data
================
The common order of processes in data preparation for machine learning is:

	      (feature engineering)             (feature selection)
	data -----------------------> features ---------------------> features
    
But we managed to swap the order of feature engineering with feature selection:

	      (feature selection)             (feature engineering)
	data ---------------------> features -----------------------> features

**What is the gain?** 
Based on the performed experiments, it is enough to engineer only *the top decile* of all candidate features to get accuracy comparable to accuracy obtained on all features. That means that you can reduce the runtime of feature engineering ~10 times without sacrificing the accuracy of the model.

**Applications** 
Large or complex databases where it is impossible or inconvenient to calculate all features.

**How?**
With application of meta-learning. The meta-learner utilizes two sources of knowledge that guide the feature selection:
1. External (acquired from other databases)
2. Internal (acquired from the database)

**Utilized meta-features**
There are three categories of meta-features, based on which the meta-learner estimates *utility* of features:
1. Landmark performance of a few selected features
2. Properties of feature (generative) functions
3. Properties of the data

**Feature utility**
We prefer features that are:
1. Relevant to the task (evaluated with Chi2 in case of classification)
2. Fast to calculate
3. Non-redundant

The estimated feature utility is then an amalgam if these three estimates.

Dependencies
==================
1.  RapidMiner (to train the meta-learner)
2.  MATLAB (to run experiments)
3.	Excel (to see the measured values from the experiments)
4.	R (to interpret the experiment results)

Limitations
======
Implemented only for relational data (specifically in SQL databases).

