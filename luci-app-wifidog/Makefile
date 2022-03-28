include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI WifiDog
LUCI_DEPENDS:=+wifidog
LUCI_PKGARCH:=all
PKG_NAME:=luci-app-wifidog
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk
#include $(INCLUDE_DIR)/package.mk

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/preinst
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
    ( . /etc/uci-defaults/luci-wifidog ) && rm -f /etc/uci-defaults/luci-wifidog
    rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/
fi

chmod 755 "$${IPKG_INSTROOT}/etc/init.d/wifidog" >/dev/null 2>&1
"$${IPKG_INSTROOT}/etc/init.d/wifidog" enable >/dev/null 2>&1

exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
