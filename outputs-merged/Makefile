

zipfile: merged
	zip -r backplane-all.zip merge/backplane-merge.* merge/README

merged: all.cfg layoutfile.cfg
	python ~/gm/gm-1.2/gerbmerge/gerbmerge.py all.cfg layoutfile.cfg

view:
	gerbv --project=backplane-merge.gerbv

