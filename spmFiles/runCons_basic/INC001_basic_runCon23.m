%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 3944 $)
%-----------------------------------------------------------------------
matlabbatch{1}.cfg_basicio.load_vars.matname = {'/vxfsvol/home/research/sanlab/Studies/Incentive/subjects/INC001/fx/regressors/contrastMatrix.mat'};
matlabbatch{1}.cfg_basicio.load_vars.loadvars.varname = {
    'contrastNames'
    'contrastCellArray'
    }';
matlabbatch{2}.cfg_basicio.subsrefvar.input(1) = cfg_dep;
matlabbatch{2}.cfg_basicio.subsrefvar.input(1).tname = 'Input variable';
matlabbatch{2}.cfg_basicio.subsrefvar.input(1).tgt_spec{1}.name = 'class';
matlabbatch{2}.cfg_basicio.subsrefvar.input(1).tgt_spec{1}.value = 'cfg_entry';
matlabbatch{2}.cfg_basicio.subsrefvar.input(1).sname = 'Load Variables from .mat File: Loaded Variable ''contrastNames''';
matlabbatch{2}.cfg_basicio.subsrefvar.input(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.cfg_basicio.subsrefvar.input(1).src_output = substruct('{}',{1});
matlabbatch{2}.cfg_basicio.subsrefvar.subsreference{1}.subsindc = {23};
matlabbatch{2}.cfg_basicio.subsrefvar.tgt_spec.s{1}.name = 'strtype';
matlabbatch{2}.cfg_basicio.subsrefvar.tgt_spec.s{1}.value = 's';
matlabbatch{3}.cfg_basicio.subsrefvar.input(1) = cfg_dep;
matlabbatch{3}.cfg_basicio.subsrefvar.input(1).tname = 'Input variable';
matlabbatch{3}.cfg_basicio.subsrefvar.input(1).tgt_spec{1}.name = 'class';
matlabbatch{3}.cfg_basicio.subsrefvar.input(1).tgt_spec{1}.value = 'cfg_entry';
matlabbatch{3}.cfg_basicio.subsrefvar.input(1).sname = 'Load Variables from .mat File: Loaded Variable ''contrastCellArray''';
matlabbatch{3}.cfg_basicio.subsrefvar.input(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{3}.cfg_basicio.subsrefvar.input(1).src_output = substruct('{}',{2});
matlabbatch{3}.cfg_basicio.subsrefvar.subsreference{1}.subsindc = {23};
matlabbatch{3}.cfg_basicio.subsrefvar.tgt_spec.e{1}.name = 'strtype';
matlabbatch{3}.cfg_basicio.subsrefvar.tgt_spec.e{1}.value = 'e';
matlabbatch{4}.spm.stats.con.spmmat = {'/vxfsvol/home/research/sanlab/Studies/Incentive/subjects/INC001/fx/fx_quick4SAN/SPM.mat'};
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name(1) = cfg_dep;
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name(1).tname = 'Name';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name(1).tgt_spec{1}.name = 'strtype';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name(1).tgt_spec{1}.value = 's';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name(1).sname = 'Access part of MATLAB variable: val{23}';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1});
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name(1).src_output = substruct('.','output');
matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec(1) = cfg_dep;
matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec(1).tname = 'T contrast vector';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec(1).tgt_spec{1}.name = 'strtype';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec(1).tgt_spec{1}.value = 'e';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec(1).sname = 'Access part of MATLAB variable: val{23}';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1});
matlabbatch{4}.spm.stats.con.consess{1}.tcon.convec(1).src_output = substruct('.','output');
matlabbatch{4}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.delete = 0;
