# flexibleConCreation
Create standard contrasts + adjust for missing conditions flexibly

FIRST:
Specify + estimate your model. 
This requires that you already have an estimated SPM.mat that you'd like to run contrasts on.

TO CREATE CONTRAST VARS:
(1) create txt file: contrastNames_analysis.txt, one contrast name per line (example in flexibleConCreation/conInfo/)
(2) create txt file: contrastWeights_analysis.txt, a matrix of weights, one contrast per line, tab delimited (example in flexibleConCreation/conInfo/)
(3) create txt file: condsRemoved_analysis.txt, a sub x cond matrix specifying missing (1) and existing (0) conditions (example in flexibleConCreation/conInfo/)
(4) make contrast mats for each sub, using matlab script makeCustomConMats.m (output goes to flexibleConCreation/customCons/, but you should change that)

NOTE:
Normally we create a template script for a template subject, and replicate it across subs.
In this case, we'll first make a template script for a single contrast (for sub 1), and then replicate it across CONTRASTS.
Then, we can use the N contrasts created to make a script for a template sub.
Finally, we replicate across subs as we usually would.

MAKE TEMPLATE FOR SUB 1, CON999:
- make batch template for con999 for subject1 (use index 999 at end of filename). 
- Use "load matlab variables" and "access matlab variables" modules.

REPLICATE FOR ALL CONS & ALL SUBS:
- Replicate this for contrasts 1 through N using the bash script (it's really primitive and uses "sed" to replace contrast numbers, but it works!)
- Load N contrasts into batch editor, save as .mat, and use spmbatch.m to replicate for all subjects as usual