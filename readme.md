# Convolutional Neural Networks on Surfaces via Seamless Toric Covers
Implementation of the SIGGRAPH 2017 paper "Convolutional Neural Networks on Surfaces via Seamless Toric Covers"
Haggai Maron, Meirav Galun, Noam Aigerman, Miri Trope, Nadav Dym, Ersin Yumer, Vladimir G. Kim, Yaron Lipman 

## Abstract
The recent success of convolutional neural networks (CNNs) for image processing tasks is inspiring research efforts attempting to achieve similar success for geometric tasks. One of the main challenges in applying CNNs to surfaces is defining a natural convolution operator on surfaces.

In this paper we present a method for applying deep learning to sphere-type shapes using a global seamless parameterization to a planar flat-torus, for which the convolution operator is well defined. As a result, the standard deep learning framework can be readily applied for learning semantic, high-level properties of the shape. An indication of our success in bridging the gap between images and surfaces is the fact that our algorithm succeeds in learning semantic information from an input of raw low-dimensional feature vectors.

We demonstrate the usefulness of our approach by presenting two applications: human body segmentation, and automatic landmark detection on anatomical surfaces. We show that our algorithm compares favorably with competing geometric deep-learning algorithms for segmentation tasks, and is able to produce meaningful correspondences on anatomical surfaces where hand-crafted features are bound to fail.


 
Note:
------------------------------------------------------------
The training code is heavily based on the code of the original FCN paper 
(Fully Convolutional Models for Semantic Segmentation', Jonathan Long, Evan Shelhamer and Trevor Darrell, CVPR, 2015 ) 
https://github.com/vlfeat/matconvnet-fcn 
 
Prerequisites:
------------------------------------------------------------
1. Download Matconvnet from http://www.vlfeat.org/matconvnet/ and put it under the training directory,
2. compile it.
3. Download the fcn32 network http://www.vlfeat.org/matconvnet/models/pascal-fcn32s-dag.mat and put it under training/base_net
4. This code was tested on matlab 2015a on linux only.
 
How to use the code
------------------------------------------------------------
The code is composed of three parts, each in a different directory. Before using it you should add all the files to the path. 
each file mentioned below should be ran from it's respective "code" directory:
1. data generation: the file make_data.m makes all the data necessary for training. 
You should put your meshes under dataGeneration/data/train or dataGeneration/data/test and select the preferred output folder (train_processed/test_processed).
Currently the file supports .ply files. this can be easily changed to support other formats.
The labels files should have a single label per face in each line, and should have the same name as the mesh files but with txt extension
 
2. training: Run the file fcnTrain.m. This will train on the files in train_processed you have created. This code uses GPU.
 
3. Prediction: run the file generateSegmentationsPerTriplet.m to generate predictions on the files in train_processed. 
After this predictions were calculated, go to the predictions/output/XXX directory in which the predictions were saved and run the file postprocessAggregateSegmentations.m 
This will generate aggregated results from multiple triplets.
 
 
Disclaimer:
------------------------------------------------------------
The code is provided as-is for academic use only and without any guarantees. Please contact the authors to report any bugs.
 
Contact:
------------------------------------------------------------
haggaimaron@gmail.com
 
 
