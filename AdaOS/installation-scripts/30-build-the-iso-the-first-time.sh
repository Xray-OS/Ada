#!/bin/bash
#set -e

################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
echo
echo "################################################################## "
tput setaf 2
echo "Phase 1 : "
echo "- Setting General parameters"
tput sgr0
echo "################################################################## "
echo

	#Let us set the desktop"
	#First letter of desktop is small letter

	desktop="plasma"
	dmDesktop="plasma"

	Ada_Version='v12'

	isoLabel='Ada-'$Ada_Version'-x86_64.iso'

	# setting of the general parameters
	archisoRequiredVersion="archiso 79-1"
	buildFolder=$HOME"/Ada-Build"
	outFolder=$HOME"/Ada-Out"
	archisoVersion=$(sudo pacman -Q archiso)

	# If you want to add packages from the chaotics-aur repo then
	# change the variable to true and add the package names
	# that are hosted on chaotics-aur in the packages.x86_64 at the bottom

	chaoticsrepo=false

	# If you are ready to use your personal repo and personal packages
	# https://arcolinux.com/use-our-knowledge-and-create-your-own-icon-theme-combo-use-github-to-saveguard-your-work/
	# 1. set variable personalrepo to true in this file (default:false)
	# 2. change the file personal-repo to reflect your repo
	# 3. add your applications to the file packages-personal-repo.x86_64

	personalrepo=false

	echo "################################################################## "
	echo "Building the desktop                   : "$desktop
	echo "Building version                       : "$Ada_Version
	echo "Iso label                              : "$isoLabel
	echo "Do you have the right archiso version? : "$archisoVersion
	echo "What is the required archiso version?  : "$archisoRequiredVersion
	echo "Build folder                           : "$buildFolder
	echo "Out folder                             : "$outFolder
	echo "################################################################## "

	if [ "$archisoVersion" == "$archisoRequiredVersion" ]; then
		tput setaf 2
		echo "##################################################################"
		echo "Archiso has the correct version. Continuing ..."
		echo "##################################################################"
		tput sgr0
	else
	tput setaf 1
	echo "###################################################################################################"
	echo "You need to install the correct version of Archiso"
	echo "Use 'sudo downgrade archiso' to do that"
	echo "or update your system"
	echo "###################################################################################################"
	tput sgr0
	fi

echo
echo "################################################################## "
tput setaf 2
echo "Phase 2 :"
echo "- Checking if archiso is installed"
echo "- Saving current archiso version to readme"
echo "- Making mkarchiso verbose"
tput sgr0
echo "################################################################## "
echo

	package="archiso"

	#----------------------------------------------------------------------------------

	#checking if application is already installed or else install with aur helpers
	if pacman -Qi $package &> /dev/null; then

			echo "Archiso is already installed"

	else

		#checking which helper is installed
		if pacman -Qi yay &> /dev/null; then

			echo "################################################################"
			echo "######### Installing with yay"
			echo "################################################################"
			yay -S --noconfirm $package

		elif pacman -Qi trizen &> /dev/null; then

			echo "################################################################"
			echo "######### Installing with trizen"
			echo "################################################################"
			trizen -S --noconfirm --needed --noedit $package

		fi

		# Just checking if installation was successful
		if pacman -Qi $package &> /dev/null; then

			echo "################################################################"
			echo "#########  "$package" has been installed"
			echo "################################################################"

		else

			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			echo "!!!!!!!!!  "$package" has NOT been installed"
			echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			exit 1
		fi

	fi

	echo
	echo "Saving current archiso version to readme"
	sudo sed -i "s/\(^archiso-version=\).*/\1$archisoVersion/" ../archiso.readme
	echo
	echo "Making mkarchiso verbose"
	sudo sed -i 's/quiet="y"/quiet="n"/g' /usr/bin/mkarchiso

echo
echo "################################################################## "
tput setaf 2
echo "Phase 3 :"
echo "- Deleting the build folder if one exists"
echo "- Copying the Archiso folder to build folder"
tput sgr0
echo "################################################################## "
echo

	echo "Deleting the build folder if one exists - takes some time"
	[ -d $buildFolder ] && sudo rm -rf $buildFolder
	echo
	echo "Copying the Archiso folder to build work"
	echo
	mkdir $buildFolder
	cp -r ../archiso $buildFolder/archiso

echo
echo "################################################################## "
tput setaf 2
echo "Phase 4 :"
echo "- Deleting any files in /etc/skel"
echo "- Getting the last version of bashrc in /etc/skel"
echo "- Removing the old packages.x86_64 file from build folder"
echo "- Copying the new packages.x86_64 file to the build folder"
echo "- Add our own personal repo + add your packages to packages-personal-repo.x86_64"
tput sgr0
echo "################################################################## "
echo

#	echo "Deleting any files in /etc/skel"
#	rm -rf $buildFolder/archiso/airootfs/etc/skel/.* 2> /dev/null
#	echo

