
# luci-app-supervisord�����̹�������

һ������Luci�ļ򵥵���������������� [supervisord](https://github.com/ochinchina/supervisord)

### ����
- ����һ����̹��������������pm2
- ������Ҫ�ǲ��ֲ���ǵ�����Ŀ�ĳ�Ʒ���������ٵ���ʵ�Լ����ظ���Ҳ������
- nodejs��python�ĳ���Ҳ�������������У�ǰ������̼��Ѿ��б����nodejs��python
- ���û�����������ļ�����һ��ʹ����Ҫֱ�ӵ㰴ť���¡��������ʧ�ܣ�����ȥ��Ŀ���ض������ļ���
- �����ļ�˵��:

```ini
;��Ҫ�����ļ�������·��������ļ���||�ָ����
;backupfile=/usr/bin/xxxxx||/etc/yyyyy
backupfile=

;��ȡ�汾���������
;getversions=xxxxx version
getversions=
```
### Ч��չʾ
![supervisord-1][1]
![supervisord-2][2]

  [1]: https://raw.githubusercontent.com/sundaqiang/openwrt-packages/master/img/supervisord-1.png
  [2]: https://raw.githubusercontent.com/sundaqiang/openwrt-packages/master/img/supervisord-2.png