# Software principles, pattern and practices:
The project relies on CLEAN architeture
https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html

The design pattern is being used is MVVM and I refered to the iOS template here: https://github.com/kudoleh/iOS-Clean-Architecture-MVVM
also mixed with some structures I experienced in other past projects.

# Brief description:
The idea of structure folder is based on Features. Each feature will have a separated folder/group. Each feature folder contains groups for ViewModel, View and Interactor which are consumed by the feature. If an interactor is used across among features, we should consider to make it as a service and reside under Infrastructure/services

For Domain folder, there are 2 sub-folders: Entities and Models. Entities folder contains business objects, used for parsing raw data objects from remote server. Models folder contains app-level objects which are supplied to the higher levels.

API and Repositories folder under Data folder are in turn used for API requests and Caching.

The project uses below frameworks:
1. Alamofire for networking task
2. RxSwift for Reactive Programming
3. SwiftyJSON for JSON parsing
4. Kingfisher for image downloading

# Steps to run application:
1. Get the source from repo
2. Navigate to the source code folder containing Podfile
3. Run this terminal command under the current folder: pod install
4. Open the file .xcworkspace and run the application
5. Optional: For Apple Silicon Macs, there is an additional step to get the project built successfully. After running 'pod install', set excluded architectures to "arm64" on the project, target and pod project.

# Done items:
1. Programming language
2. Design app's architecture
3. UI should be looks like in attachment.
4. Write UnitTests
5. Exception handling
6. Caching handling

# Additional note:
The project was derived from an existing assignment project I worked on earlier, so in git history, we may notice some unnecessary files have been removed from the project.
