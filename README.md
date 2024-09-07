<!-- PROJECT LOGO -->
<br />
<div align="center">
        <h1>wan6mon</h1>
    <p align="center">
        <b>一段檢查 IPv6 Prefix Delegation (IPv6-PD) 是否存在嘅 Shell 代碼</b>
    </p>
</div>

雖然 Netvigator 係2024年香港唯一一間提供 IPv6 俾家用網絡嘅 ISP ，但佢派嘅 IPv6-PD 係會隨時間流逝而直接消失嘅。呢段 Shell 代碼嘅目的係檢查`wan6`接口，當 `ipv6-prefix` 係一個列表（曾經有攞到過 IPv6-PD），但入面冇`address`嘅時候，會自動重啓`odhcpd`同`wan6`接口，強制更新 IPv6-PD。

<ol>
    <li><a href="#依賴軟件包">依賴軟件包</a></li>
    <li><a href="#如何使用">如何使用</a></li>
    <li><a href="#問題報告、建議、疑問之類">問題報告、建議、疑問之類</a>
</ol>

## 依賴軟件包

以防萬一，請檢查是否已安裝`libubox`軟件包。
```shell
opkg install libubox
```

## 如何使用

### 下載 Shell 代碼

```shell
cd /opt
```

如果有裝`git-http`，可以用`git clone`下載代碼。

```shell
git clone https://github.com/callieniera/wan6mon.git
```

冇嘅話，可以用`vim` / `nano`或任何方法將`wan6mon.sh`複製去資料夾內。

```shell
mkdir wan6mon
nano wan6mon.sh
```

### 運行 Shell 代碼

當 IPv6-PD 消失嘅時候會自動觸發防火牆重新載入，因此可以喺`hotplug.d`入面加入自動檢查代碼：

```shell
cp /etc/hotplug.d/iface/20-firewall /etc/hotplug.d/iface/20-firewall.backup
echo "if [ \"\$ACTION\" = \"ifupdate\" ]; then
        sleep 3
        logger -t firewall \"Executing additional ipv6-pd check after firewall reloaded\"
        /bin/sh /opt/wan6mon/wan6mon.sh 
fi" >> /etc/hotplug.d/iface/20-firewall
```

又或者自己手動修改`/etc/hotplug.d/iface/20-firewall`，喺最後一行之後加入以下內容：

```shell
if [ "$ACTION" = "ifupdate" ]; then
        sleep 3
        logger -t firewall "Executing additional ipv6-pd check after firewall reloaded"
        /bin/sh /opt/wan6mon/wan6mon.sh
fi
```

如果搵唔到`/etc/hotplug.d/iface/20-firewall`，就可能要用 cron 定期運行代碼：

```cron
*/15 * * * * /bin/sh /opt/wan6mon/wan6mon.sh
```

## 問題報告、建議、疑問之類
可透過 [Telegram](https://t.me/callieniera) 聯絡我。

<div align="center">
    <div align="center">
        <h1>2024年香港 ISP 嘅 IPv6 普及情況</h1>
    </div>
</div>

### 家用 Netvigator

**/56 prefix**

### 其他家用寬頻

未有支援

### 商用 Netvigator、商用 HGC、商用 HKBN

**需要申請至少有8個固定 IPv4 嘅服務先會有 IPv6 服務**