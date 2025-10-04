.PHONY: release

release:
	@echo "Releasing version $(VERSION)"
	@echo "Tagging version $(VERSION)"
	git tag -a v$(VERSION) -m "Release version $(VERSION)"
	git push origin v$(VERSION)
	@echo "Creating GitHub release"
	gh release create v$(VERSION) --title "Release v$(VERSION)" --generate-notes
	@echo "Release complete"
