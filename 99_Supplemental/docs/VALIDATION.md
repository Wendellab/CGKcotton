# Validation and limits

The original adapted entry points were checked against external author-supplied inputs during repository preparation. Ten R analysis tasks completed with exit code 0; all 13 active R files and 15 Python helpers passed syntax checks. Figure previews were inspected. After publication redaction, syntax checks were repeated on the generalized active entry points.

Private paths, contact details, licensing values, and sample metadata files are excluded from publication. Historical sample identifiers appearing in example commands have been replaced by SAMPLE_ placeholders. These production templates require local configuration before execution and are not claimed to reproduce historical runs without that configuration.

Bash syntax-only checks of the source workflows found three historical notebook files containing non-shell material: liftoff.sh, liftoff2.sh, and geneinformation.sh. Other checked shell files parsed. Syntax checks do not validate data paths, scientific choices, or intermediate filenames.

No raw-read processing, genotype calling/liftover, original f2 extraction, full GENESPACE run, Julia/SNaQ inference, full new Twisst inference, or MCMCtree inference was repeated. MCMC convergence, ESS, calibration sensitivity, and model selection remain for author evaluation. The dated-tree task only replots supplied outputs.

Initial sandboxed R processes failed on shutdown; checks repeated outside that sandbox completed successfully. No original input datasets or production scripts were edited. Tests and generated datasets/figures are not uploaded.

## Numbered analysis layout

After reorganization, all 24 retained R files and 11 Python files passed syntax parsing. The relocated shared runner completed the mapping task with exit status 0 using staged input data. Repository-relative Markdown links were checked against the published file set. Analysis task names and external input layout are unchanged. Full inference pipelines were not rerun.
