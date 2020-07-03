# oem_script
windows oem scripts


Find Windows version, build, edition from ISO file

Open an elevated Command Prompt window, and then type the following command:
dism /Get-WimInfo /WimFile:F:\sources\install.wim /index:1
In the ISO file, if you have install.esd instead of install.wim, you’d type:

dism /Get-WimInfo /WimFile:F:\sources\install.esd /index:1
