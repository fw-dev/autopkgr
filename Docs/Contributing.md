## Contributing

### 1. Code Signing
We code sign AutoPkgr with the Linde Group mac developer account during release, but when building in debug mode we have the project configured to use a generic self signed certificate to handle the code signing. 

Right now this is not strictly necessary but once we move closer to the 1.2 release, and begin using a Privileged Helper Tool, both the app and helper tool need to be signed with the same certificate in order for the ```SMJobBless()``` function to work.

In order to contribute you will need to install the
```
AuotPkgr-OpenSource-Dev-Certificate.p12
```
at the root of this project. It should be no more complicated than double clicking on the cert file, just
leave the password field blank when prompted.  You will need to quit and relaunch Xcode for it to recognize the newly installed certificate.

*_if working on the 1.2 or greater branch make sure you "uninstall" the helper tool when done working so it doesn't conflict with the official releases.  If you see an error about code sign certificates don't match this is what it's in reference to._

### 2. Pods
We use cocoa pods which makes it real easy to get up and running. just cd into your autopkgr repo's directory and 
```
pod install
```
Then open the ```AutoPkgr.xcworkspace``` file


When switching between branches you may need to update your pod installation by running
```
pod update
```

When ever you do this, you may also need to clean the project's build folder using
```
shift-command-K
```
inside of Xcode.

### 3. Scheme
For some reason I noticed when freshly cloned the build scheme is set to build the ```Mailcore2 ios``` framework.  This needs to be changed to ```AutoPkrg``` , it may go without saying, but also may save a few headaches.