#	echo "Getting the last version of bashrc in /etc/skel"
#	echo
#	wget https://raw.githubusercontent.com/arcolinux/arcolinux-root/master/etc/skel/.bashrc-latest -O $buildFolder/archiso/airootfs/etc/skel/.bashrc

	echo "Removing the old packages.x86_64 file from build folder"
	rm $buildFolder/archiso/packages.x86_64
	rm $buildFolder/archiso/packages-personal-repo.x86_64
	echo

	echo "Copying the new packages.x86_64 file to the build folder"
	cp -f ../archiso/packages.x86_64 $buildFolder/archiso/packages.x86_64
	echo

	if [ $personalrepo == true ]; then
		echo "Adding packages from your personal repository - packages-personal-repo.x86_64"
		printf "\n" | sudo tee -a $buildFolder/archiso/packages.x86_64
		cat ../archiso/packages-personal-repo.x86_64 | sudo tee -a $buildFolder/archiso/packages.x86_64
	fi

	if [ $personalrepo == true ]; then
		echo "Adding our own repo to /etc/pacman.conf"
		printf "\n" | sudo tee -a $buildFolder/archiso/pacman.conf
		printf "\n" | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
		cat personal-repo | sudo tee -a $buildFolder/archiso/pacman.conf
		cat personal-repo | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
	fi

	if [ $chaoticsrepo == true ]; then
		echo "Adding our chaotics repo to /etc/pacman.conf"
		printf "\n" | sudo tee -a $buildFolder/archiso/pacman.conf
		printf "\n" | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
		cat chaotics-repo | sudo tee -a $buildFolder/archiso/pacman.conf
		cat chaotics-repo | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
	fi

	if [ $chaoticsrepo == false ]; then
		echo "Adding our chaotics repo to /etc/pacman.conf"
		printf "\n" | sudo tee -a $buildFolder/archiso/pacman.conf
		printf "\n" | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
		cat no-chaotics-repo | sudo tee -a $buildFolder/archiso/pacman.conf
		cat no-chaotics-repo | sudo tee -a $buildFolder/archiso/airootfs/etc/pacman.conf
	fi

	echo
	echo "Adding the content of the /personal folder"
	echo
	cp -rf ../personal/ $buildFolder/archiso/airootfs/

	if test -f $buildFolder/archiso/airootfs/personal/.gitkeep ; then
		echo
		rm $buildFolder/archiso/airootfs/personal/.gitkeep
		echo ".gitkeep is now removed"
		echo
    fi

echo
echo "################################################################## "
tput setaf 2
echo "Phase 5 : "
echo "- Changing all references"
echo "- Adding time to /etc/dev-rel"
tput sgr0
echo "################################################################## "
echo

	#Setting variables

	#profiledef.sh
	oldname1='iso_name="ada'
	newname1='iso_name="ada'

	oldname2='iso_label="ada'
	newname2='iso_label="ada'

	oldname3='ada'
	newname3='ada'

	#hostname
	oldname4='ada'
	newname4='ada'

	#sddm.conf user-session
	oldname5='Session=plasma'
	newname5='Session='$dmDesktop

	echo "Changing all references"
	echo
	sed -i 's/'$oldname1'/'$newname1'/g' $buildFolder/archiso/profiledef.sh
	sed -i 's/'$oldname2'/'$newname2'/g' $buildFolder/archiso/profiledef.sh
	sed -i 's/'$oldname3'/'$newname3'/g' $buildFolder/archiso/airootfs/etc/dev-rel
	sed -i 's/'$oldname4'/'$newname4'/g' $buildFolder/archiso/airootfs/etc/hostname
	sed -i 's/'$oldname5'/'$newname5'/g' $buildFolder/archiso/airootfs/etc/sddm.conf.d/kde_settings.conf

	echo "Adding time to /etc/dev-rel"
	date_build=$(date -d now)
	echo "Iso build on : "$date_build
	sudo sed -i "s/\(^ISO_BUILD=\).*/\1$date_build/" $buildFolder/archiso/airootfs/etc/dev-rel


echo
echo "###########################################################"
tput setaf 2
echo "Phase 6 :"
echo "- Cleaning the cache from /var/cache/pacman/pkg/"
tput sgr0
echo "###########################################################"
echo

	echo "Cleaning the cache from /var/cache/pacman/pkg/"
	yes | sudo pacman -Scc

echo
echo "################################################################## "
tput setaf 2
echo "Phase 7 :"
echo "- Building the iso - this can take a while - be patient"
tput sgr0
echo "################################################################## "
echo

	[ -d $outFolder ] || mkdir $outFolder
	cd $buildFolder/archiso/
	sudo mkarchiso -v -w $buildFolder -o $outFolder $buildFolder/archiso/



echo
echo "###################################################################"
tput setaf 2
echo "Phase 8 :"
echo "- Creating checksums"
echo "- Copying pgklist"
tput sgr0
echo "###################################################################"
echo

	cd $outFolder

	echo "Creating checksums for : "$isoLabel
	echo "##################################################################"
	echo
	echo "Building sha1sum"
	echo "########################"
	sha1sum $isoLabel | tee $isoLabel.sha1
	echo "Building sha256sum"
	echo "########################"
	sha256sum $isoLabel | tee $isoLabel.sha256
	echo "Building md5sum"
	echo "########################"
	md5sum $isoLabel | tee $isoLabel.md5
	echo
	echo "Moving pkglist.x86_64.txt"
	echo "########################"
	cp $buildFolder/iso/arch/pkglist.x86_64.txt  $outFolder/$isoLabel".pkglist.txt"

echo
echo "##################################################################"
tput setaf 2
echo "Phase 9 :"
echo "- Making sure we start with a clean slate next time"
tput sgr0
echo "################################################################## "
echo

	echo "Deleting the build folder if one exists - takes some time"
	[ -d $buildFolder ] && sudo rm -rf $buildFolder

echo
echo "##################################################################"
tput setaf 2
echo "DONE"
echo "- Check your out folder :"$outFolder
tput sgr0
echo "################################################################## "
echo
