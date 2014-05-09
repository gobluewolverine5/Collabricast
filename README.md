Collabricast
===========

Collabricast is an image streaming app that allows you to display photos from your phone to your TV wirelessly using Google's Chromecast. In addition, there are picture annotation and slideshow functionalities. Create slideshows collaboratively with others using multiple iOS devices!

##Compatibility
Collabricast is built to run on iOS 7 and was developed in Xcode 5


##Setting Up

Collabricast uses the external library "Photo-Picker-Plus" made by Chute to access Facebook photos. For more information on "Photo-Picker-Plus" visit https://github.com/chute/photo-picker-plus-ios. To access the Facebook image picking feature you must obtain a Chute private key.


1. In the repository, navigate to: *Collabricast/External Libraries/PhotoPickerPlus/Configuration/GCConfiguration-Sample.plist*
2. Replace *YOUR_CLIENT_ID* and *YOUR_CLIENT_SECRET* with your Chute Client ID and Client Secret key obtained from Chute.
3. Rename *GCConfiguration-Sample.plist* to *GCConfiguration.plist*
4. Build the project and that's it!

##Authors

* Evan Hsu (evanjhsu@umich.edu) - iOS Developer
* Suraj Rajan (surajraj@umich.edu) - UI Designer