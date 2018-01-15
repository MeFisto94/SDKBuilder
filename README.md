# SDKBuilder
A Docker Container to aid building the SDK as done in Travis CI Environment.
Useful if travis is not working or to debug travis issues.  
  
Do note that this container is not intended to get you started with SDK Development,
because for that you would need some setup for remote debugging over tcp, which is a
pointless overhead. The scripts are thus made to build from a fixed SDK tag which you
have to specify (which implicitly contains the engine version to take).  
Furthermore all of the required dependencies are to build/convert the jdks and in
general to build the installers for you.  
  
This means that this is rather for people trying to debug build issues or maybe
building their fork of the SDK, where they would only have to change the git
addresses in `docker-entrypoint.sh`.  
  
Also note that this container requires a minimum SDK version of `v3.2.0-stable-sdk1`,
earlier versions (especially v3.1) won't build without adoptions.

## How To Use
First download the container to your local system.  
It's important to run this step each time you want to build,
because it ensures you are running the latest version of our build tools.

```
sudo docker pull mefisto94/sdkbuilder
```
  
If you want to build the `v3.2.0-stable-sdk1` then, you would execute:

```
sudo docker run --rm -e TRAVIS_TAG=v3.2.0-stable-sdk1 -v $(pwd):/dist -it mefisto94/sdkbuilder
```

### Explanation
- We recommend you to use `--rm`, so the build is not disturbed by builds in previous images.
Since this container is meant for a CI/CD environment, this is also the desired behavior.
If you run the container locally and want to save time and bandwidth, there are also
environment variables to update the sdk/engine, see below.

- You *HAVE* to specify a SDK git tag using `TRAVIS_TAG` (the name is to stay in sync with
the actual travis build). If you would not specify a tag the container would build from
master which however produces unexpected and un-reproduceable results.

- `-v $(pwd):/dist` mounts your current directory into the container. This essentially 
tells the container where to place the releases. You could also use `-v /home/user/sdk/installers/:/dist`

- `-it` might be optional but in case errors appear, it's good to have a look at the container.

## Environment Variables
Environment Variable | Default Value | Typical Value | Description
--- | --- | --- | ---
`TRAVIS` | `SDK_DOCKER` | `SDK_DOCKER` | Used by the scripts to detect the TravisCI Environment. Here we even allow to distinguish the "real" travis from our Container. Don't touch.  
`TRAVIS_TAG` | `-` | `v3.2.0-stable-sdk1` | Used to specify which SDK tag to build. Note that this value here would mean engine: `v3.2.0-stable` and the first sdk release of it.  
`AUTOUPDATE_ENGINE` | `undefined` | `undefined` | Used to signal the scripts to force-update the engine, which might be present in the container. It's discouraged to use it, rather use dockers `--rm` flag. Everything other than `true` will be treated as `false`.  
`AUTOUPDATE_SDK` | `undefined` | `undefined` | Used to signal the scripts to force-update the sdk, which might be present in the container. It's discouraged to use it, rather use dockers `--rm` flag. Everything other than `true` will be treated as `false`.  
`AUTOUPDATE` | `undefined` | `undefined` | Convenience Variable: If `true`, both `AUTOUPDATE_ENGINE` and `AUTOUPDATE_SDK` will be `true`.  
`BUILD_X86` | `true` | `true / false` | Whether or not to build the installers for X86/i586 (Windows and Linux 32bit).
`BUILD_X64` | `true` | `true / false` | Whether or not to build the installers for X64/amd64 (Windows and Linux 64bit).
`BUILD_OTHER` | `true` | `true / false` | Whether or not to build the other installers (Mac OS X and portable/platform independant zip).

Note: The `BUILD_` variables are all on by default, so building all installers can be done without additional environment switches.
If you however only want to build for 64 bit, then you'd add `-e BUILD_X64=true -e BUILD_X86=false -e BUILD_OTHER=false` to the `docker run` command.  

## Contribution
Contribution to this project is (as all of my projects) welcome. There is not much to change here however, apart from maybe fixing bugs and making the image smaller.  
The Size of ~ 250MiB is because I use `ubuntu:rolling`, but the Ubuntu image might already be on the hosts anyway.  
If you intend to make this container more user friendly (i.e. a dialog instead of these environment variables), please consider creating a container which depends on this one.
That way we can keep this container CI centric.
