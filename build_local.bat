@echo off
setlocal
echo ========================================================
echo        WSL uzerinden Spacewar UEFI Derleyicisi
echo ========================================================
echo.
echo Lutfen bekleyin, Ubuntu baslatiliyor...

:: WSL içindeki dosyanın \r\n karakterlerinden bozulmaması için dos2unix'i Windows'tan çağırıp
:: ardindan bash ile scriptimizi calistiriyoruz.
wsl -e bash -c "sudo apt-get update >/dev/null 2>&1; sudo apt-get install -y dos2unix >/dev/null 2>&1; dos2unix build_local_wsl.sh; chmod +x build_local_wsl.sh; ./build_local_wsl.sh"

echo.
echo Islem tamamlandiysa masaustunuzdeki "woa-spacewar" klasorunde img dosyanizi bulabilirsiniz!
pause
