# flexibleConCreation
Create standard contrasts + adjust for missing conditions flexibly

TO CREATE CONTRAST VARS:
(1) create txt file: contrastNames_fxSuffix.txt, one contrast name per line (example in flexibleConCreation/conInfo/)
(2) create txt file: contrastWeights_fxSuffix.txt, a matrix of weights, one contrast per line, tab delimited (example in flexibleConCreation/conInfo/)
(3) create txt file: condsRemoved_fxSuffix.txt, a sub x cond matrix specifying missing (1) and existing (0) conditions (example in flexibleConCreation/conInfo/)
(4) make contrast mats for each sub, using matlab script makeCustomConMats.m (output goes to flexibleConCreation/customCons/, you can change that)

TO USE CONTRAST VARS IN MAKING TEMPLATE FOR CON999
(3) make batch template for con999 for subject1 (index 999). Use "load matlab variables" and "access matlab variables" modules.

TO REPLICATE FOR ALL CONS & ALL SUBS
(4) replicate this for contrasts 1 through N using bash script (sed-fest)
Use sed to replace fx folder name, contrastMatrix.mat filename, and contrast numbers 1thruN.
(5) Load N contrasts into batch editor, save as .mat, and use SPMBATCH to replicate for all subjects