# Deployment

- Increment CFBundleVersion in Info.plist
- Archive the build
- Zip it
- Put the zip in ./builds
- Set up the appcast `/Users/dirk/Library/Developer/Xcode/DerivedData/Journalist_Mode-hbpadbepukebbzbilprfncfbjlhh/SourcePackages/artifacts/Sparkle/bin/generate_appcast ~/Dev/journalist-mode/builds`
- Update link on webpage
- Send to s3 & invalidate cache
```
aws s3 cp --recursive website/public s3://journalistmode.com/ --acl public-read \
&& aws s3 cp --recursive builds s3://journalistmode.com/ --acl public-read \
&& aws cloudfront create-invalidation --distribution-id ${DISTRO_ID} --paths "/*"
```
    

# Later

- Fully cli build/deploy:
    - `xcodebuild archive`
    - `xcodebuild -exportArchive`
    - `xcrun notarytool submit ...`
