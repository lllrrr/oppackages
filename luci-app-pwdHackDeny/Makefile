include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-pwdHackDeny
PKG_VERSION:=v6.0.5
PKG_RELEASE:=20210314

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  DEPENDS:=+gawk +ipset +iptables +ip6tables +iptables-mod-iprange +diffutils
  TITLE:=LuCI support for password hack deny by wulishui
  PKGARCH:=all
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
rm -f /tmp/luci-*
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/pwdHackDeny
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/* $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_BIN) ./root/etc/pwdHackDeny.sh $(1)/etc/pwdHackDeny.sh
	
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/* $(1)/etc/uci-defaults/
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./root/etc/config/* $(1)/etc/config/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
