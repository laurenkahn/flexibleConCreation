# flexibleConCreation
Create standard contrasts + adjust for missing conditions flexibly

FIRST:
- Specify + estimate your model. 
- This set of scripts requires that you already have an estimated SPM.mat that you'd like to run contrasts on.

TO CREATE CONTRAST VARS:
- (1) create txt file: contrastNames_analysis.txt, one contrast name per line (example in flexibleConCreation/conInfo/)
- (2) create txt file: contrastWeights_analysis.txt, a matrix of weights, one contrast per line, tab delimited (example in flexibleConCreation/conInfo/)
- (3) create txt file: condsRemoved_analysis.txt, a sub x cond matrix specifying missing (1) and existing (0) conditions (example in flexibleConCreation/conInfo/)
- (4) make contrast mats for each sub, using matlab script scripts/makeCustomConMats.m (output goes to flexibleConCreation/customCons/, but you should change that)

NOTE:
- Normally we create a template script for a template subject, and replicate it across subs.
- In this case, we'll first make a template script for a single contrast (for sub 1), and then replicate it across CONTRASTS.
- Then, we can use the N contrasts created to make a script for a template sub.
- Finally, we replicate across subs as we usually would.

MAKE TEMPLATE FOR SUB 1, CON999:
- An example is in spmFiles/templates/
- Should have index 999 at the end of the filename
- It will use "load matlab variables" and "access matlab variables" modules.
- YOU MUST:
(1) Update the path to the customContrasts .mat file for that subject
(2) Update the path for the SPM.mat that was created from your model specification/estimation for that subject

CREATE TEMPLATE FOR SUB 1:
- Replicate this script for contrasts 1 through N using the bash code in the .txt file (it's really primitive and uses "sed" to replace contrast numbers, but it works!)
- Just copy and paste the code from scripts/replicateConJobs.txt into the terminal, + it'll be nearly instantaneous
- You should now have N contrast scripts, for contrasts 1 thru N, for subject 1.
- Load these N contrast scripts into batch editor (in order), and save the whole thing as a .mat

REPLICATE FOR ALL SUBS:
- Use spmbatch.m to replicate for all subjects as usual