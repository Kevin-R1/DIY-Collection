#  双AdGuardHome一键安装脚本及docker AdGuardHome一键安装版  by [Namia-X]

### **基于你已经安装了docker版agd可以使用模板进行复制和上传，或者docker版自己配置**

- 1 文件夹找到 /mnt/mmcblk2p4/adg/confdir1，上传AdGuardHome.yaml到confdir1此为docker版本配置yaml文件上传路径，博主本人只是把它当作了第二分dns用作拦截国内外广告你可以自己找喜欢的dns去改变，如有失效的请提交出来我，我去补充。
- 2 你已经下载了agd并且在服务里面找到了agd你可以直接复制AdGuardHome-cn.yaml此文件里面的，在adg模板手动复制粘贴就行。
- 3 搭配mosdns或者smtdns运行，插件包的agd不作为dns服务器选择无，如果你用我模版记得看对应端口转发和访问端口转发如果不喜欢自行改。
- 4不需要删掉固件自带的agd，你不嫌麻烦可以全docker板agd。

### **其他固件如X86和RK瑞芯微处理器下的op如要使用此脚本，还需要手动创建两个文件夹路径，然后继续运行脚本**
---
     mkdir -p /mnt/mmcblk2p4/adg
---

这个命令适合N1下的openwrt直接创建
---
    wget https://raw.githubusercontent.com/Kevin-R1/Two-docker-agd/main/adg.sh && sh adg.sh  
---
操作顺序
---

3111100311

---
### **[`悟空的日常`]( https://github.com/wukongdaily) 所撰写的iStore商店和设置向导 by [wukongdaily]**

### **安装iStore商店(ARM64 & x86-64通用)**
---
     wget -qO imm.sh https://cafe.cpolar.top/wkdaily/zero3/raw/branch/main/zero3/imm.sh && chmod +x imm.sh && ./imm.sh
     
---
### **安装网络向导和首页(ARM64 & x86-64通用)**

---
     is-opkg install luci-i18n-quickstart-zh-cn
     
---
```
curl -fsSL https://raw.githubusercontent.com/eooce/ssh_tool/main/ssh_tool.sh -o ssh_tool.sh && chmod +x ssh_tool.sh && ./ssh_tool.sh
```
以下是博主提供的DNS服务器列表，按**国内**和**国外**分类。
---

1. ### **国内DNS服务器**

1.1 腾讯 DNS
腾讯 DNS 基于 BGP Anycast 技术，不论用户身在何地，都可就近访问服务。支持谷歌 ECS 协议，配合 DNSPod 权威解析，可以给用户提供出最准确的解析结果，承诺不劫持解析结果。

     IPv4：119.29.29.29
     DoH：https://doh.pub/dns-query
     DoH：https://1.12.12.12/dns-query
     DoH：https://120.53.53.53/dns-query
     DoH：https://sm2.doh.pub/dns-query (国密)
     DoT：dot.pub
     DoT：1.12.12.12
     DoT：120.53.53.53
     
1.2 阿里 DNS
阿里 DNS 线路支持包括电信、移动、联通、鹏博士、广电网、教育网及海外 150 个国家或地域，支持用户 ECS 扩展技术，智能解析；支持 DoT/DoH 协议，保护用户隐私，安全防劫持。

     IPv4：223.5.5.5
     IPv4：223.6.6.6
     DoH：https://223.5.5.5/dns-query
     DoH：https://223.6.6.6/dns-query
     DoH：https://dns.alidns.com/dns-query
     DoT：dns.alidns.com
1.3 360DNS

     DoH：https://doh.360.cn/dns-query	
     DoT：dot.360.cn

1.4 台湾Quad 101

     IPv4：101.101.101.101	
     IPv4：101.102.103.104
     DoH：https://dns.twnic.tw/dns-query

2. ### **国外DNS服务器**
   
2.1 Google DNS

     IPv4：8.8.8.8
     IPv4：8.8.4.4
     DoH：https://dns.google/dns-query
     DoT：dns.google
     
2.2 IBM Quad9

Quad9 DNS 服务由总部位于瑞士的 Quad9 基金会运营（IBM是主要赞助商之一），Quad9 系统都不会记录包含您 IP 地址的数据，如果您的系统支持，Connections 可以使用加密，整个 Quad9 平台的设计符合 GDPR。

#推荐：Malware Blocking、DNSSEC Validation（这是最典型的配置）

     IPv4：9.9.9.9
     IPv4：149.112.112.112
     DoH：https://dns.quad9.net/dns-query
     DoT：dns.quad9.net
 
#使用 ECS 保护：恶意软件阻止、DNSSEC 验证、启用 ECS

     IPv4：9.9.9.11
     IPv4：149.112.112.11
     DoH：https://dns11.quad9.net/dns-query
     DoT：dns11.quad9.net
 
#不安全：没有恶意软件阻止，没有 DNSSEC 验证（仅限专家！）

     IPv4：9.9.9.10
     IPv4：149.112.112.10
     DoH：https://dns10.quad9.net/dns-query
     DoT：dns10.quad9.net
     
2.3 👍CleanBrowsing DNS

CleanBrowsing 帮助他们在家中创建自己的家庭友好网络，为孩子创造安全在线体验。永远免费，没有跟踪。

#安全保护：阻止对网络钓鱼、垃圾邮件、恶意软件和恶意域的访问。

     IPv4：185.228.168.9
     IPv4：185.228.169.9
     DoH：https://doh.cleanbrowsing.org/doh/security-filter/
     DoT：dns.cleanbrowsing.org
 
