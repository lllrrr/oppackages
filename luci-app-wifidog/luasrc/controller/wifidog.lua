module("luci.controller.wifidog", package.seeall)

function index()
    if not nixio.fs.access("/usr/bin/wifidog") then
        return
    end

    entry({"admin", "services", "wifidog"}, cbi("wifidog/wifidog_cfg"), _("WifiDog"))
end
