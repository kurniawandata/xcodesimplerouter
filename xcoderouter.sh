#!/bin/bash
#Progammer : Kurniawan. trainingxcode@gmail.com. xcode.or.id.
again='y'
while [[ $again == 'Y' ]] || [[ $again == 'y' ]];
do
clear
echo "=====================================================================";
echo " X-code Simple Router for Ubuntu Server 20.04                        ";
echo " Progammer : Kurniawan. xcode.or.id                                  ";
echo " Version 1.0 (24/04/2020)                                            ";
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=";
echo " Router & Server pendukung router                                    ";
echo " [1]  Install X-code Pandawa (Untuk ganti nama ke eth0 dan eth1)     ";
echo " [2]  Setting IP Address untuk eth0 dan eth1                         ";
echo " [3]  Install NAT, DHCP Server & Bandwidth monitoring                ";
echo " [4]  Setting DHCP Server                                            ";
echo " [5]  Bandwidth Monitoring                                           ";
echo " [6]  Port Forwarding                                                ";
echo " [7]  Install VPN Server PPTP                                        ";
echo " [8]  Setting ip client VPN Server                                   ";
echo " [9]  Setting Password VPN Server                                    ";
echo " [10] Setting ms-dns pada VPN Server                                 ";
echo " =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-";
echo " Lihat user DHCP Server dan lainnya                                  ";
echo " [11] Lihat user yang mendapatkan akses dari DHCP Server             ";
echo " [12] Reset rc.local hanya untuk NAT dari client ke internet         ";
echo " [13] Edit rc.local                                                  ";
echo " [14] Reboot                                                         ";
echo " [15] Exit                                                           ";
echo "=====================================================================";
read -p " Masukkan Nomor Pilihan Anda [1 - 15] : " choice;
echo "";
case $choice in
1)  if [ -z "$(sudo ls -A /etc/default/grub)" ]; then
    echo "Tidak terdeteksi grub, anda yakin pakai Ubuntu 20.04 ?"
    else
    sudo apt-get install ifupdown
    sudo apt-get install net-tools
    sudo cp support/grub /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    sudo cp support/resolved.conf /etc/systemd/
    sudo systemctl restart systemd-resolved
    sudo cp support/interfaces /etc/network/
    sudo cp support/rc.local /etc/
    sudo chmod 777 rc.local
    sudo sysmctl enable rc-local.service
    sudo apt-get update
    sudo apt-get install arp-scan
    sudo nano /etc/network/interfaces
    read -p "Tekan enter untuk restart"
    reboot
    fi
    ;;

2)  if [ -z "$(ls -l /etc/network/interfaces)" ]; then
    echo "Tidak terdeteksi ada /etc/network/interfaces"
    else
    sudo nano /etc/network/interfaces
    read -p "Apakah anda mau restart koneksi eth0 & eth1 sekarang? y/n :" -n 1 -r
    echo 
        if [[ ! $REPLY =~ ^[Nn]$ ]]
        then
        ip addr flush eth0 && sudo systemctl restart networking.service
        ip addr flush eth1 && sudo systemctl restart networking.service
        sudo ifconfig
        fi
    fi
    ;;

3)  read -p "Apakah anda mau yakin mau install NAT, DHCP Server, dan iptraf ? y/n :" -n 1 -r
    echo  ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    sudo sysctl -w net.ipv4.ip_forward=1
    sudo /sbin/iptables -P FORWARD ACCEPT
    sudo /sbin/iptables --table nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo cp support/rc.local /etc/
    sudo chmod 777 rc.local
    sudo sysmctl enable rc-local.service
    echo "NAT sudah diinstall"
    sudo apt-get install isc-dhcp-server
    sudo mv /etc/dhcp/dhcp.conf /tmp
    sudo cp support/dhcpd.conf /etc/dhcp
    sudo nano /etc/dhcp/dhcpd.conf
    sudo service isc-dhcp-server restart
    echo "DHCP Server sudah diinstall"
    sudo apt-get install iptraf
    echo "iptraff sudah diinstall"
    fi
    ;;