#成人保护：阻止访问所有成人、恶意和网络钓鱼网站。它不会阻止代理、混合内容网站（如 Reddit）

     IPv4：185.228.168.10
     IPv4：185.228.169.11
     DOH：https://doh.cleanbrowsing.org/doh/adult-filter/
     DOT：dns.cleanbrowsing.org
 
#家庭保护:阻止访问所有成人、恶意、网络钓鱼、混合内容网站（如 Reddit）、阻止用于绕过过滤器的代理、Google、Bing 和 Youtube 设置为安全模式。

     IPv4：185.228.168.168
     IPv4：185.228.169.168
     DoH：https://doh.cleanbrowsing.org/doh/family-filter/
     DoT：dns.cleanbrowsing.org
2.4 👍OpenDNS

     IPv4：208.67.222.222
     IPv4：208.67.220.220
     DoH：https://doh.opendns.com/dns-query
     DoH：https://doh.familyshield.opendns.com/dns-query
     
2.5 Cloudflare DNS

     IPv4：1.0.0.1
     IPv4：1.1.1.1
     DoH：https://1.1.1.1/dns-query
     DoH：https://1.0.0.1/dns-query
     DoH：https://cloudflare-dns.com/dns-query
     DoT: one.one.one.one
     DoT: 1dot1dot1dot1.cloudflare-dns.com
     
2.6 AdGuard DNS
AdGuard DNS 是屏蔽互联网广告的安全方法。它不需要您安装任何应用程序。在任何设备上都设置简单、使用便捷、免费，并且为您提供屏蔽广告、计数器、恶意网站和成人内容的功能。

#无过滤，不拦截

     IPv4：94.140.14.140
     IPv4：94.140.15.15
     DoH：https://dns-unfiltered.adguard.com/dns-query
     DoT：dns-unfiltered.adguard.com
     DoQ：dns-unfiltered.adguard.com
 
#过滤广告和跟踪

     IPv4：94.140.14.14
     IPv4：94.140.15.15
     DoH：https://dns.adguard.com/dns-query
     DoT：dns.adguard.com
     DoQ：dns.adguard.com
 
#家庭过滤：开启安全搜索和安全模式选项、拦截成人内容，并且屏蔽广告和跟踪器

     IPv4：94.140.14.15
     IPv4：94.140.15.16
     DoH：https://dns-family.adguard.com/dns-query
     DoT：dns-family.adguard.com
     DoQ：quic://dns-family.adguard.com
2.7 DNS.SB

     IPv4：185.222.222.222
     IPv4：45.11.45.11
     DoH：https://doh.dns.sb/dns-query
     DoH：https://doh.sb/dns-query
     DoT：dot.sb

2.8 日本 IIJ DNS

     DoH：https://public.dns.iij.jp/dns-query


---

### **使用说明**
1. **国内DNS**：适合访问国内网站，速度快，推荐阿里DNS、腾讯DNS、360DNS。
2. **国外DNS**：适合访问国际网站，隐私保护强，推荐Cloudflare DNS、Google DNS。
3. **Windows**：在“网络设置”中配置DoH或DoT。
4. **路由器**：在路由器管理界面中配置DoT。
5. **手机**：在“私人DNS”设置中配置DoT。

---

### **国内广告拦截白名单**必填白名单
白名单1

     https://raw.githubusercontent.com/8680/GOODBYEADS/master/data/rules/allow.txt
白名单2

     https://raw.githubusercontent.com/BlueSkyXN/AdGuardHomeRules/master/ok.txt
### **国内广告拦截规则**

百万ADH广告拦截过滤规则

        https://raw.githubusercontent.com/BlueSkyXN/AdGuardHomeRules/master/all.txt
DNS 拦截

        https://raw.githubusercontent.com/217heidai/adblockfilters/main/rules/adblockdns.txt
目前中文区命中率最高的广告过滤列表，实现了精确的广告屏蔽和隐私保护屏蔽广告域名、电视盒子广告、APP内置广告

        https://cdn.jsdelivr.net/gh/privacy-protection-tools/anti-AD@master/anti-ad-easylist.txt

广告拦截

        https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/light.txt
EasyList-去除国际网页中大多数广告，包括不需要的框架、图像和对象

        https://easylist-downloads.adblockplus.org/easylist.txt
yhosts – 屏蔽国内网站广告-国内维护

        https://raw.githubusercontent.com/vokins/yhosts/master/hosts
屏蔽网站的 cookies 相关的警告

        https://www.i-dont-care-about-cookies.eu/abp/
CJX’s Annoyance List (去自推列表)

        https://cdn.jsdelivr.net/gh/cjx82630/cjxlist@master/cjx-annoyance.txt
知乎过滤器

        https://cdn.jsdelivr.net/gh/zsakvo/AdGuard-Custom-Rule@master/rule/zhihu-strict.txt

### **国外广告拦截规则**
StevenBlack – 屏蔽国外网站广告-国外维护

        https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
AdGuard DNS filter

        https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt
EasyList-去除国际网页中大多数广告，包括不需要的框架、图像和对象

        https://easylist-downloads.adblockplus.org/easylist.txt
屏蔽网站的 cookies 相关的警告

        https://www.i-dont-care-about-cookies.eu/abp/
屏蔽美欧地区英文网站相关的广告

        https://winhelp2002.mvps.org/hosts.txt
