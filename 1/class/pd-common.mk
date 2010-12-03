# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2010 IOhannes m zmölnig <zmoelnig@iem.at>

#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.

ifndef _cdbs_bootstrap
_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class
endif

ifndef _cdbs_class_pd_common
_cdbs_class_pd_common := 1
CDBS_BUILD_DEPENDS_class_pd_common ?= pd-pkg-tools
CDBS_BUILD_DEPENDS += , $(CDBS_BUILD_DEPENDS_class_pd_common)


include $(_cdbs_class_path)/langcore.mk$(_cdbs_makefile_suffix)
include $(_cdbs_rules_path)/buildcore.mk$(_cdbs_makefile_suffix)

nostrip_package = 
ifneq (,$(filter nostrip,$(DEB_BUILD_OPTIONS)))
 nostrip_package = yes
endif
ifeq (,$(is_debug_package))
 nostrip_package = yes
endif

#be sure to include $(_cdbs_rules_path)/rules/debhelper.mk before
ifdef _cdbs_rules_debhelper

## put debhelper specific code in here

# endif _cdbs_rules_debhelper
endif


## code not specific to other backends

# pd externals have the uncommon extension .pd_linux, which prevents them from
# being properly detected by dh_shlibdeps, so we do it manually
$(patsubst %,binary-predeb-IMPL/%,$(DEB_ALL_PACKAGES)) ::
	dpkg-shlibdeps $(shell find $(cdbs_curdestdir) -name "*.pd_linux") -Tdebian/$(cdbs_curpkg).substvars

# pd externals have the uncommon extension .pd_linux, which prevents them from
# being properly detected by dh_strip, so we do it manually
$(patsubst %,binary-strip-IMPL/%,$(DEB_ALL_PACKAGES)) :: 
	$(if $(nostrip_package),,strip --remove-section=.comment --remove-section=.note --strip-unneeded $(shell find $(cdbs_curdestdir) -name "*.pd_linux") )

$(patsubst %,install/%,$(DEB_ALL_PACKAGES)) :: install/%:
	@echo 'Adding pd dependencies to debian/$(cdbs_curpkg).substvars'
	@echo '$(call cdbs_expand_curvar,PD_DEPENDS,$(comma) )'    | -ne '$(cdbs_re_squash_extended_space); $(re_squash_commas_and_spaces); /\w/ and print "pd:Depends=$$_\n"'     >> debian/$(cdbs_curpkg).substvars


#endif _cdbs_class_pd_common
endif
