LIBDIR := lib
include $(LIBDIR)/main.mk

# Tree files that are included in the document
TREE_FILES := trees/capability_tree.txt trees/entitlements_tree.txt trees/installed_entitlments_tree.txt yang/trees/ietf-entitlement-inventory.tree

# Custom target for unpaginated text output
%.unpaginated.txt: %.xml
	xml2rfc --text --no-pagination -o $@ $<

unpaginated: $(drafts:=.unpaginated.txt)


ifneq (,$(filter clean clean-all,$(MAKECMDGOALS)))
# no tree generation rules during clean
else
# Generate YANG trees from the module (ensures docs match implementation)
$(TREE_FILES): yang/ietf-entitlement-inventory.yang generate-trees.sh
	./generate-trees.sh

trees: $(TREE_FILES)

# Make the draft depend on tree files
draft-ietf-ivy-entitlement-inventory.md: $(TREE_FILES)
endif


# Validate examples against YANG schema
validate: yang/ietf-entitlement-inventory.yang
	./validate-all.sh
	./validate-examples.sh

# Full validation: regenerate trees and validate examples
yang-check: trees validate
	@echo "All YANG checks passed."

$(LIBDIR)/main.mk:
ifneq (,$(shell grep "path *= *$(LIBDIR)" .gitmodules 2>/dev/null))
	git submodule sync
	git submodule update --init
else
ifneq (,$(wildcard $(ID_TEMPLATE_HOME)))
	ln -s "$(ID_TEMPLATE_HOME)" $(LIBDIR)
else
	git clone -q --depth 10 -b main \
	    https://github.com/martinthomson/i-d-template $(LIBDIR)
endif
endif