4)  if [ -z "$(ls -A /etc/dhcp/dhcpd.conf)" ]; then
    echo "Tidak terdeteksi DHCP Server"
    else
    echo "Setting DHCP Server"
    sudo nano /etc/dhcp/dhcpd.conf
    service isc-dhcp-server restart
    fi
    ;;   

5) sudo iptraf-ng
    ;;

6) echo "Isi file rc.local :"
   sudo cat /etc/rc.local
   echo -n "Masukkan ip WAN pada router : "
   read ipwan
   echo "Daftar ip LAN yang dapat dituju :"
   sudo arp-scan --interface=eth1 --localnet
   echo -n "Masukkan ip LAN pada server yang dituju : "
   read iplan
   echo -n "Masukkan nomor port yang akan diforward : "
   read portip
   sudo sysctl -w net.ipv4.ip_forward=1
   sudo iptables -t nat -A PREROUTING -j DNAT -d $ipwan -p tcp --dport $portip --to $iplan
   sudo sed -i "/exit 0/i\sudo iptables -t nat -A PREROUTING -j DNAT -d "$ipwan" -p tcp --dport "$portip" --to "$iplan"" /etc/rc.local
   ;;

7) read -p "Apakah anda yakin install VPN Server PPTP  ? y/n :" -n 1 -r
    echo  ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "Install PPTP Server" 
    sudo apt-get install pptpd
    sudo cp support/etc/pptpd.conf /etc
    sudo cp support/chap-secrets /etc/ppp
    sudo cp support/ppptpd-options /etc/ppp
    sudo nano /etc/pptpd.conf
    sudo nano /etc/ppp/chap-secrets
    sudo nano /etc/ppp/pptpd-options
    sudo service pptpd restart
    else
    echo "Sudah ada PPTP Server"
    fi
    fi
    ;;

8) if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "Tidak terdeteksi file pptpd.conf pada VPN Server"
    else
    echo "Edit pptpd.conf" 
    sudo nano /etc/pptpd.conf
    sudo service pptpd restart
    fi
    ;;

9) if [ -z "$(ls -l /etc/ppp/chap-secrets)" ]; then
    echo "Tidak terdeteksi file chap-secrets pada VPN Server"
    else
    echo "Edit file chap-secrets" 
    sudo nano /etc/ppp/chap-secrets
    sudo service pptpd restart
    fi
    ;;

10) if [ -z "$(ls -l /etc/pptpd.conf)" ]; then
    echo "Tidak terdeteksi file pptpd-options pada VPN Server"
    else
    echo "Edit file pptpd-options" 
    sudo nano /etc/ppp/pptpd-options
    sudo service pptpd restart
    fi
    ;;

11) if [ -z "$(ls -l /var/lib/dhcp/dhcpd.leases)" ]; then
    echo "Tidak terdeteksi DHCP Server"
    else
    sudo perl support/dhcplist.pl
    fi
    ;;

12) sudo cp support/rc.local /etc/
    sudo chmod 777 rc.local
    sudo sysmctl enable rc-local.service
    ;; 

13) sudo nano /etc/rc.local
    ;;

14) read -p "Apakah anda yakin akan restart? y/n :" -n 1 -r
    echo 
    if [[ ! $REPLY =~ ^[Nn]$ ]]
    then
    reboot
    fi
    ;;

15) exit
    ;;
*)    echo "Maaf, menu tidak ada"
esac
echo ""
echo "X-code Simple Router for Ubuntu Server 20.04"
echo "Oleh Kurniawan - trainingxcode@gmail.com. xcode.or.id"
echo ""
echo -n "Kembali ke menu? [y/n]: ";
read again;
while [[ $again != 'Y' ]] && [[ $again != 'y' ]] && [[ $again != 'N' ]] && [[ $again != 'n' ]];
do
echo "Masukkan yang anda pilih tidak ada di menu";
echo -n "Kembali ke menu? [y/n]: ";
read again;
done
done
