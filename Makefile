docs:
	/Applications/Adobe\ Flash\ Builder\ 4.6/sdks/4.6.0/bin/aasdoc		\
		-source-path ./mixpanel-as3-lib/src								\
		-doc-sources ./mixpanel-as3-lib/src/com/mixpanel/Mixpanel.as	\
		-output ./mixpanel-as3-lib/docs 								\
		-main-title "Mixpanel AS3 Library"								\
		-window-title "Mixpanel AS3 Library"

release:
	git checkout gh-pages
	git reset --hard HEAD
	git merge master
	make docs
	git commit -am "Updated Docs; Latest Release"
