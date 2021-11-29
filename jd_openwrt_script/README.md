# jd_openwrt_script
适用于openwrt安装jd脚本的插件,本插件不带luci界面！！！ 不带luci界面！！！ 不带luci界面！！！

此插件帮助装好依赖和下载 https://github.com/ITdesk01/JD_Script/tree/main 这里的脚本

准确来说这是一个帮忙安装脚本的插件，依赖和脚本安装好，他的任务结束了 

## 编译
cd 到你的源码

        git clone  https://github.com/ITdesk01/jd_openwrt_script.git package/jd_openwrt_script
        ./scripts/feeds update && ./scripts/feeds install
        make menuconfig
        
选上插件

        Extra packages  --->
             <*> jd_openwrt_script
             
        
开始编译

        make V=99


## 使用
1.编译完成以后刷机，连上网开机的等5分钟至少，然后插件自动安装脚本与依赖,是否完成可以查看系统日志
      
2.安装完成以后，查看一下使用说明
        
        sh $jd 
      
3.扫码获取cooike
        
        node /usr/share/jd_openwrt_script/JD_Script/js/getJDCookie.js
        获取到的cookie填到 /usr/share/jd_openwrt_script/script_config/jdCookie.js
     
4.运行全部脚本

        sh $jd run_0 run_07


**如果安装失败可以用以下命令控制插件重新安装**
      
        /etc/init.d/jd_openwrt_script stop
        /etc/init.d/jd_openwrt_script start
      
**彻底关闭插件**
        
        /etc/init.d/jd_openwrt_script stop
        /etc/init.d/jd_openwrt_script disable
      

不会编译的可以采用我的编译辅助脚本编译： https://github.com/openwrtcompileshell/OpenwrtCompileScript （编译出来就是带插件的）
